--
-- this is the view that does not work
--
CREATE VIEW contract_rules_v (
    contract_rule_id,
    version,
    rowid,
    rgp_id,
    rule_info_category,
    contract_id,
    rule_name,
    rule_concatenated_values,
    d_rule_concatenated_values    
)
AS
SELECT
    cr.contract_rule_id,
    cr.version,
    cr.rdb$db_key,
    cr.rgp_id,
    cr.rule_info_category,
    crg.contract_id,
    crd.meaning,
    (SELECT p_concatenated_value 
        FROM df_get_concatenated_value(cr.rdb$db_key, 'CONTRACT RULE DF', cr.rule_info_category, NULL)) 
    AS rule_concatenated_values,
    (SELECT p_concatenated_value 
        FROM df_get_concatenated_value(cr.rdb$db_key, 'CONTRACT RULE DF', cr.rule_info_category, 'D')) 
    AS d_rule_concatenated_values
FROM
    contract_rule_groups crg
    JOIN contract_rules cr ON (crg.rgp_id = cr.rgp_id)
    JOIN contract_rule_defs crd ON (cr.rule_info_category = crd.rule_code);

COMMIT;
----------------------------------

-- this is the sp that work

SET TERM !! ;
CREATE PROCEDURE get_contract_rules

RETURNS(
    contract_rule_id    INTEGER,
    version             INTEGER,
    rowid               CHAR(8),
    rgp_id              INTEGER,
    rule_info_category  VARCHAR(80),
    contract_id         INTEGER,
    rule_name           VARCHAR(80),
    rule_concatenated_values    VARCHAR(20480),
    d_rule_concatenated_values  VARCHAR(20480)    
)
AS
BEGIN
    FOR
    SELECT
        cr.contract_rule_id,
        cr.version,
        cr.rdb$db_key,
        cr.rgp_id,
        cr.rule_info_category,
        crg.contract_id,
        crd.meaning,
        (SELECT p_concatenated_value 
            FROM df_get_concatenated_value(cr.rdb$db_key, 'CONTRACT RULE DF', cr.rule_info_category, NULL)) 
        AS rule_concatenated_values,
        (SELECT p_concatenated_value 
            FROM df_get_concatenated_value(cr.rdb$db_key, 'CONTRACT RULE DF', cr.rule_info_category, 'D')) 
        AS d_rule_concatenated_values
    FROM
        contract_rule_groups crg
        JOIN contract_rules cr ON (crg.rgp_id = cr.rgp_id)
        JOIN contract_rule_defs crd ON (cr.rule_info_category = crd.rule_code)
    INTO
        :contract_rule_id,
        :version,
        :rowid,
        :rgp_id,
        :rule_info_category,
        :contract_id,
        :rule_name,
        :rule_concatenated_values,
        :d_rule_concatenated_values
    DO
    BEGIN
        SUSPEND;
    END
END !!
SET TERM ; !!

-- ---------------------------------------------------------

SET TERM !! ;
CREATE PROCEDURE df_get_concatenated_value(
    p_rowid                         CHAR(8),
    p_descriptive_flexfield_name    VARCHAR(40),
    p_context_code                  VARCHAR(80),
    p_mode                          VARCHAR(1)
)
RETURNS(
    p_concatenated_value   VARCHAR(20480)
)
AS
    DECLARE VARIABLE v_concatenated_value  VARCHAR(20480);
    DECLARE VARIABLE v_sql                 VARCHAR(2048);
    DECLARE VARIABLE v_table_name          VARCHAR(30);
    DECLARE VARIABLE v_context_column_name VARCHAR(30);
    DECLARE VARIABLE v_appcolumn_name      VARCHAR(30);
    DECLARE VARIABLE v_appcolumn_name_expr VARCHAR(240);
    DECLARE VARIABLE v_flex_value_set_id   INTEGER; 
    DECLARE VARIABLE v_delimiter           VARCHAR(1);
    DECLARE VARIABLE v_sep                 VARCHAR(10);
    DECLARE VARIABLE v_has_columns         INTEGER = 0;
    DECLARE VARIABLE v_context_code        VARCHAR(80);    
    DECLARE VARIABLE v_validation_type     VARCHAR(1); 
BEGIN
    v_concatenated_value = '';

    -- get descriptive field info
    SELECT  
        table_name,
        context_column_name,
        concatenated_segment_delimiter
    FROM fnd_descriptive_flexs
    WHERE descriptive_flexfield_name = :p_descriptive_flexfield_name 
    INTO
        :v_table_name,
        :v_context_column_name,
        :v_delimiter;

    v_sep = '';
    v_sql = 'SELECT ' || v_context_column_name || ',';

    FOR 
    SELECT 
        app_column_name,
        flex_value_set_id        
    FROM fnd_descr_flex_col_usages
    WHERE
    (descriptive_flexfield_name = :p_descriptive_flexfield_name)
    AND (descriptive_flex_context_code = :p_context_code)
    ORDER BY column_seq_num
    INTO 
        :v_appcolumn_name,
        :v_flex_value_set_id
    DO
    BEGIN
        
        v_appcolumn_name_expr = v_appcolumn_name;

        SELECT 
            validation_type
        FROM fnd_flex_values_sets
        WHERE flex_value_set_id = :v_flex_value_set_id
        INTO :v_validation_type;

        IF ((ROW_COUNT = 1) AND (v_validation_type = 'F') AND (p_mode='D')) THEN
        BEGIN
            v_appcolumn_name_expr = 
                '(SELECT p_meaning FROM df_get_lookup_meaning(' || 
                    CAST(v_flex_value_set_id AS VARCHAR(15)) || ',' ||                    
                    v_appcolumn_name || '))';
        END

        v_sql = v_sql || v_sep || 'COALESCE(' || v_appcolumn_name_expr || ', '' '')' ;
        v_sep = ' || ''' || v_delimiter || ''' || ';
        v_has_columns = 1;
    END

    IF (v_has_columns = 0) THEN
    BEGIN
        v_sql = v_sql || '''''';
    END
        
    v_sql = v_sql || 
        ' AS concatenated_value' ||
        ' FROM ' || v_table_name || 
        ' WHERE rdb$db_key = ''' || p_rowid || '''';

    EXECUTE STATEMENT v_sql
    INTO
        :v_context_code,
        :v_concatenated_value;

    p_concatenated_value = v_concatenated_value;

	SUSPEND;
END !!
SET TERM ; !!


SET TERM !! ;
CREATE PROCEDURE df_get_lookup_meaning(
    p_flex_value_set_id             INTEGER,
    p_value                         VARCHAR(240)
)
RETURNS(
    p_meaning                       VARCHAR(240)
)
AS
    DECLARE VARIABLE v_sql                 VARCHAR(2048);
    DECLARE VARIABLE v_table_name          VARCHAR(30);
    DECLARE VARIABLE v_value_column_name   VARCHAR(30); 
    DECLARE VARIABLE v_meaning_column_name VARCHAR(30);
    DECLARE VARIABLE v_additional_where_clause  VARCHAR(1024);
BEGIN
    p_meaning = NULL;

    IF (NOT (p_value IS NULL)) THEN
    BEGIN    
        SELECT  
            table_name,
            value_column_name,
            meaning_column_name,
            additional_where_clause
        FROM fnd_flex_validation_tables
        WHERE (flex_value_set_id = :p_flex_value_set_id)
        INTO 
            :v_table_name,
            :v_value_column_name,
            :v_meaning_column_name,
            :v_additional_where_clause;

        IF (ROW_COUNT = 1) THEN
        BEGIN    
            v_sql = 
                'SELECT ' || v_meaning_column_name ||
                ' FROM ' || v_table_name || ' ' || 
                COALESCE(v_additional_where_clause, ' WHERE (1=1) ') || 
                'AND (' || v_value_column_name || '=''' || p_value || ''')';

            EXECUTE STATEMENT v_sql
            INTO
                :p_meaning;
            --p_meaning = v_sql;
        END
    END
    SUSPEND;
END !!
SET TERM ; !!
