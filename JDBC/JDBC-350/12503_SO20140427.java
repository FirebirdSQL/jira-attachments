package nl.lawinegevaar.fb;

import org.firebirdsql.pool.FBSimpleDataSource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

/**
 * Test for StackOverflow question <a href="http://stackoverflow.com/questions/23238260/simplejdbccall-nullpointerexception-on-firebird-db">http://stackoverflow.com/questions/23238260/simplejdbccall-nullpointerexception-on-firebird-db</a>
 *
 * @author <a href="mailto:mrotteveel@users.sourceforge.net">Mark Rotteveel</a>
 */
public class SO20140427 {

    /*
        Assumes the following DDL:
        CREATE GENERATOR GEN_MYRECORDS;

        CREATE TABLE MYRECORDS
        (
          ID Integer NOT NULL,
          UID Integer NOT NULL,
          PRIMARY KEY (ID)
        );
     */

    public static void main(String[] args) throws SQLException {
        FBSimpleDataSource ds = new FBSimpleDataSource();
        ds.setDatabase("//localhost/D:/data/db/testdatabase.fdb");
        ds.setUserName("sysdba");
        ds.setPassword("masterkey");
        int uid = 5;
        int last_inserted = 0;

        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
        // sp declaration
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_NEWRECORD")
                .declareParameters(
                        new SqlParameter("UID", Types.INTEGER),
                        new SqlOutParameter("NEWID", Types.INTEGER));
        Map<String, Object> in = new HashMap<String, Object>();
        in.put("UID", uid);

        try {
            Map<String, Object> out = jdbcCall.execute(in); //here throws Exception
            last_inserted = Integer.parseInt(String.valueOf(out.get("NEWID")));
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            System.out.println("createRecord result id=" + last_inserted);
        }
    }
}
