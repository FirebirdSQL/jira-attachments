
SET SQL DIALECT 3; 

/* CREATE DATABASE 'C:\SESMT\DADOS\SESMT.FDB' PAGE_SIZE 16384 DEFAULT CHARACTER SET ISO8859_1 */

/*  Character sets */
ALTER CHARACTER SET ISO8859_1 SET DEFAULT COLLATION PT_BR;



/*  Generators or sequences */
CREATE GENERATOR FLAMEROBIN$LOG_GEN;

/* Domain definitions */
CREATE DOMAIN D_ACAO AS VARCHAR(30) CHARACTER SET ISO8859_1
         CHECK (value <> '');
CREATE DOMAIN D_CODIGO30 AS VARCHAR(30) CHARACTER SET ISO8859_1 NOT NULL;
CREATE DOMAIN D_COMENTARIO AS VARCHAR(50) CHARACTER SET ISO8859_1;
CREATE DOMAIN D_CURRENT_TIME AS TIMESTAMP
         DEFAULT CURRENT_TIMESTAMP

 NOT NULL;
CREATE DOMAIN D_CURRENT_USER AS VARCHAR(30) CHARACTER SET ISO8859_1
         DEFAULT USER NOT NULL;
CREATE DOMAIN D_DATA AS DATE
         DEFAULT '1970-01-01'
         CHECK ((VALUE=NULL) or (VALUE >='1970-01-01'));
CREATE DOMAIN D_DURABILIDADE AS INTEGER
         DEFAULT 0
         CHECK (VALUE >=0) NOT NULL;
CREATE DOMAIN D_EPI AS VARCHAR(50) CHARACTER SET ISO8859_1 NOT NULL;
CREATE DOMAIN D_MEMO AS BLOB SUB_TYPE TEXT SEGMENT SIZE 5 CHARACTER SET ISO8859_1;
CREATE DOMAIN D_NOME_COMPLETO AS VARCHAR(120) CHARACTER SET ISO8859_1
         DEFAULT USER NOT NULL;
CREATE DOMAIN D_PERFIL AS VARCHAR(30) CHARACTER SET ISO8859_1 NOT NULL;
CREATE DOMAIN D_QUANTIDADE AS INTEGER
         DEFAULT 0
         CHECK (VALUE >=0) NOT NULL;
CREATE DOMAIN D_RESPOSTA AS CHAR(1) CHARACTER SET ISO8859_1
         DEFAULT 'N'
         CHECK (VALUE IN ('S', 'N')) NOT NULL;
CREATE DOMAIN D_RG AS VARCHAR(30) CHARACTER SET ISO8859_1
         DEFAULT NULL;
CREATE DOMAIN D_ROWID AS NUMERIC(18, 0)
         DEFAULT 0 NOT NULL;
CREATE DOMAIN D_STATUS AS CHAR(1) CHARACTER SET ISO8859_1 NOT NULL;
CREATE DOMAIN D_TEXTO AS VARCHAR(4096) CHARACTER SET ISO8859_1
         DEFAULT '';
CREATE DOMAIN D_TIPO_RETORNO AS VARCHAR(30) CHARACTER SET ISO8859_1
         DEFAULT ''
         CHECK (VALUE IN ('','EXPIRADOS','PERDIDOS','DANIFICADOS','PRORROGADOS'));
CREATE DOMAIN D_VALOR2 AS NUMERIC(18, 2)
         DEFAULT 0 NOT NULL;
CREATE DOMAIN MY_DATA AS DATE
         DEFAULT CURRENT_DATE;
CREATE DOMAIN MY_TIME AS TIME
         DEFAULT CURRENT_TIME;
CREATE DOMAIN MY_USER AS VARCHAR(32) CHARACTER SET ISO8859_1
         DEFAULT CURRENT_USER;

/* Table: AGENDA, Owner: SYSDBA */
CREATE TABLE AGENDA (ID_AGENDA D_ROWID,
        ID_COLABORADOR D_ROWID,
        DT_INICIAL D_DATA NOT NULL,
        DT_FINAL D_DATA NOT NULL,
        DESCRICAO D_TEXTO,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
        STATUS D_STATUS,
        STATUS_COM COMPUTED BY ((
  CASE
      WHEN status='A' THEN 'Aberto'
      WHEN status='F' THEN 'Permanente'
      WHEN status='C' THEN 'Cancelado'
  END)),
CONSTRAINT PK_AGENDA PRIMARY KEY (ID_AGENDA),
CONSTRAINT UNQ1_AGENDA UNIQUE (ID_COLABORADOR, DT_INICIAL, DT_FINAL));

/* Table: CA, Owner: SYSDBA */
CREATE TABLE CA (ID_CA D_ROWID NOT NULL,
        ID_EPI D_ROWID,
        VL_MEDIO D_VALOR2,
        VALIDO_ATE D_DATA,
        DESCRICAO D_TEXTO,
        APROVADO_PARA D_TEXTO,
        CA_SIMILAR D_RESPOSTA,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN status='A' THEN 'Ativo'
      WHEN status='C' THEN 'Inativo'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_CA PRIMARY KEY (ID_CA),
CONSTRAINT UNQ1_CA UNIQUE (ID_CA, ID_EPI));

/* Table: CARTEIRA, Owner: SYSDBA */
CREATE TABLE CARTEIRA (ID_CARTEIRA D_ROWID NOT NULL,
        ID_COLABORADOR D_ROWID,
        ID_EPI D_ROWID,
        QTDE_ATUAL D_ROWID,
        DT_PRIMEIRO_RECEBIMENTO D_DATA,
        DT_ULTIMO_RECEBIMENTO D_DATA,
        DT_ULTIMA_PRORROGACAO D_CURRENT_TIME,
        DT_VENCIMENTO D_DATA,
        OPCIONAL D_RESPOSTA,
        DURABILIDADE D_DURABILIDADE,
        DURABILIDADE_EXPLICACAO D_TEXTO,
        PRORROGACAO_DIAS D_QUANTIDADE,
        PRORROGACAO_MAX_VEZES D_QUANTIDADE,
        PRORROGACAO_REALIZADAS D_QUANTIDADE,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN ((QTDE_ATUAL=0) AND (OPCIONAL='S')) THEN 'Sem proteção, mas opcional'
      WHEN ((QTDE_ATUAL=0) AND (OPCIONAL<>'S')) THEN 'Sem proteção, item obrigatório'
      WHEN ((QTDE_ATUAL>0) AND (DT_VENCIMENTO >= current_date)) THEN 'Protegido'
      WHEN ((QTDE_ATUAL>0) AND (DT_VENCIMENTO < current_date)) THEN 'Protegido, mas item vencido'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_CARTEIRA PRIMARY KEY (ID_CARTEIRA),
CONSTRAINT UNQ1_CARTEIRA UNIQUE (ID_COLABORADOR, ID_EPI));

/* Table: CA_MOVTOS, Owner: SYSDBA */
CREATE TABLE CA_MOVTOS (ID_MOVTO D_ROWID NOT NULL,
        ID_COLABORADOR D_ROWID,
        ID_CA D_ROWID,
        ID_EPI D_ROWID,
        LOTE D_ROWID,
        DT_SAIDA D_DATA,
        DT_RETORNO D_DATA,
        DT_VENCIMENTO D_DATA,
        TIPO_RETORNO D_TIPO_RETORNO,
        OPCIONAL D_RESPOSTA,
        DURABILIDADE D_DURABILIDADE,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS,
        STATUS_COM COMPUTED BY (
    CASE
      WHEN status='A' THEN 'Aguardando devolução'
      WHEN status='C' THEN 'Cancelado'
      WHEN status='F' THEN 'Devolvido'
    END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_CA_MOVTOS PRIMARY KEY (ID_MOVTO));

/* Table: CA_MOVTOS_PRORROGACAO, Owner: SYSDBA */
CREATE TABLE CA_MOVTOS_PRORROGACAO (ID_PRORROGACAO D_ROWID NOT NULL,
        ID_MOVTO D_ROWID NOT NULL,
        DT_VENCIMENTO_ANTES D_DATA NOT NULL,
        DT_VENCIMENTO_DEPOIS D_DATA NOT NULL,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_CA_MOVTOS_PRORROGACAO PRIMARY KEY (ID_PRORROGACAO));

/* Table: COLABORADOR, Owner: SYSDBA */
CREATE TABLE COLABORADOR (ID_COLABORADOR D_ROWID,
        NOME_COMPLETO D_NOME_COMPLETO,
        RG D_RG,
        DT_CRIACAO D_DATA,
        DT_INICIO D_DATA,
        TRAB_SEG D_RESPOSTA,
        TRAB_TER D_RESPOSTA,
        TRAB_QUA D_RESPOSTA,
        TRAB_QUI D_RESPOSTA,
        TRAB_SEX D_RESPOSTA,
        TRAB_SAB D_RESPOSTA,
        TRAB_DOM D_RESPOSTA,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN status='A' THEN 'Ativo'
      WHEN status='C' THEN 'Inativo'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_COLABORADOR PRIMARY KEY (ID_COLABORADOR),
CONSTRAINT UNQ1_COLABORADOR UNIQUE (NOME_COMPLETO));

/* Table: COLABORADOR_PERFIL, Owner: SYSDBA */
CREATE TABLE COLABORADOR_PERFIL (ID_COLABORADOR D_ROWID,
        ID_PERFIL D_ROWID,
CONSTRAINT PK_COLABORADOR_PERFIL PRIMARY KEY (ID_COLABORADOR, ID_PERFIL));

/* Table: COLABORADOR_PERFIL_MOVTOS, Owner: SYSDBA */
CREATE TABLE COLABORADOR_PERFIL_MOVTOS (ID_PERFIL_MOVTOS D_ROWID,
        ID_COLABORADOR D_ROWID,
        ID_PERFIL D_ROWID,
        DT_INICIO D_DATA NOT NULL,
        DT_TERMINO D_DATA,
        EPI_UTILIZADOS D_TEXTO,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS NOT NULL,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN status='A' THEN 'Ativo'
      WHEN status='C' THEN 'Inativo'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_COLABORADOR_PERFIL_MOVTOS PRIMARY KEY (ID_PERFIL_MOVTOS),
CONSTRAINT UNQ1_COLABORADOR_PERFIL_MOVTOS UNIQUE (ID_COLABORADOR, ID_PERFIL, DT_INICIO));

/* Table: EPI, Owner: SYSDBA */
CREATE TABLE EPI (ID_EPI D_ROWID,
        EPI D_EPI NOT NULL,
        VL_MEDIO D_VALOR2,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS NOT NULL,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN status='A' THEN 'Ativo'
      WHEN status='C' THEN 'Inativo'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_EPI PRIMARY KEY (ID_EPI),
CONSTRAINT UNQ1_EPI UNIQUE (EPI));

/* Table: FLAMEROBIN$LOG, Owner: SYSDBA */
CREATE TABLE FLAMEROBIN$LOG (ID INTEGER NOT NULL,
        OBJECT_TYPE VARCHAR(10) CHARACTER SET ISO8859_1,
        OBJECT_NAME CHAR(31) CHARACTER SET ISO8859_1,
        SQL_STATEMENT BLOB SUB_TYPE TEXT SEGMENT SIZE 80 CHARACTER SET ISO8859_1,
        EXECUTED_AT TIMESTAMP default current_timestamp,
        USER_NAME CHAR(31) CHARACTER SET ISO8859_1 default current_user);

/* Table: LOG_ERRORS, Owner: SYSDBA */
CREATE TABLE LOG_ERRORS (ID D_ROWID,
        CONTEXTO D_NOME_COMPLETO,
        DESCRICAO D_TEXTO,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        FATAL D_RESPOSTA,
CONSTRAINT PK_LOG_ERRORS PRIMARY KEY (ID));

/* Table: PARAMETROS, Owner: SYSDBA */
CREATE TABLE PARAMETROS (PARAMETRO D_CODIGO30 NOT NULL,
        VALOR_NUM D_QUANTIDADE,
        VALOR_STR D_NOME_COMPLETO,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
CONSTRAINT PK_PARAMETROS PRIMARY KEY (PARAMETRO));

/* Table: PERFIL, Owner: SYSDBA */
CREATE TABLE PERFIL (ID_PERFIL D_ROWID,
        PERFIL D_PERFIL NOT NULL,
        DESCRICAO D_TEXTO,
        LAST_UPDATE D_CURRENT_TIME,
        LAST_OWNER D_CURRENT_USER,
        STATUS D_STATUS,
        STATUS_COM COMPUTED BY (
  CASE
      WHEN status='A' THEN 'Ativo'
      WHEN status='C' THEN 'Inativo'
  END),
        MODIFICADO_EM COMPUTED BY (CAST((SUBSTRING(CAST(LAST_UPDATE as varchar(30)) FROM 1 FOR 10)||' por '||LAST_OWNER) as varchar(40))),
CONSTRAINT PK_PERFIL PRIMARY KEY (ID_PERFIL),
CONSTRAINT UNQ1_PERFIL UNIQUE (PERFIL));

/* Table: PERFIL_EPI, Owner: SYSDBA */
CREATE TABLE PERFIL_EPI (ID_PERFIL D_ROWID,
        ID_EPI D_ROWID,
        OPCIONAL D_RESPOSTA,
        DURABILIDADE D_DURABILIDADE,
        DURABILIDADE_EXPLICACAO D_TEXTO,
        PRORROGACAO_DIAS D_QUANTIDADE,
        PRORROGACAO_MAX_VEZES D_QUANTIDADE,
CONSTRAINT PK_PERFIL_EPI PRIMARY KEY (ID_PERFIL, ID_EPI));

/*  Index definitions for all user tables */
CREATE INDEX CA_MOVTOS_IDX1 ON CA_MOVTOS (ID_COLABORADOR, ID_EPI, DT_VENCIMENTO);
CREATE INDEX CA_MOVTOS_IDX2 ON CA_MOVTOS (ID_COLABORADOR, ID_EPI, LOTE);
CREATE INDEX CA_MOVTOS_PRORROGACAO_IDX1 ON CA_MOVTOS_PRORROGACAO (ID_PRORROGACAO, ID_MOVTO);

ALTER TABLE CA ADD CONSTRAINT FK_CA_1 FOREIGN KEY (ID_EPI) REFERENCES EPI (ID_EPI);

ALTER TABLE CARTEIRA ADD CONSTRAINT FK_CARTEIRA_1 FOREIGN KEY (ID_COLABORADOR) REFERENCES COLABORADOR (ID_COLABORADOR);

ALTER TABLE CARTEIRA ADD CONSTRAINT FK_CARTEIRA_2 FOREIGN KEY (ID_EPI) REFERENCES EPI (ID_EPI);

ALTER TABLE CA_MOVTOS ADD CONSTRAINT FK_CA_MOVTOS_1 FOREIGN KEY (ID_COLABORADOR) REFERENCES COLABORADOR (ID_COLABORADOR);

ALTER TABLE CA_MOVTOS ADD CONSTRAINT FK_CA_MOVTOS_2 FOREIGN KEY (ID_CA) REFERENCES CA (ID_CA);

ALTER TABLE CA_MOVTOS ADD CONSTRAINT FK_CA_MOVTOS_3 FOREIGN KEY (ID_EPI) REFERENCES EPI (ID_EPI);

ALTER TABLE COLABORADOR_PERFIL ADD CONSTRAINT FK_COLABORADOR_PERFIL_1 FOREIGN KEY (ID_COLABORADOR) REFERENCES COLABORADOR (ID_COLABORADOR);

ALTER TABLE COLABORADOR_PERFIL ADD CONSTRAINT FK_COLABORADOR_PERFIL_2 FOREIGN KEY (ID_PERFIL) REFERENCES PERFIL (ID_PERFIL);

ALTER TABLE COLABORADOR_PERFIL_MOVTOS ADD CONSTRAINT FK_COLABORADOR_PERFIL_MOVTOS_1 FOREIGN KEY (ID_COLABORADOR) REFERENCES COLABORADOR (ID_COLABORADOR);

ALTER TABLE COLABORADOR_PERFIL_MOVTOS ADD CONSTRAINT FK_COLABORADOR_PERFIL_MOVTOS_2 FOREIGN KEY (ID_PERFIL) REFERENCES PERFIL (ID_PERFIL);

ALTER TABLE PERFIL_EPI ADD CONSTRAINT FK_PERFIL_EPI_1 FOREIGN KEY (ID_PERFIL) REFERENCES PERFIL (ID_PERFIL);

ALTER TABLE PERFIL_EPI ADD CONSTRAINT FK_PERFIL_EPI_2 FOREIGN KEY (ID_EPI) REFERENCES EPI (ID_EPI);

/*  Exceptions */
CREATE EXCEPTION ERR 'ERRO GENERICO';
COMMIT WORK;
SET AUTODDL OFF;
SET TERM ^ ;

/* Stored procedures */
CREATE PROCEDURE GET_CARTEIRA (P_ID_COLABORADOR D_ROWID DEFAULT 0,
P_ID_EPI D_ROWID DEFAULT 0,
P_DT_DURAR_ATE DATE DEFAULT current_date,
P_SE_CALCULAR_DIAS_ATRASO CHAR(1) CHARACTER SETISO8859_1  DEFAULT 'N',
P_SE_CALCULAR_DIAS_USUFRUTO CHAR(1) CHARACTER SETISO8859_1  DEFAULT 'N')
RETURNS (ID_CARTEIRA D_ROWID,
ID_COLABORADOR D_ROWID,
COLABORADOR D_NOME_COMPLETO,
ID_EPI D_ROWID,
EPI VARCHAR(50) CHARACTER SETISO8859_1 ,
QTDE_ATUAL INTEGER,
QTDE_SUGERIDA INTEGER,
DT_PRIMEIRO_RECEBIMENTO DATE,
DT_ULTIMO_RECEBIMENTO DATE,
DT_ULTIMA_PRORROGACAO DATE,
DT_VENCIMENTO DATE,
DIAS_ATRASO INTEGER,
DIAS_USUFRUTO INTEGER,
OPCIONAL VARCHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE INTEGER,
DURABILIDADE_EXPLICACAO VARCHAR(4096) CHARACTER SETISO8859_1 ,
PRORROGACAO_DIAS INTEGER,
PRORROGACAO_MAX_VEZES INTEGER,
PRORROGACAO_REALIZADAS INTEGER,
LAST_UPDATE TIMESTAMP,
LAST_OWNER VARCHAR(30) CHARACTER SETISO8859_1 ,
STATUS_COM VARCHAR(50) CHARACTER SETISO8859_1 )
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_CA_LISTA (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR)
RETURNS (ID_PERFIL D_ROWID,
ID_CA D_ROWID,
ID_EPI D_ROWID,
EPI TYPE OF COLUMN EPI.EPI,
OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL,
DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE,
DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_CA_MOVTOS_RANGE (P_DT_INICIAL D_DATA,
P_DT_FINAL D_DATA = current_date,
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (ID_MOVTO D_ROWID,
ID_COLABORADOR D_ROWID,
ID_CA D_ROWID,
ID_EPI D_ROWID,
DT_SAIDA D_DATA,
DT_RETORNO D_DATA,
TIPO_RETORNO D_TIPO_RETORNO,
OPCIONAL CHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE D_DURABILIDADE,
STATUS CHAR(1) CHARACTER SETISO8859_1 )
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_DIAS_UTEIS (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR,
P_DT_INICIO D_DATA,
P_DT_TERMINO D_DATA)
RETURNS (DIAS_UTEIS INTEGER)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_DT_INAUGURACAO RETURNS (DT_INAUGURACAO D_DATA)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_DT_ULTIMO_VENCIMENTO (P_ID_COLABORADOR D_ROWID,
P_ID_EPI D_ROWID,
P_DEFAULT_DATE D_DATA = current_date)
RETURNS (EXISTE_VENCIMENTO CHAR(1) CHARACTER SETISO8859_1 ,
DT_VENCIMENTO DATE)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_DURABILIDADE_EM (PID_COLABORADOR D_ROWID,
PID_EPI D_ROWID,
PDT_SAIDA D_DATA)
RETURNS (DURABILIDADE INTEGER)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_EPI_LISTA (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR)
RETURNS (ID_PERFIL TYPE OF COLUMN PERFIL_EPI.ID_PERFIL,
ID_EPI TYPE OF COLUMN PERFIL_EPI.ID_EPI,
EPI TYPE OF COLUMN EPI.EPI,
OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL,
DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE,
DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_QS (P_ID_COLABORADOR D_ROWID,
P_ID_EPI D_ROWID,
P_DT_DURAR_ATE D_DATA)
RETURNS (QS INTEGER)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_SE_DIA_UTIL (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR,
P_DATA D_DATA)
RETURNS (DIA_UTIL CHAR(1) CHARACTER SETISO8859_1 )
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_SOMA_DIAS_UTEIS (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR = 0,
P_DT_INICIO D_DATA = current_date,
P_QTDE_DIAS D_QUANTIDADE = 1)
RETURNS (RESULT_DATE DATE)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_USO_TABELAS RETURNS (TABELA VARCHAR(32) CHARACTER SETISO8859_1 ,
QUANTIDADE INTEGER)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE GET_VENCIMENTO (P_ID_COLABORADOR TYPE OF D_ROWID,
P_ID_EPI TYPE OF D_ROWID,
P_QUANTIDADE D_QUANTIDADE,
P_DT_INICIO D_DATA)
RETURNS (ID_PERFIL D_ROWID,
DT_VENCIMENTO DATE,
OPCIONAL CHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE INTEGER,
DURABILIDADE_EXPLICACAO D_TEXTO,
PRORROGACAO_DIAS INTEGER,
PRORROGACAO_MAX_VEZES INTEGER)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SET_DESTRUIR_DADOS (P_CONFIRMACAO D_RESPOSTA)
AS 
BEGIN EXIT; END ^
CREATE PROCEDURE SP_AGENDA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_AGENDA D_ROWID = 0,
P_ID_COLABORADOR D_ROWID = 0,
P_DT_INICIAL D_DATA = current_date,
P_DT_FINAL D_DATA = current_date,
P_DESCRICAO D_TEXTO = '',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_CA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_CA D_ROWID,
P_ID_EPI D_ROWID = 0,
P_VL_MEDIO D_VALOR2 = 0,
P_VALIDO_ATE D_DATA = '2012-01-01',
P_DESCRICAO D_TEXTO = '',
P_APROVADO_PARA D_TEXTO = '',
P_CA_SIMILAR D_RESPOSTA = 'N',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_CARTEIRA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (RESULT_VALUE BIGINT)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_CARTEIRA_RECALC_ITEM (P_ID_COLABORADOR D_ROWID = 0,
P_ID_EPI D_ROWID = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_COLABORADOR (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID,
P_NOME_COMPLETO D_NOME_COMPLETO = '',
P_RG D_RG = '',
P_DT_INICIO D_DATA = current_date,
P_TRAB_SEG D_RESPOSTA = 'n',
P_TRAB_TER D_RESPOSTA = 'n',
P_TRAB_QUA D_RESPOSTA = 'n',
P_TRAB_QUI D_RESPOSTA = 'n',
P_TRAB_SEX D_RESPOSTA = 'n',
P_TRAB_SAB D_RESPOSTA = 'n',
P_TRAB_DOM D_RESPOSTA = 'n',
P_STATUS D_STATUS = 'a')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_COLABORADOR_PERFIL (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID,
P_ID_PERFIL D_PERFIL)
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_EPI (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_EPI TYPE OF COLUMN EPI.ID_EPI = 0,
P_EPI TYPE OF COLUMN EPI.EPI = '',
P_VL_MEDIO TYPE OF COLUMN EPI.VL_MEDIO = 0,
P_STATUS D_STATUS = 'a')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_LOG (P_CONTEXTO TYPE OF COLUMN LOG_ERRORS.CONTEXTO,
P_DESCRICAO TYPE OF COLUMN LOG_ERRORS.DESCRICAO,
P_FATAL VARCHAR(1) CHARACTER SETISO8859_1  = 'N')
AS 
BEGIN EXIT; END ^
CREATE PROCEDURE SP_MOVTO_DEVOLVER (PID_CA D_ROWID,
PID_COLABORADOR D_ROWID,
PDT_RETORNO D_DATA,
PTIPO_RETORNO D_TIPO_RETORNO,
PQUANTIDADE D_QUANTIDADE = 0,
PDIAS_USUFRUTO D_QUANTIDADE = 0,
PNOVA_RETIRADA_ID_CA D_ROWID = 0,
PNOVA_RETIRADA_QUANTIDADE D_QUANTIDADE = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_MOVTO_ENTREGAR (P_ID_CA D_ROWID = 0,
P_ID_COLABORADOR D_ROWID = 0,
P_QTDE_SAIDA D_QUANTIDADE = 0,
P_DT_SAIDA D_DATA = current_date,
P_RECALCULAR CHAR(1) CHARACTER SETISO8859_1  = 'S')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_PARAMETROS (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_PARAMETRO D_CODIGO30,
P_VALOR_NUM TYPE OF COLUMN PARAMETROS.VALOR_NUM = 0,
P_VALOR_STR TYPE OF COLUMN PARAMETROS.VALOR_STR = '')
RETURNS (VALOR_NUM TYPE OF COLUMN PARAMETROS.VALOR_NUM,
VALOR_STR TYPE OF COLUMN PARAMETROS.VALOR_STR)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_PERFIL (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_PERFIL D_ROWID,
P_PERFIL D_PERFIL = '',
P_DESCRICAO D_TEXTO = '',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_PERFIL_EPI (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_PERFIL TYPE OF COLUMN PERFIL_EPI.ID_PERFIL,
P_ID_EPI TYPE OF COLUMN PERFIL_EPI.ID_EPI,
P_OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL = 'N',
P_DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE = 0,
P_DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO = '',
P_PRORROGACAO_DIAS TYPE OF COLUMN PERFIL_EPI.PRORROGACAO_DIAS = 0,
P_PRORROGACAO_MAX_VEZES TYPE OF COLUMN PERFIL_EPI.PRORROGACAO_MAX_VEZES = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
BEGIN SUSPEND; END ^
CREATE PROCEDURE SP_RECALCULAR (P_DT_INICIAL D_DATA = '1970-01-01',
P_DT_FINAL D_DATA = '1970-01-01',
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (RESULT_VALUE INTEGER)
AS 
BEGIN SUSPEND; END ^

ALTER PROCEDURE GET_CARTEIRA (P_ID_COLABORADOR D_ROWID DEFAULT 0,
P_ID_EPI D_ROWID DEFAULT 0,
P_DT_DURAR_ATE DATE DEFAULT current_date,
P_SE_CALCULAR_DIAS_ATRASO CHAR(1) CHARACTER SETISO8859_1  DEFAULT 'N',
P_SE_CALCULAR_DIAS_USUFRUTO CHAR(1) CHARACTER SETISO8859_1  DEFAULT 'N')
RETURNS (ID_CARTEIRA D_ROWID,
ID_COLABORADOR D_ROWID,
COLABORADOR D_NOME_COMPLETO,
ID_EPI D_ROWID,
EPI VARCHAR(50) CHARACTER SETISO8859_1 ,
QTDE_ATUAL INTEGER,
QTDE_SUGERIDA INTEGER,
DT_PRIMEIRO_RECEBIMENTO DATE,
DT_ULTIMO_RECEBIMENTO DATE,
DT_ULTIMA_PRORROGACAO DATE,
DT_VENCIMENTO DATE,
DIAS_ATRASO INTEGER,
DIAS_USUFRUTO INTEGER,
OPCIONAL VARCHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE INTEGER,
DURABILIDADE_EXPLICACAO VARCHAR(4096) CHARACTER SETISO8859_1 ,
PRORROGACAO_DIAS INTEGER,
PRORROGACAO_MAX_VEZES INTEGER,
PRORROGACAO_REALIZADAS INTEGER,
LAST_UPDATE TIMESTAMP,
LAST_OWNER VARCHAR(30) CHARACTER SETISO8859_1 ,
STATUS_COM VARCHAR(50) CHARACTER SETISO8859_1 )
AS 
declare variable nvalor1 integer;
declare variable lnecessario integer;
declare variable lexistente integer;
declare variable lid_colaborador integer;
declare variable q1 varchar(4096) = '';
declare variable q2 varchar(4096) = '';
declare variable lse_atrasado char(1) = 'N';
declare variable ldate_start date;
declare variable ldate_finish date;
declare variable lultimo_recebimento date;
begin
  -- quando a quantidade de itens existentes no CARTEIRA difere do quanto
  -- deveria ter então o programa recalcula todos */
  q1='select a.id_colaborador from colaborador a ';
  if (:p_id_colaborador=0) then
  begin
    q1=:q1||'where (a.status=''A'') ';
  end
  else
  begin
    q1=:q1||'where (a.id_colaborador='||cast(:p_id_colaborador as varchar(8))||') ';
  end
  for execute statement (:q1)
    into
      :lid_colaborador do
  begin
    select count(*) from CARTEIRA
    where id_colaborador=:lid_colaborador
    into :lexistente;

    select count(*) from colaborador_perfil a
    inner join perfil_epi b on (a.id_perfil=b.id_perfil)
    where a.id_colaborador=:lid_colaborador
    into :lnecessario;
  
    if (:lexistente<>:lnecessario) then
    begin
      execute procedure SP_CARTEIRA ('RECALCULAR',:lid_colaborador) returning_values :nvalor1;
      if (:nvalor1<=0) then
      begin
        execute procedure SP_LOG  'GET_CARTEIRA','Este colaborador ('||cast(:lid_colaborador as varchar(8))||'não possui carteira de items!';
      end
    end
  end

  q2='
    select
      a.id_carteira,
      a.id_colaborador,
      c.nome_completo,
      a.id_epi,
      b.epi,
      a.qtde_atual,
      a.dt_primeiro_recebimento,
      a.dt_ultimo_recebimento,
      a.dt_vencimento,
      a.opcional,
      a.durabilidade,
      a.durabilidade_explicacao,
      a.prorrogacao_dias,
      a.prorrogacao_max_vezes,
      a.prorrogacao_realizadas,
      a.dt_ultima_prorrogacao,
      a.last_update,
      a.last_owner,
      a.status_com
    from CARTEIRA a
    inner join epi b ON (b.id_epi=a.id_epi)
    inner join colaborador c ON (c.id_colaborador=a.id_colaborador)';
  if (:p_id_colaborador>0) then
  begin
    q2=:q2||'where (a.id_colaborador='||cast(:p_id_colaborador as varchar(8))||') ';
  end

  if (:p_id_epi>0) then
  begin
    q2=:q2||' and (a.id_epi='||cast(:p_id_epi as varchar(8))||') ';
  end
  q2=:q2||'order by a.id_epi';

--execute procedure SP_LOG  'GET_CARTEIRA',:q2;
--exit;
  for execute statement (:q2)
    into
      :id_carteira,
      :id_colaborador,
      :colaborador,
      :id_epi,
      :epi,
      :qtde_atual,
      :dt_primeiro_recebimento,
      :dt_ultimo_recebimento,
      :dt_vencimento,
      :opcional,
      :durabilidade,
      :durabilidade_explicacao,
      :prorrogacao_dias,
      :prorrogacao_max_vezes,
      :prorrogacao_realizadas,
      :dt_ultima_prorrogacao,
      :last_update,
      :last_owner,
      :status_com  do
  begin
    -- calculando quantidade sugerida (qs)
    select qs from GET_QS (:id_colaborador,:id_epi,:p_dt_durar_ate)
    into :qtde_sugerida;
    if (:qtde_sugerida is null) then qtde_sugerida=0;
    -- Calculando dias de atraso
    dias_atraso=0;
    dias_usufruto=0;

    if ((:p_se_calcular_dias_atraso = 'S') and (:qtde_atual>0) ) then
    begin
      ldate_start=:dt_vencimento;
      if ((:ldate_start is null) or (:ldate_start <= '01.01.2000')) then
      begin
        select dt_inicio from colaborador where id_colaborador=:id_colaborador
        into :ldate_start;
      end
      ldate_finish=current_date;
      if (:ldate_finish > :ldate_start) then
      begin
        SELECT dias_uteis FROM GET_DIAS_UTEIS (:id_colaborador, :ldate_start, :ldate_finish)
        INTO :dias_atraso;
      end
    end
    if ((:p_se_calcular_dias_usufruto = 'S') and (:qtde_atual>0)) then
    begin
      ldate_start=:dt_ultimo_recebimento;
      ldate_finish=current_date;
      select a.dt_ultimo_recebimento  from carteira a where a.id_colaborador=:id_colaborador and a.id_epi=:id_epi
      into :lultimo_recebimento;
      if (:ldate_finish > :ldate_start) then
      begin
        SELECT dias_uteis FROM GET_DIAS_UTEIS (:id_colaborador, :ldate_start, :ldate_finish)
        INTO :dias_usufruto;
      end
    end

    suspend;
  end

end ^

ALTER PROCEDURE GET_CA_LISTA (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR)
RETURNS (ID_PERFIL D_ROWID,
ID_CA D_ROWID,
ID_EPI D_ROWID,
EPI TYPE OF COLUMN EPI.EPI,
OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL,
DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE,
DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO)
AS 
begin
  if (not exists(select * from colaborador where id_colaborador=:p_id_colaborador)) then
  begin
    execute procedure SP_LOG  'GET_CA_LISTA',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não existe.','S';
    suspend;
    exit;
  end 

  if (not exists(select * from colaborador_perfil where id_colaborador=:p_id_colaborador)) then
  begin
    execute procedure SP_LOG  'GET_CA_LISTA',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não possui perfil.','S';
    suspend;
    exit;
  end 


  for
    select id_perfil
    from colaborador_perfil a
    where a.id_colaborador=:p_id_colaborador
    into :id_perfil do
  begin
    for
      select c.id_ca, a.id_epi, b.epi, a.opcional, a.durabilidade, a.durabilidade_explicacao
      from perfil_epi a
      inner join epi b on (b.id_epi=a.id_epi)
      inner join ca c on (c.id_epi=a.id_epi)
      where a.id_perfil=:id_perfil
      order by b.epi
      into :id_ca, :id_epi, :epi, :opcional, :durabilidade, :durabilidade_explicacao do
      begin
        suspend;
      end
  end

end ^

ALTER PROCEDURE GET_CA_MOVTOS_RANGE (P_DT_INICIAL D_DATA,
P_DT_FINAL D_DATA = current_date,
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (ID_MOVTO D_ROWID,
ID_COLABORADOR D_ROWID,
ID_CA D_ROWID,
ID_EPI D_ROWID,
DT_SAIDA D_DATA,
DT_RETORNO D_DATA,
TIPO_RETORNO D_TIPO_RETORNO,
OPCIONAL CHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE D_DURABILIDADE,
STATUS CHAR(1) CHARACTER SETISO8859_1 )
AS 
declare variable stmt varchar(4096) = '';
begin
  /* Se a data inicial não for especificada então o recalculo incluirá desde o registro mais antigo */
  /* Se a data final não for especificada entao assume a data atual */
  if (:p_dt_final < '2000-01-01') then p_dt_final=current_date;

  stmt='
  select a.id_movto,
               a.id_colaborador,
               a.id_ca,
               a.id_epi,
               a.dt_saida,
               a.dt_retorno,
               a.tipo_retorno,
               a.opcional,
               a.durabilidade,
               a.status
  from ca_movtos a
  inner join carteira b on (b.id_colaborador=a.id_colaborador and b.id_epi=a.id_epi)
  where (a.status=''A'')
  and ((b.dt_vencimento>= :st_dt_final) and (a.dt_saida <= :st_dt_final)) or
      ((b.dt_vencimento>= :st_dt_inicial) and (a.dt_saida <= :st_dt_inicial))';

  if (:p_id_colaborador>0) then
  begin
    stmt=:stmt||' and (a.id_colaborador='||cast(:p_id_colaborador as varchar(8))||')';
  end
  stmt=:stmt||'order by a.dt_saida';

  for execute statement (:stmt) ( st_dt_inicial := :p_dt_inicial, st_dt_final := :p_dt_final )
  into
      :id_movto,
      :id_colaborador,
      :id_ca,
      :id_epi,
      :dt_saida,
      :dt_retorno,
      :tipo_retorno,
      :opcional,
      :durabilidade,
      :status
  do begin
    suspend;
  end
end ^

ALTER PROCEDURE GET_DIAS_UTEIS (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR,
P_DT_INICIO D_DATA,
P_DT_TERMINO D_DATA)
RETURNS (DIAS_UTEIS INTEGER)
AS 
declare variable ldia_util varchar(1) = '';
declare variable ltemp_date date = current_date;
begin
  dias_uteis=0;

  /* Se a data inicial nao for mencionada entao a data inicial passa a ser
    o primeiro dia de trabalho do colaborador e se o colaborador não for
    mencionado entao usa a data do primeiro dia de trabalhado do colaborador
    mais antigo */
  if (:p_dt_inicio < '01.01.2000') then
  begin
    if (:p_id_colaborador = 0) then
    begin
      select min(dt_inicio) from colaborador
      into :p_dt_inicio;
    end
    else
    begin
      select dt_inicio from colaborador where id_colaborador=:p_id_colaborador
      into :p_dt_inicio;
    end
  end

  if (:p_dt_inicio < '2000-01-01') then
  begin
    execute procedure SP_LOG  'GET_DIAS_UTEIS',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') contou com data inicial inferior a 01.01.2000';
    suspend;
    exit;
  end

  ltemp_date=:p_dt_inicio;
  dias_uteis=0;
  while (:ltemp_date <= :p_dt_termino) do
  begin
    execute procedure GET_SE_DIA_UTIL (:p_id_colaborador, :ltemp_date) returning_values :ldia_util;
    if (:ldia_util = 'S') then dias_uteis=:dias_uteis+1;
    ltemp_date=dateadd (1 day to :ltemp_date);
  end

  /* Procedure Text */
  suspend;
end ^

ALTER PROCEDURE GET_DT_INAUGURACAO RETURNS (DT_INAUGURACAO D_DATA)
AS 
begin
  select first 1 a.dt_inicio
  from  colaborador a
  order by a.dt_inicio
  into :dt_inauguracao;
  suspend;
end ^

ALTER PROCEDURE GET_DT_ULTIMO_VENCIMENTO (P_ID_COLABORADOR D_ROWID,
P_ID_EPI D_ROWID,
P_DEFAULT_DATE D_DATA = current_date)
RETURNS (EXISTE_VENCIMENTO CHAR(1) CHARACTER SETISO8859_1 ,
DT_VENCIMENTO DATE)
AS 
declare variable l_dt_vencimento date = current_date;
begin
  existe_vencimento='S';
  select max(dt_vencimento) from carteira
  where id_colaborador=:p_id_colaborador and id_epi=:p_id_epi
  into :l_dt_vencimento;
  if ((:l_dt_vencimento is null) or (:l_dt_vencimento < '01.01.2000')) then
  begin
    l_dt_vencimento=:p_default_date;
    existe_vencimento='N';
  end
  dt_vencimento=:l_dt_vencimento;
  suspend;
end ^

ALTER PROCEDURE GET_DURABILIDADE_EM (PID_COLABORADOR D_ROWID,
PID_EPI D_ROWID,
PDT_SAIDA D_DATA)
RETURNS (DURABILIDADE INTEGER)
AS 
declare variable ldur_entregues integer = 0;
declare variable ldur_devolvidos integer = 0;
declare variable q1 varchar(4096) = '';
declare variable q2 varchar(4096) = '';
declare variable lid_colaborador d_rowid = 0;
declare variable ldt_saida d_data = '01.01.1970';
declare variable ldt_retorno d_data = '01.01.1970';
declare variable ldt_vencimento d_data = '01.01.1970';
declare variable ldurabilidade d_durabilidade = 0;
begin
  durabilidade=0;
  q1='select id_colaborador, dt_saida, dt_retorno, dt_vencimento, durabilidade '||
     'from ca_movtos a where (a.id_epi='||cast(:pid_epi as varchar(8))||')' ;
  if (:pid_colaborador>0) then
  begin
    q1=:q1||' and (a.id_colaborador='||cast(:pid_colaborador as varchar(8))||')';
  end
  q1=:q1||' and a.status<>''C''';
  q2=:q1||' and a.dt_saida <= :pst_desejada';
  -- Calculando quantos EPIs sairam
  ldur_entregues=0;
  for execute statement (:q2) ( pst_desejada := :pdt_saida )
  into
    :lid_colaborador,
    :ldt_saida,
    :ldt_retorno,
    :ldt_vencimento,
    :ldurabilidade
  do
  begin
    ldur_entregues=(:ldur_entregues+:ldurabilidade);
  end

  -- Calculando quantos EPIs foram devolvidos
  ldur_devolvidos=0;
  q1=:q1||' and (a.dt_retorno > ''01.01.1970'')';
  q2=:q1||' and (a.dt_retorno <= :pst_desejada)';
  for execute statement (:q2) ( pst_desejada := :pdt_saida )
  into
    :lid_colaborador,
    :ldt_saida,
    :ldt_retorno,
    :ldt_vencimento,
    :ldurabilidade
  do
  begin
    ldur_devolvidos=(:ldur_devolvidos+:ldurabilidade);
  end
  --exception err :q2;
  /* Resultado */
  durabilidade=:ldur_entregues-:ldur_devolvidos;
  suspend;
end ^

ALTER PROCEDURE GET_EPI_LISTA (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR)
RETURNS (ID_PERFIL TYPE OF COLUMN PERFIL_EPI.ID_PERFIL,
ID_EPI TYPE OF COLUMN PERFIL_EPI.ID_EPI,
EPI TYPE OF COLUMN EPI.EPI,
OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL,
DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE,
DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO)
AS 
begin
  if (not exists(select * from colaborador where id_colaborador=:p_id_colaborador)) then
  begin
    execute procedure SP_LOG  'GET_EPI_LISTA',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não existe.','S';
    suspend;
    exit;
  end 

  if (not exists(select * from colaborador_perfil where id_colaborador=:p_id_colaborador)) then
  begin
    execute procedure SP_LOG  'GET_EPI_LISTA',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não possui perfil.','S';
    suspend;
    exit;
  end 


  for
    select id_perfil
    from colaborador_perfil a
    where a.id_colaborador=:p_id_colaborador
    into :id_perfil do
  begin
    for
      select a.id_epi, b.epi, a.opcional, a.durabilidade, a.durabilidade_explicacao
      from perfil_epi a
      inner join epi b on (b.id_epi=a.id_epi)
      where a.id_perfil=:id_perfil
      order by b.epi
      into :id_epi, :epi, :opcional, :durabilidade, :durabilidade_explicacao do
      begin
        suspend;
      end
  end

end ^

ALTER PROCEDURE GET_QS (P_ID_COLABORADOR D_ROWID,
P_ID_EPI D_ROWID,
P_DT_DURAR_ATE D_DATA)
RETURNS (QS INTEGER)
AS 
declare variable lqtde_atual integer = 0;
declare variable lpartir_de date = '01.01.1970';
declare variable lstart_date date = '01.01.1970';
begin
  /* Retorna a quantidade necessária de um EPI para durar até determinada data */

  select qtde_atual, dt_vencimento from carteira
  where id_colaborador=:p_id_colaborador and id_epi=:p_id_epi
  into :lqtde_atual,:lpartir_de;

  if (:lpartir_de < current_date) then lpartir_de=current_date;
  lstart_date=:lpartir_de;
  qs=0;
  while (lstart_date <= :p_dt_durar_ate) do
  begin
    qs=:qs+1;
    select dt_vencimento FROM GET_VENCIMENTO(:p_id_colaborador,:p_id_epi,:lqtde_atual+:qs, :lpartir_de)
    into :lstart_date;
  end
  --if (:qs >0) then qs=:qs-1;
  suspend;
end ^

ALTER PROCEDURE GET_SE_DIA_UTIL (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR,
P_DATA D_DATA)
RETURNS (DIA_UTIL CHAR(1) CHARACTER SETISO8859_1 )
AS 
--declare variable l_temp_date date = current_date;
declare variable l_weekday integer = 0;
declare variable l_trab_seg d_resposta = 'N';
declare variable l_trab_ter d_resposta = 'N';
declare variable l_trab_qua d_resposta = 'N';
declare variable l_trab_qui d_resposta = 'N';
declare variable l_trab_sex d_resposta = 'N';
declare variable l_trab_sab d_resposta = 'N';
declare variable l_trab_dom d_resposta = 'N';
begin
  if (:p_id_colaborador>0) then
  begin
    if (not exists(select * from colaborador where id_colaborador=:p_id_colaborador)) then
    begin
      execute procedure SP_LOG  'GET_SE_DIA_UTIL',
        'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não existe.','S';
      suspend;
      exit;
    end
    /* Os dias que são uteis para esse colaborador */
    select trab_seg, trab_ter, trab_qua, trab_qui, trab_sex, trab_sab, trab_dom
    from colaborador
    where id_colaborador=:p_id_colaborador
    into :l_trab_seg, :l_trab_ter, :l_trab_qua, :l_trab_qui, :l_trab_sex, :l_trab_sab, :l_trab_dom;
  end
  else
  begin
    l_trab_seg='S';
    l_trab_ter='S';
    l_trab_qua='S';
    l_trab_qui='S';
    l_trab_sex='S';
    l_trab_sab='N';
    l_trab_dom='N';
  end

  if (
     (:l_trab_seg='N') and
     (:l_trab_ter='N') and
     (:l_trab_qua='N') and
     (:l_trab_qui='N') and
     (:l_trab_sex='N') and
     (:l_trab_sab='N') and
     (:l_trab_dom='N')
     ) then
  begin
    execute procedure SP_LOG  'GET_SE_DIA_UTIL',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não possui dias uteis.','S';
    suspend;
    exit;
  end 


  dia_util='S';

  l_weekday=extract(weekday from :p_data); -- 0 = Domingo
  if ((:l_weekday=0) and (:l_trab_dom='N')) then dia_util='N';
  if ((:l_weekday=1) and (:l_trab_seg='N')) then dia_util='N';
  if ((:l_weekday=2) and (:l_trab_ter='N')) then dia_util='N';
  if ((:l_weekday=3) and (:l_trab_qua='N')) then dia_util='N';
  if ((:l_weekday=4) and (:l_trab_qui='N')) then dia_util='N';
  if ((:l_weekday=5) and (:l_trab_sex='N')) then dia_util='N';
  if ((:l_weekday=6) and (:l_trab_sab='N')) then dia_util='N';
  /* observa a agenda publica */
  if (:dia_util='S') then
  begin
    if (
      exists(select * from AGENDA
      where id_colaborador=0 and
      :p_data between dt_inicial and dt_final)
      ) then  dia_util='N';
  end
  /* observa a agenda privada  */
  if ((:dia_util='S') and (:p_id_colaborador>0)) then
  begin
    if (
      exists(select * from AGENDA
      where id_colaborador=:p_id_colaborador and
       :p_data between dt_inicial and dt_final)
      ) then  dia_util='N';
  end

  /* Procedure Text */
  suspend;
end ^

ALTER PROCEDURE GET_SOMA_DIAS_UTEIS (P_ID_COLABORADOR TYPE OF COLUMN COLABORADOR.ID_COLABORADOR = 0,
P_DT_INICIO D_DATA = current_date,
P_QTDE_DIAS D_QUANTIDADE = 1)
RETURNS (RESULT_DATE DATE)
AS 
declare variable l_temp_date date = current_date;
declare variable l_dias_uteis integer = 0;
declare variable l_loops integer = 0;
declare variable l_se_util varchar(1);
begin
  /* Quando a data não é informada então utiliza a data em que o
     colaborador passou a trabalhar na empresa */
  if ((:p_id_colaborador>0)  and (:p_dt_inicio < '01.01.2000')) then
  begin
    select dt_inicio
    from colaborador
    where id_colaborador=:p_id_colaborador
    into :p_dt_inicio;
    execute procedure SP_LOG  'GET_SOMA_DIAS_UTEIS',
      'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') teve data inferior a 01.01.2000 então assumi '||
      cast(:p_dt_inicio as varchar(10))||' que foi o dia em que começou a trabalhar conosco.';
  end

  result_date=:p_dt_inicio;
  if (:p_qtde_dias <=0) then p_qtde_dias=1;
  l_dias_uteis=0;
  l_temp_date=dateadd(-1 day to :p_dt_inicio);

  while ((l_dias_uteis < :p_qtde_dias) and (:l_loops <= 36500)) do
  begin
    l_temp_date=dateadd(1 day to :l_temp_date);
    select dia_util from get_se_dia_util(:p_id_colaborador, :l_temp_date) into :l_se_util;
    if (:l_se_util='S') then l_dias_uteis=:l_dias_uteis+1;
    l_loops=:l_loops+1;
  end
  result_date=:l_temp_date;
  suspend;
end ^

ALTER PROCEDURE GET_USO_TABELAS RETURNS (TABELA VARCHAR(32) CHARACTER SETISO8859_1 ,
QUANTIDADE INTEGER)
AS 
declare variable stmt varchar(255);
begin
  FOR SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG = 0
  INTO :tabela DO
  BEGIN
    STMT = 'SELECT COUNT(*) FROM '|| TRIM(tabela);
    EXECUTE STATEMENT (STMT) INTO :quantidade;
    SUSPEND;
  END
end ^

ALTER PROCEDURE GET_VENCIMENTO (P_ID_COLABORADOR TYPE OF D_ROWID,
P_ID_EPI TYPE OF D_ROWID,
P_QUANTIDADE D_QUANTIDADE,
P_DT_INICIO D_DATA)
RETURNS (ID_PERFIL D_ROWID,
DT_VENCIMENTO DATE,
OPCIONAL CHAR(1) CHARACTER SETISO8859_1 ,
DURABILIDADE INTEGER,
DURABILIDADE_EXPLICACAO D_TEXTO,
PRORROGACAO_DIAS INTEGER,
PRORROGACAO_MAX_VEZES INTEGER)
AS 
declare variable l_next_id d_rowid = 0;
declare variable l_status varchar(1) = 'A';
declare variable l_temp_date date = current_date;
declare variable l_add d_resposta = 'N';
declare variable l_id_perfil type of column perfil.id_perfil = 0;
declare variable l_opcional char(1) = 'N';
declare variable l_durabilidade integer = 0;
declare variable l_durabilidade_explicacao d_texto = '';
declare variable l_prorrogacao_dias integer = 0;
declare variable l_prorrogacao_max_vezes integer = 0;
declare variable loops integer = 0;
declare variable ret_id_perfil d_rowid;
declare variable ret_dt_vencimento date;
declare variable ret_opcional char(1);
declare variable ret_durabilidade integer;
declare variable ret_durabilidade_explicacao d_texto;
declare variable ret_prorrogacao_dias integer;
declare variable ret_prorrogacao_max_vezes integer;
begin
  --dt_vencimento='01.01.1970';
  dt_vencimento='01.01.2000';
  id_perfil=0;
  durabilidade=0;
  durabilidade_explicacao='';
  prorrogacao_dias=0;
  prorrogacao_max_vezes=0;

  if ((:p_id_colaborador<=0) or (:p_id_epi<=0) ) then
  begin
    execute procedure SP_LOG  'GET_VENCIMENTO','O Colaborador '||cast(:p_id_colaborador as varchar(8))||' ou EPI '||cast(:p_id_epi as varchar(8))||') não foi informado !';
    suspend;
    exit;
  end
    if (not exists(select * from colaborador where id_colaborador=:p_id_colaborador)) then
  begin
    execute procedure SP_LOG  'GET_VENCIMENTO','O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não existe !','S';
    suspend;
    exit;
  end 

  if (not exists(select * from epi where id_epi=:p_id_epi)) then
  begin
    execute procedure SP_LOG  'GET_VENCIMENTO','O EPI ('||cast(:p_id_epi as varchar(8))||') não existe !';
    suspend;
    exit;
  end 

  if (not exists(select * from colaborador_perfil where id_colaborador=:p_id_colaborador)) then
  begin
    --exception ERR 'O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não possui nenhum perfil !';
    execute procedure SP_LOG  'GET_VENCIMENTO','O colaborador ('||cast(:p_id_colaborador as varchar(8))||') não possui nenhum perfil !';
    suspend;
    exit;
  end 


  /* valores padroes assumidos */
  ret_opcional='N';
  ret_durabilidade=365*10;
  ret_durabilidade_explicacao='Quando a durabilidade nao pode ser calculada corretamente pela falta de parametros o valor assumido é ';
  ret_durabilidade_explicacao=:durabilidade_explicacao||cast(:durabilidade as varchar(8))||' dias.';
  for
    select id_perfil
    from colaborador_perfil a
    where a.id_colaborador=:p_id_colaborador
    into :l_id_perfil do
  begin
    if (exists(select * from perfil_epi a where a.id_perfil=:l_id_perfil and a.id_epi=:p_id_epi)) then
    begin
      loops=:loops+1;
      select first 1 a.opcional, a.durabilidade, a.durabilidade_explicacao,
        a.prorrogacao_dias, a.prorrogacao_max_vezes
      from perfil_epi a
      where
        a.id_perfil=:l_id_perfil
        and a.id_epi=:p_id_epi
      order by a.durabilidade
      into :l_opcional, :l_durabilidade, :l_durabilidade_explicacao, :l_prorrogacao_dias,:l_prorrogacao_max_vezes;

      if (:l_durabilidade is null) then l_durabilidade=0;

      if ((:l_durabilidade < :ret_durabilidade)) then
      begin
        if (:l_durabilidade >0) then
        begin
          ret_id_perfil=:l_id_perfil;
          ret_opcional=:l_opcional;
          ret_durabilidade=:l_durabilidade;
          ret_durabilidade_explicacao=:l_durabilidade_explicacao;
          ret_prorrogacao_dias=:l_prorrogacao_dias;
          ret_prorrogacao_max_vezes=:l_prorrogacao_max_vezes;
        end
      end
    end
  end

  if (l_durabilidade = 0) then
  begin
    ret_id_perfil=:l_id_perfil;
    select opcional, durabilidade, durabilidade_explicacao, prorrogacao_dias, prorrogacao_max_vezes 
    from carteira
    where id_colaborador=:p_id_colaborador and id_epi=:p_id_epi
    into :l_opcional,:l_durabilidade,:l_durabilidade_explicacao,:l_prorrogacao_dias,:l_prorrogacao_max_vezes;    
    if (:l_durabilidade >0) then
    begin
      ret_id_perfil=:l_id_perfil;
      ret_opcional=:l_opcional;
      ret_durabilidade=:l_durabilidade;
      ret_durabilidade_explicacao=:l_durabilidade_explicacao;
      ret_prorrogacao_dias=:l_prorrogacao_dias;
      ret_prorrogacao_max_vezes=:l_prorrogacao_max_vezes;
    end
  end

  if (l_durabilidade = 0) then
  begin
    execute procedure SP_LOG  'GET_VENCIMENTO','O colaborador ('||cast(:p_id_colaborador as varchar(8))||')'||
      ' id_epi='||cast(:p_id_epi as varchar(8))||
      ' não encontrou a durabilidade !';
    suspend;
    exit;
  end

  id_perfil=:ret_id_perfil;
  opcional=:ret_opcional;
  durabilidade=:ret_durabilidade;
  durabilidade_explicacao=:ret_durabilidade_explicacao;
  prorrogacao_dias=:ret_prorrogacao_dias;
  prorrogacao_max_vezes=:ret_prorrogacao_max_vezes;

  if (:durabilidade=0) then
  begin
    execute procedure SP_LOG  'GET_VENCIMENTO',
      'Não foi possivel calcular durabilidade do EPI ['||
      cast(:p_id_epi as varchar(10))||'] do colaborador ['||
      cast(:p_id_colaborador as varchar(10))||'].';
    suspend;
    exit;
  end

  select result_date FROM GET_SOMA_DIAS_UTEIS (:p_id_colaborador,:p_dt_inicio,(:durabilidade*:p_quantidade))
  into :dt_vencimento;

  /* Procedure Text */
  suspend;
end ^

ALTER PROCEDURE SET_DESTRUIR_DADOS (P_CONFIRMACAO D_RESPOSTA)
AS 
begin
  if (:p_confirmacao <> 'S') then exit;

  delete from parametros;
  delete from agenda;
  --delete from ca_movtos;
  delete from colaborador_perfil;
  delete from colaborador_perfil_movtos;
  delete from perfil_epi;
  delete from perfil;
  delete from ca;
  delete from epi;
  delete from colaborador;
  execute procedure SP_LOG  'SET_DESTRUIR_DADOS', 'Usuario destruiu os dados.';
end ^

ALTER PROCEDURE SP_AGENDA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_AGENDA D_ROWID = 0,
P_ID_COLABORADOR D_ROWID = 0,
P_DT_INICIAL D_DATA = current_date,
P_DT_FINAL D_DATA = current_date,
P_DESCRICAO D_TEXTO = '',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_status varchar(1) = '';
declare variable l_id_colaborador d_rowid = 0;
declare variable l_next d_rowid = 0;
declare variable l_dt_inicial d_data = current_date;
declare variable l_dt_final d_data = current_date;
declare variable l_permitido integer = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end

  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='AGENDA' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_AGENDA','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end

  l_id_colaborador=:p_id_colaborador;

  if (:p_acao='INCLUIR') then
  begin
    select coalesce(max(id_agenda),0) from agenda into :l_next;
    l_next=:l_next+1;
    insert into agenda(
      id_agenda,
      id_colaborador,
      dt_inicial,
      dt_final,
      descricao,
      last_update,
      last_owner,
      status)
    values(
      :l_next,
      :p_id_colaborador,
      :p_dt_inicial,
      :p_dt_final,
      :p_descricao,
      current_timestamp,
      current_user,
      'A');

    /* recalcula todas as devoluções programadas */
    execute procedure sp_recalcular (:p_dt_inicial,:p_dt_final,:l_id_colaborador) returning_values :result_value;

    result_value=1;
  end

  if (:p_acao in ('ALTERAR','EXCLUIR')) then
  begin
    select dt_inicial, dt_final, status from agenda
    where id_agenda=:p_id_agenda
    into :l_dt_inicial, :l_dt_final, :l_status;
    if (:l_status = 'F') then
    begin
      exception ERR 'Esse agendamento encontra-se [Permanente], isso quer dizer que não pode ser modificado porque já está em uso !';
      suspend;
      exit;
     end
  end

  if (:p_acao='ALTERAR') then
  begin
    update agenda
    set descricao=:p_descricao,
        dt_inicial=:p_dt_inicial,
        dt_final=:p_dt_final,
        last_update=current_timestamp,
        last_owner=current_user,
        status=:p_status
    where id_agenda=:p_id_agenda;
    /* recalcula todas as devoluções programadas */
    if ((:p_dt_inicial<>:l_dt_inicial) or (:p_dt_final<>:l_dt_final))  then
    begin
      execute procedure sp_recalcular (:l_dt_inicial,:l_dt_final,:l_id_colaborador) returning_values :result_value;
    end
    result_value=1;
  end

  if (:p_acao='EXCLUIR') then
  begin
    delete from agenda
    where id_agenda=:p_id_agenda and status<>'F';
    /* recalcula todas as devoluções programadas */
    execute procedure sp_recalcular (:l_dt_inicial,:l_dt_final,:l_id_colaborador) returning_values :result_value;
  end
  suspend;
end ^

ALTER PROCEDURE SP_CA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_CA D_ROWID,
P_ID_EPI D_ROWID = 0,
P_VL_MEDIO D_VALOR2 = 0,
P_VALIDO_ATE D_DATA = '2012-01-01',
P_DESCRICAO D_TEXTO = '',
P_APROVADO_PARA D_TEXTO = '',
P_CA_SIMILAR D_RESPOSTA = 'N',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_valido_ate d_data = '1970-01-01';
declare variable l_status char(1) = 'A';
declare variable l_id_epi d_rowid = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  if (:p_acao='INCLUIR') then
  begin
    if (exists(select * from ca where id_ca=:p_id_ca and id_epi=:p_id_epi)) then
    begin
      exception ERR 'O CA '||cast(:p_id_ca as varchar(10))||' já foi associado a este epi !';
      suspend;
      exit;
    end

    insert into ca(id_ca,id_epi,vl_medio,valido_ate,descricao,aprovado_para,ca_similar, last_update, last_owner, status)
    values(:p_id_ca,:p_id_epi,:p_vl_medio,:p_valido_ate, :p_descricao, :p_aprovado_para, :p_ca_similar, current_timestamp,current_user,'A') ;
    result_value=1;
  end


  if (:p_acao='ALTERAR') then
  begin
    select id_epi, valido_ate, status from ca
    where id_ca=:p_id_ca
    into l_id_epi, :l_valido_ate, :l_status;
    if ((:p_status<>:l_status) and (:l_status='C')) then
    begin
      if ( exists(select * from ca where id_ca=:p_id_ca and status ='A' )) then
      begin
        exception ERR 'O CA '||cast(:p_id_ca as varchar(10))||' está em uso por colaboradores !';
        suspend;
        exit;
      end
    end

    /* Se voce mudar o numero do CA, o sistema o bloqueará se o mesmo já está em uso */
    if ((:p_id_epi<>:l_id_epi)) then
    begin
      if ( exists(select * from ca_movtos where id_ca=:p_id_ca)) then
      begin
        exception ERR 'O epi do CA '||cast(:p_id_ca as varchar(10))||' não pode ser modificado porque já há registros de sua movimentação !';
        suspend;
        exit;
        --delete from ca_movtos_old where id_ca=:p_id_ca;
      end
    end

    update ca
    set id_epi=:p_id_epi,
        vl_medio=:p_vl_medio,
        valido_ate=:p_valido_ate,
        descricao=:p_descricao,
        aprovado_para=:p_aprovado_para,
        ca_similar=:p_ca_similar,
        last_update=current_timestamp,
        last_owner=current_user,
        status=:p_status
    where id_ca=:p_id_ca;
    if (:p_valido_ate<>:l_valido_ate) then
    begin
      /* recalcula todas as devoluções programadas */
      if (:l_valido_ate > :p_valido_ate) then l_valido_ate=:p_valido_ate;
      execute procedure sp_recalcular ('2000-01-01',current_date) returning_values :result_value;
    end
    result_value=1;
  end
  if (:p_acao='EXCLUIR') then
  begin
    /* if (exists(select * from ca_movtos where id_ca=:p_id_ca)) then
    begin
      exception ERR 'Não pode excluir um CA que já possui movimentação !';
      suspend;
      exit;
    end */

    delete from ca_movtos
    where id_ca=:p_id_ca;

    --delete from ca_movtos_prorrogacao
    --where id_ca=:p_id_ca;

    delete from ca
    where id_ca=:p_id_ca;
  end
  suspend;
end ^

ALTER PROCEDURE SP_CARTEIRA (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (RESULT_VALUE BIGINT)
AS 
declare variable l_id_carteira d_rowid = 0;
declare variable l_id_epi d_rowid = 0;
declare variable l_opcional type of column perfil_epi.opcional;
declare variable l_durabilidade type of column perfil_epi.durabilidade;
declare variable l_durabilidade_explicacao type of column perfil_epi.durabilidade_explicacao;
declare variable l_prorrogacao_dias type of column perfil_epi.prorrogacao_dias;
declare variable l_prorrogacao_max_vezes type of column perfil_epi.prorrogacao_max_vezes;
declare variable l_next_id d_rowid = 0;
begin
  result_value=0;
  if (:p_acao not in ('RECALCULAR','INCLUIR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  if (:p_acao in ('RECALCULAR','INCLUIR')) then
  begin
    /* criando o CARTEIRA de itens que o colaborador pode possuir */
    for select
       b.id_epi,
       b.opcional,
       b.durabilidade,
       b.durabilidade_explicacao,
       b.prorrogacao_dias,
       b.prorrogacao_max_vezes
   from colaborador_perfil a
   inner join perfil_epi b on (a.id_perfil=b.id_perfil)
   where a.id_colaborador=:p_id_colaborador
   into
       :l_id_epi,
       :l_opcional,
       :l_durabilidade,
       :l_durabilidade_explicacao,
       :l_prorrogacao_dias,
       :l_prorrogacao_max_vezes do
    begin
      l_next_id=0;
      select coalesce(id_carteira,0) from carteira
      where id_colaborador=:p_id_colaborador and id_epi=:l_id_epi
      into :l_next_id;

      if  ((:l_next_id is null) or (:l_next_id=0))   then
      begin
        select coalesce(max(id_carteira),0) from carteira
        into :l_next_id;
        if (:l_next_id is null) then l_next_id=0;
        l_next_id=:l_next_id+1;
      end

      update or insert into carteira(
          id_carteira,
          id_colaborador,
          id_epi,
          qtde_atual,
          dt_primeiro_recebimento,
          dt_ultimo_recebimento,
          dt_ultima_prorrogacao,
          dt_vencimento,
          opcional,
          durabilidade,
          durabilidade_explicacao,
          prorrogacao_dias,
          prorrogacao_max_vezes,
          last_update,
          last_owner)
      values(
          :l_next_id,
          :p_id_colaborador,
          :l_id_epi,
          0,
          '01.01.1970', -- dt_primeiro_recebimento
          '01.01.1970', -- dt_ultimo_Recebimento
          '01.01.1970', -- dt_ultima_prorrogacao
          '01.01.1970', -- dt_vencimento
          :l_opcional,
          :l_durabilidade,
          :l_durabilidade_explicacao,
          :l_prorrogacao_dias,
          :l_prorrogacao_max_vezes,
          current_timestamp,
          current_user
         )
         matching(id_carteira);
      execute procedure SP_CARTEIRA_RECALC_ITEM (:p_id_colaborador,:l_id_epi)
         returning_values :result_value;
    end
  end

  if (:p_acao = 'RECALCULAR') then
  begin
    for
      select id_carteira, id_epi from carteira
      where id_colaborador=:p_id_colaborador
      into :l_id_carteira, :l_id_epi do
    begin
      execute procedure sp_carteira_recalc_item (:p_id_colaborador,:l_id_epi)
         returning_values :result_value;
    end
    -- removendo itens que o colaborador nao possua mais e nem tenha
    --   perfil que indique em usa-la
    for
      select id_carteira, id_epi from carteira
      where id_colaborador=:p_id_colaborador and qtde_atual<=0
      into :l_id_carteira, :l_id_epi do
    begin
      if (not exists(
           select * from colaborador_perfil a
           inner join perfil_epi b on (a.id_perfil=b.id_perfil)
           where id_colaborador=:p_id_colaborador and b.id_epi=:l_id_epi
      )) then
      begin
        delete from carteira where id_carteira=:l_id_carteira;
      end
    end
  end

  if (:p_acao = 'EXCLUIR') then
  begin
    delete from carteira where id_colaborador=:p_id_colaborador;
    result_value=1;
  end

  suspend;
end ^

ALTER PROCEDURE SP_CARTEIRA_RECALC_ITEM (P_ID_COLABORADOR D_ROWID = 0,
P_ID_EPI D_ROWID = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable lid_carteira d_rowid = 0;
declare variable lid_ca d_rowid = 0;
declare variable ldt_vencimento d_data = '01.01.1970';
declare variable ldt_primeiro_recebimento d_data = '01.01.1970';
declare variable ldt_ultimo_recebimento d_data = '01.01.1970';
declare variable lca_valido_ate d_data = '01.01.1970';
declare variable lqtde_em_maos d_quantidade = 0;
declare variable ldurabilidade_total integer = 0;
declare variable lid_prorrogacao d_rowid = 0;
declare variable lmulti_ca integer = 0;
declare variable ldt_saida d_data = '01.01.1970';
declare variable ldurabilidade integer = 0;
begin
  result_value=0;
  if ((:p_id_colaborador <=0) or (:p_id_epi<=0)) then
  begin
    exception ERR 'Parametros invalidos para SP_CARTEIRA_RECALC_ITEM !';
    suspend;
    exit;
  end

  -- Será que há mais de um CA para o mesmo EPI ?
  lmulti_ca=0;
  select count(distinct id_ca) from ca_movtos a
  where (a.id_colaborador=:p_id_colaborador) and
        (a.id_epi=:p_id_epi) and
        (status='A')
  into :lmulti_ca;

  select a.id_carteira, dt_ultimo_recebimento from carteira a
  where a.id_colaborador=:p_id_colaborador and a.id_epi=:p_id_epi
  into :lid_carteira, :ldt_ultimo_recebimento ;

  -- Procurando saber o primeiro e mais antigo CA
  select first 1 a.id_ca from ca_movtos a
  where a.id_colaborador=:p_id_colaborador and a.id_epi=:p_id_epi and status='A'
  order by dt_saida
  into :lid_ca;

  ldurabilidade_total=0;
  ldt_vencimento='01.01.1970';
  lqtde_em_maos=0;
  ldt_primeiro_recebimento='01.01.1970';
  ldt_ultimo_recebimento='01.01.1970';
  ldurabilidade_total=0;
  for
    select a.dt_saida, durabilidade from ca_movtos a
    where (a.id_colaborador=:p_id_colaborador) and
          (a.id_epi=:p_id_epi) and
          (a.status='A')
    order by a.dt_saida
    into :ldt_saida, :ldurabilidade do
  begin
    if (:ldt_primeiro_recebimento = '01.01.1970') then ldt_primeiro_recebimento=:ldt_saida;
    ldt_ultimo_recebimento=:ldt_saida;
    lqtde_em_maos=:lqtde_em_maos+1;
    if (:ldurabilidade=0) then
    begin
      select durabilidade from get_vencimento(:p_id_colaborador,:p_id_epi,1,:ldt_ultimo_recebimento)
      into :ldurabilidade;
    end
    ldurabilidade_total=:ldurabilidade_total+:ldurabilidade;
  end
  if ((:ldt_ultimo_recebimento is null) or
     (:ldt_ultimo_recebimento < '01.01.2000'))
  then ldt_ultimo_recebimento=:ldt_primeiro_recebimento;

  -- calculando o vencimento
  select dt_vencimento from get_vencimento(:p_id_colaborador,:p_id_epi,:lqtde_em_maos,:ldt_primeiro_recebimento)
  into :ldt_vencimento;

  /* Se o vencimento calculado for superior ao vencimento do CA, então vale o do CA
     Se o EPI tiver varios CAs entao vale o CA com vencimento menor */
  if (lmulti_ca=0) then
  begin
    select min(a.valido_ate) from ca a
    inner join epi b on (b.id_epi=a.id_epi)
    where b.id_epi=:p_id_epi
    into :lca_valido_ate;

    if (:lca_valido_ate < :ldt_vencimento) then
    begin
      ldt_vencimento=:lca_valido_ate;
    end
  end
  /* As vezes, o operador dá baixa num epi de um CA mais recente e nao dá baixa num CA mais antigo
     quando isso ocorre, a data de vencimento parte do CA mais antigo e assim o vencimento sai errado
     Se isso acontecer, o sistema inverte a passa a contar o vencimento a partir do ultimo vencimento
   */
  if (:ldt_vencimento < :ldt_ultimo_recebimento) then
  begin
    select dt_vencimento from get_vencimento(:p_id_colaborador,:p_id_epi,:lqtde_em_maos,:ldt_ultimo_recebimento)
    into :ldt_vencimento;
  end

  /* atualizando o CARTEIRA */
  update CARTEIRA
  set qtde_atual=:lqtde_em_maos,
      dt_primeiro_recebimento=:ldt_primeiro_recebimento,
      dt_ultimo_recebimento=:ldt_ultimo_recebimento,
      dt_vencimento=:ldt_vencimento,
      last_update=current_timestamp,
      last_owner=current_user
  where id_carteira=:lid_carteira;

  update ca_movtos
  set dt_vencimento=:ldt_vencimento
  where (id_colaborador=:p_id_colaborador) and (id_epi=:p_id_epi) and (status='A');

  /* Atualiza log de prorrogacoes que estavam sem data de vencimento */
  for
    select a.id_prorrogacao
    from ca_movtos_prorrogacao a
    inner join ca_movtos  b on (b.id_movto=a.id_movto)
    where b.id_colaborador=:p_id_colaborador and b.id_epi=:p_id_epi and b.dt_vencimento='01.01.1970'
    into :lid_prorrogacao do
  begin
    update ca_movtos_prorrogacao
    set    dt_vencimento_depois=:ldt_vencimento,
           last_update=current_timestamp,
           last_owner=current_user
    where  id_prorrogacao=:lid_prorrogacao and dt_vencimento_depois='01.01.1970';
  end

  result_value=:lid_carteira;

  suspend;
end ^

ALTER PROCEDURE SP_COLABORADOR (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID,
P_NOME_COMPLETO D_NOME_COMPLETO = '',
P_RG D_RG = '',
P_DT_INICIO D_DATA = current_date,
P_TRAB_SEG D_RESPOSTA = 'n',
P_TRAB_TER D_RESPOSTA = 'n',
P_TRAB_QUA D_RESPOSTA = 'n',
P_TRAB_QUI D_RESPOSTA = 'n',
P_TRAB_SEX D_RESPOSTA = 'n',
P_TRAB_SAB D_RESPOSTA = 'n',
P_TRAB_DOM D_RESPOSTA = 'n',
P_STATUS D_STATUS = 'a')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_trab_seg d_resposta = 'N';
declare variable l_trab_ter d_resposta = 'N';
declare variable l_trab_qua d_resposta = 'N';
declare variable l_trab_qui d_resposta = 'N';
declare variable l_trab_sex d_resposta = 'N';
declare variable l_trab_sab d_resposta = 'N';
declare variable l_trab_dom d_resposta = 'N';
declare variable l_dt_criacao d_data = current_date;
declare variable l_dt_inicio d_data = current_date;
declare variable l_next d_rowid = 0;
declare variable l_permitido integer = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='COLABORADOR' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_COLABORADOR','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end
  if (:p_acao in ('INCLUIR','ALTERAR')) then
  begin
    if ((:p_trab_seg='N') and
        (:p_trab_ter='N') and
        (:p_trab_qua='N') and
        (:p_trab_qui='N') and
        (:p_trab_sex='N') and
        (:p_trab_sab='N') and
        (:p_trab_dom='N')) then
    begin
      exception ERR 'Colaborador ('||:p_nome_completo||') precisa trabalhar em algum dia da semana !';
      suspend;
      exit;
    end
  end
  if (:p_acao='INCLUIR') then
  begin
    select coalesce(max(id_colaborador),0)+1 from colaborador
    into :l_next;
    update or insert into colaborador(
      id_colaborador,
      nome_completo,
      rg,
      dt_criacao,
      dt_inicio,
      trab_seg,
      trab_ter,
      trab_qua,
      trab_qui,
      trab_sex,
      trab_sab,
      trab_dom,
      last_update,
      last_owner,
      status)
    values(
      :l_next,
      :p_nome_completo,
      :p_rg,
      :p_dt_inicio, 
      current_date,
      :p_trab_seg,
      :p_trab_ter,
      :p_trab_qua,
      :p_trab_qui,
      :p_trab_sex,
      :p_trab_sab,
      :p_trab_dom,
      current_timestamp,
      current_user,
      'A')
    matching(id_colaborador) ;
    result_value=:l_next;
  end
  if (:p_acao='ALTERAR') then
  begin
    select dt_criacao, dt_inicio, trab_seg,trab_ter,trab_qua,trab_qui,trab_sex,trab_sab,trab_dom
    from colaborador
    where id_colaborador=:p_id_colaborador
    into :l_dt_criacao,:l_dt_inicio, :l_trab_seg,:l_trab_ter,:l_trab_qua,:l_trab_qui,:l_trab_sex,:l_trab_sab,:l_trab_dom;

    update colaborador
    set nome_completo=:p_nome_completo,
        rg=:p_rg,
        trab_seg=:p_trab_seg,
        trab_ter=:p_trab_ter,
        trab_qua=:p_trab_qua,
        trab_qui=:p_trab_qui,
        trab_sex=:p_trab_sex,
        trab_sab=:p_trab_sab,
        trab_dom=:p_trab_dom,
        last_update=current_timestamp,
        last_owner=current_user,
        status=:p_status
    where id_colaborador=:p_id_colaborador;

    /* recalcula todas as devoluções programadas desse colaborador
    caso sua programação de dias uteis tenha sido alterada */
    if (
        (:p_trab_seg<>:l_trab_seg) or
        (:p_trab_ter<>:l_trab_ter) or
        (:p_trab_qua<>:l_trab_qua) or
        (:p_trab_qui<>:l_trab_qui) or
        (:p_trab_sex<>:l_trab_sex) or
        (:p_trab_sab<>:l_trab_sab) or
        (:p_trab_dom<>:l_trab_dom)
        ) then
    begin
      execute procedure sp_recalcular (:l_dt_criacao,current_date,:p_id_colaborador) returning_values :result_value;
    end
    result_value=1;
  end
  if (:p_acao='EXCLUIR') then
  begin
    if (exists(select * from colaborador_perfil where id_colaborador=:p_id_colaborador)) then
    begin
      exception ERR 'Não pode excluir um colaborador que estiver associado a um perfil !';
      suspend;
      exit;
    end
    if (exists(select * from ca_movtos where id_colaborador=:p_id_colaborador)) then
    begin
      exception ERR 'Não pode excluir um colaborador que possui movimentação de CAs !';
      suspend;
      exit;
    end
    if (exists(select * from agenda where id_colaborador=:p_id_colaborador and status<>'A')) then
    begin
      exception ERR 'Não pode excluir um colaborador que possui agendamentos executados para ele !';
      suspend;
      exit;
    end
    if (exists(select * from colaborador_perfil_movtos where id_colaborador=:p_id_colaborador and dt_inicio<>dt_termino)) then
    begin
      exception ERR 'Não pode excluir um colaborador que possui movimentação de Perfis !';
      suspend;
      exit;
    end

    delete from ca_movtos
    where id_colaborador=:p_id_colaborador;

    delete from colaborador_perfil_movtos
    where id_colaborador=:p_id_colaborador;

    delete from agenda
    where id_colaborador=:p_id_colaborador;

    delete from colaborador_perfil
    where id_colaborador=:p_id_colaborador;

    delete from colaborador
    where id_colaborador=:p_id_colaborador;
  end
  suspend;
end ^

ALTER PROCEDURE SP_COLABORADOR_PERFIL (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_COLABORADOR D_ROWID,
P_ID_PERFIL D_PERFIL)
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_dt_inicio d_data = '1970-01-01';
declare variable l_epi d_epi = '';
declare variable l_durabilidade d_durabilidade = 0;
declare variable l_epi_utilizados varchar(4096) = '';
declare variable l_opcional varchar(1) = 'N';
declare variable l_next_id d_rowid = 0;
declare variable l_id_perfil_movtos d_rowid = 0;
declare variable l_permitido integer = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end

  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='COLABORADOR_PERFIL' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_COLABORADOR_PERFIL','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end

  if ((:p_id_perfil=0) or (:p_id_colaborador=0) ) then
  begin
    exception ERR 'Associação de colaborador e perfil inválida !';
    suspend;
    exit;
  end

  if (:p_acao='INCLUIR') then
  begin
    insert into colaborador_perfil(id_colaborador,id_perfil)
    values(:p_id_colaborador,:p_id_perfil) ;
    select coalesce(max(id_perfil_movtos),0)+1 from colaborador_perfil_movtos
    into :l_next_id;
    insert into colaborador_perfil_movtos (
      id_perfil_movtos,
      id_colaborador,
      id_perfil,
      dt_inicio,
      dt_termino,
      epi_utilizados,
      last_update,
      last_owner,
      status)
    values(
      :l_next_id,
      :p_id_colaborador,
      :p_id_perfil,
      current_date,
      '1970-01-01',
      '',
      current_timestamp,
      current_user, 
      'A');

    /* recalcula todas as devoluções programadas desse colaborador */
    execute procedure sp_recalcular ('2000-01-01',current_date,:p_id_colaborador) returning_values :result_value;

    result_value=1;
  end
  if (:p_acao='EXCLUIR') then
  begin
    select id_perfil_movtos, dt_inicio from colaborador_perfil_movtos
    where id_colaborador=:p_id_colaborador and
          id_perfil=:p_id_perfil and
          status='A'
    into :l_id_perfil_movtos, :l_dt_inicio;

    if (:l_dt_inicio < '2000-01-01') then
    begin
      exception ERR 'Não achei o inicio de uso do perfil ['||:p_id_perfil||'] !';
      suspend;
      exit;
    end

    l_epi_utilizados='';
    for
      select b.epi,
             a.durabilidade,
             a.opcional
      from perfil_epi a
      inner join epi b on (b.id_epi=a.id_epi)
      where id_perfil=:p_id_perfil
    into :l_epi, :l_durabilidade, :l_opcional do
    begin
      l_epi_utilizados=l_epi_utilizados||:l_epi||',dur='||cast(:l_durabilidade as varchar(8));
      if (:l_opcional='S')
      then l_epi_utilizados=l_epi_utilizados||:l_epi||',opcional';
    end

    update colaborador_perfil_movtos
    set dt_termino=current_date,
        epi_utilizados=:l_epi_utilizados,
        last_update=current_timestamp,
        last_owner=current_user,
        status='C'
    where (id_perfil_movtos=:l_id_perfil_movtos);

    delete from colaborador_perfil
    where id_colaborador=:p_id_colaborador and id_perfil=:p_id_perfil;

    /* recalcula todas as devoluções programadas desse colaborador */
    execute procedure sp_recalcular ('2000-01-01',current_date,:p_id_colaborador) returning_values :result_value;
  end
  suspend;
end ^

ALTER PROCEDURE SP_EPI (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_EPI TYPE OF COLUMN EPI.ID_EPI = 0,
P_EPI TYPE OF COLUMN EPI.EPI = '',
P_VL_MEDIO TYPE OF COLUMN EPI.VL_MEDIO = 0,
P_STATUS D_STATUS = 'a')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_next d_rowid = 0 ;
declare variable l_permitido integer = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='EPI' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_EPI','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end

  if (:p_acao='INCLUIR') then
  begin
    select coalesce(max(id_epi),0)+1 from epi
    into :l_next;
    insert into epi(id_epi,epi, vl_medio, last_update,last_owner,status)
    values(:l_next,:p_epi, :p_vl_medio, current_timestamp, current_user,'A');
    result_value=:l_next;
  end
  if (:p_acao='ALTERAR') then
  begin
    update epi
    set epi=:p_epi,
        vl_medio=:p_vl_medio,
        last_update=current_timestamp,
        last_owner=current_user,
        status=:p_status
    where id_epi=:p_id_epi;
    result_value=:p_id_epi;
  end
  if (:p_acao='EXCLUIR') then
  begin
    if (exists(select * from perfil_epi where id_epi=:p_id_epi)) then
    begin
      exception ERR 'Não pode excluir um epi que estiver associado a um perfil !';
      suspend;
      exit;
    end
    if (exists(select * from ca where id_epi=:p_id_epi)) then
    begin
      exception ERR 'Não pode excluir um epi que estiver associado a um Certificado Aprovado !';
      suspend;
      exit;
    end
    delete from epi where id_epi=:p_id_epi;
    result_value=:p_id_epi;
  end
  suspend;
end ^

ALTER PROCEDURE SP_LOG (P_CONTEXTO TYPE OF COLUMN LOG_ERRORS.CONTEXTO,
P_DESCRICAO TYPE OF COLUMN LOG_ERRORS.DESCRICAO,
P_FATAL VARCHAR(1) CHARACTER SETISO8859_1  = 'N')
AS 
declare variable l_next_id d_rowid = 0;
begin
  select coalesce(max(id),0) from log_errors
  into :l_next_id;
  if (:l_next_id is null) then l_next_id=0;
  l_next_id=:l_next_id+1;
  insert into log_errors(id,contexto,descricao,fatal,last_update,last_owner)
  values(:l_next_id,:p_contexto,:p_descricao,:p_fatal,current_timestamp,current_user);
  if (:p_fatal='S') then
  begin
    exception ERR :p_descricao||'['||:p_contexto||']';
  end
end ^

ALTER PROCEDURE SP_MOVTO_DEVOLVER (PID_CA D_ROWID,
PID_COLABORADOR D_ROWID,
PDT_RETORNO D_DATA,
PTIPO_RETORNO D_TIPO_RETORNO,
PQUANTIDADE D_QUANTIDADE = 0,
PDIAS_USUFRUTO D_QUANTIDADE = 0,
PNOVA_RETIRADA_ID_CA D_ROWID = 0,
PNOVA_RETIRADA_QUANTIDADE D_QUANTIDADE = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable lid_movto bigint = 0;
declare variable lid_movto_prorrogado d_rowid = 0;
declare variable lprorrogacao_dias integer = 0;
declare variable lprorrogacao_max_vezes integer = 0;
declare variable lprorrogacao_realizadas integer = 0;
declare variable ldt_ultima_prorrogacao d_data = '01.01.1970';
declare variable ldt_vencimento_antes d_data = '01.01.1970';
declare variable ldt_vencimento_depois d_data = '01.01.1970';
declare variable lqtde_em_posse bigint = 0;
declare variable lid_epi d_rowid = 0;
declare variable ldt_saida d_data = '01.01.1970';
declare variable lopcional char(1) = 'N';
declare variable ldurabilidade integer = 0;
declare variable ldurabilidade_explicacao d_texto = '';
declare variable loops integer = 0;
declare variable llote d_rowid = 0;
begin
  result_value=0;
  if ((:pid_ca <= 0) or (:pid_colaborador<=0))  then
  begin
    execute procedure sp_log 'SP_MOVTO_DEVOLVER', 'Faltam especificar os parametros corretamente.','S';
    suspend;
    exit;
  end

  if (:ptipo_retorno in ('EXPIRADOS','PRORROGADOS')) then pdias_usufruto=0;

  select count(*) as ncount
  from ca_movtos a
  where a.id_colaborador=:pid_colaborador and a.id_ca=:pid_ca and a.status='A'
  into :lqtde_em_posse;

  if (:lqtde_em_posse=0) then
  begin
    exception ERR 'O colaborador recebeu não possui itens do CA '||cast(:pid_ca as varchar(8))||'!';
    suspend;
    exit;
  end

  if (:pquantidade>:lqtde_em_posse) then
  begin
    exception ERR 'O colaborador recebeu do CA '||cast(:pid_ca as varchar(8))||
      'apenas '||cast(:lqtde_em_posse as varchar(8))||
      'e você não pode devolver '||cast( :pquantidade as varchar(8))||'!';
    suspend;
    exit;
  end

  -- Descobrindo o epi desse CA
  select a.id_epi from ca a
  where a.id_ca=:pid_ca
  into :lid_epi;

  select a.prorrogacao_realizadas, a.dt_ultima_prorrogacao, dt_vencimento,
    prorrogacao_max_vezes, prorrogacao_dias,opcional,durabilidade
  from carteira a
  where id_colaborador=:pid_colaborador and id_epi=:lid_epi
  into :lprorrogacao_realizadas,:ldt_ultima_prorrogacao,:ldt_vencimento_antes,
       :lprorrogacao_max_vezes,:lprorrogacao_dias,:lopcional,:ldurabilidade;
  -- Sera que pode aceitar itens expirados
  if (:ptipo_retorno = 'EXPIRADOS') then
  begin
    if (:pdt_retorno <:ldt_vencimento_antes) then
    begin
      execute procedure sp_log 'SP_MOVTO_DEVOLVER', 'Itens expirados só podem ser devolvidos quando expira(óbvio) seu vencimento.','S';
      suspend;
      exit;
    end
  end
  -- Sera que pode prorrogar ?
  if (:ptipo_retorno = 'PRORROGADOS') then
  begin
    if (:lprorrogacao_max_vezes=0) then lprorrogacao_max_vezes=999;
    if (:lprorrogacao_max_vezes<=0) then
    begin
      exception err 'Não é possivel prorrogar, para esse item não há prorrogação de vencimento!';
      suspend;
      exit;
    end

    if (:lprorrogacao_realizadas>=:lprorrogacao_max_vezes) then
    begin
      exception err 'Não é possivel prorrogar, a quantidade máxima foi alcançada!';
      suspend;
      exit;
    end

    -- Faz a entrega de um EPI com durabilidade menor
    --ldt_ultima_prorrogacao=:pdt_retorno;
    --lprorrogacao_realizadas=:lprorrogacao_realizadas+1;
  end

  loops=0;
  while (:loops < :pquantidade) do
  begin
    loops=:loops+1;
    select coalesce(min(a.id_movto),0)
    from ca_movtos a
    where (id_colaborador=:pid_colaborador) and
          (id_ca=:pid_ca) and
          (a.status='A')
    into :lid_movto;
  
    if (:lid_movto <=0) then
    begin
      exception ERR 'Este CA '||cast(:pid_ca as varchar(8))||' não foi retirado por este colaborador!';
      suspend;
      exit;
    end
  
    -- Descobrindo quando o item que vou dar baixa saiu
    select a.dt_saida, a.lote from ca_movtos a
    where id_movto=:lid_movto
    into :ldt_saida, :llote;

    -- Dados sobre possivel prorrogação
    select prorrogacao_dias,prorrogacao_max_vezes,opcional,durabilidade,durabilidade_explicacao
    from GET_VENCIMENTO(:pid_colaborador,:lid_epi,1,:pdt_retorno)
    into :lprorrogacao_dias, :lprorrogacao_max_vezes,:lopcional,:ldurabilidade,:ldurabilidade_explicacao;

    if (:ptipo_retorno in ('PERDIDOS','DANIFICADOS')) then
    begin
     if (:pdias_usufruto > 0)
     then ldurabilidade=:pdias_usufruto;
    end
  
    -- qualquer dia não util que houver no meio entre a data da saida e data do
    -- vencimento torna-se um dia não util permanente, impossivel de ser excluído
    update agenda
    set status='F'
    where (dt_inicial >= :ldt_saida) and (dt_final <= :pdt_retorno) and (status='A');
  
    update ca_movtos
    set dt_retorno=:pdt_retorno,
        dt_vencimento=:ldt_vencimento_antes,
        durabilidade=:ldurabilidade,
        tipo_retorno=:ptipo_retorno,
        last_update=current_timestamp,
        last_owner=current_user,
        status='F'
    where (id_movto=:lid_movto);
  
    result_value=:lid_movto;

    if (:ptipo_retorno = 'PRORROGADOS') then -- 'PRORROGADOS','EXPIRADOS','PERDIDOS','DANIFICADOS'
    begin
      -- Faz a entrega de um EPI com durabilidade menor
      ldt_ultima_prorrogacao=:pdt_retorno;
      lprorrogacao_realizadas=:lprorrogacao_realizadas+1;
      execute procedure  sp_movto_entregar(:pid_ca,:pid_colaborador,1,:pdt_retorno,'N') returning_values :lid_movto_prorrogado;
      if (:lid_movto_prorrogado > 0) then
      begin
        -- altera a durabilidade a menor
        update ca_movtos
        set durabilidade=:lprorrogacao_dias
        where (id_movto=:lid_movto_prorrogado);
    
        -- Registra na tabela de historico essa prorrogacao
        UPDATE OR INSERT INTO CA_MOVTOS_PRORROGACAO(
               ID_PRORROGACAO,
               ID_MOVTO,
               DT_VENCIMENTO_ANTES,
               DT_VENCIMENTO_DEPOIS,
               LAST_UPDATE,
               LAST_OWNER)
        VALUES(
               :lid_movto_prorrogado,
               :lid_movto,
               :ldt_vencimento_antes,
               '01.01.1970',  -- DT_VENCIMENTO_DEPOIS
               current_timestamp,
               current_user);
        result_value=:lid_movto_prorrogado;
      end
    end
  end --loops de quantidade

  -- Atualizando a carteira
  update carteira
  set qtde_atual=qtde_atual-:pquantidade,
      dt_ultimo_recebimento=:pdt_retorno,
      opcional=:lopcional,
      durabilidade=:ldurabilidade,
      durabilidade_explicacao=:ldurabilidade_explicacao,
      dt_ultima_prorrogacao=:ldt_ultima_prorrogacao,
      prorrogacao_dias=:lprorrogacao_dias,
      prorrogacao_max_vezes=:lprorrogacao_max_vezes,
      prorrogacao_realizadas=:lprorrogacao_realizadas,
      last_update=current_timestamp,
      last_owner=current_user
  where id_colaborador=:pid_colaborador and id_epi=:lid_epi;

  /* Atualiza a carteira de novo, se houver prorrogacao
  if (:ptipo_retorno = 'PRORROGADOS') then
  begin
    update carteira
    set dt_ultima_prorrogacao=:ldt_ultima_prorrogacao,
        prorrogacao_realizadas=:lprorrogacao_realizadas,
        last_update=current_timestamp,
        last_owner=current_user
    where (id_colaborador=:pid_colaborador) and
        (id_epi=:lid_epi) and
        (dt_ultima_prorrogacao<:ldt_ultima_prorrogacao);
  end  */
  if (result_value=0) then result_value=:lid_movto;

  -- se foi uma devolução com uma nova retirada....
  if ((:pnova_retirada_id_ca > 0) and (:pnova_retirada_quantidade > 0)) then
  begin
    execute procedure  sp_movto_entregar(:pnova_retirada_id_ca,:pid_colaborador,:pnova_retirada_quantidade,:pdt_retorno,'N')
      returning_values :result_value;
  end

  -- recalculando o novo vencimento desse epi
  execute procedure SP_CARTEIRA_RECALC_ITEM (:pid_colaborador,:lid_epi) returning_values :result_value;

  /* Atualiza a carteira de novo, se houver prorrogacao */
  if ((:ptipo_retorno = 'PRORROGADOS') and (:lid_movto_prorrogado>0)) then
  begin
    select a.dt_vencimento from carteira a
    where id_colaborador=:pid_colaborador and id_epi=:lid_epi
    into :ldt_vencimento_depois;

    update ca_movtos_prorrogacao
    set dt_vencimento_depois=:ldt_vencimento_depois
    where (id_prorrogacao=:lid_movto_prorrogado);
  end
  if (result_value=0) then result_value=:lid_movto;
  suspend;
end ^

ALTER PROCEDURE SP_MOVTO_ENTREGAR (P_ID_CA D_ROWID = 0,
P_ID_COLABORADOR D_ROWID = 0,
P_QTDE_SAIDA D_QUANTIDADE = 0,
P_DT_SAIDA D_DATA = current_date,
P_RECALCULAR CHAR(1) CHARACTER SETISO8859_1  = 'S')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable ldt_vencimento d_data = current_date;
declare variable ldt_vencimento_anterior d_data = current_date;
declare variable ldurabilidade d_durabilidade = 0;
declare variable lopcional d_resposta = 'N';
declare variable lid_movto d_rowid = 0;
declare variable lid_epi d_rowid = 0;
declare variable lca_status char(1) = 'A';
declare variable lqtde_atual integer = 0;
declare variable loops integer = 0;
declare variable llote d_rowid = 0;
begin
  result_value=0;

  if ((:p_id_ca=0) or (:p_id_colaborador=0) ) then
  begin
    exception ERR 'CA ou Colaborador inválido !';
    suspend;
    exit;
  end

  /* calculando o id_epi usado para este CA */
  select id_epi, status from ca where id_ca=:p_id_ca
  into :lid_epi,:lca_status;

  if ((:p_id_ca=0) or (:p_id_colaborador=0) or (:lid_epi=0)) then
  begin
    exception ERR 'Id de um dos campos : CA, EPI ou Colaborador é inválido !';
    suspend;
    exit;
  end

  if (:lca_status<>'A') then
  begin
    exception ERR 'CA'||cast(:p_id_ca as varchar(8))||' não está ativo !';
    suspend;
    exit;
  end

  /* quantidade atual em mãos */
  select qtde_atual, dt_vencimento from get_carteira(:p_id_colaborador,:lid_epi)
  into :lqtde_atual, :ldt_vencimento_anterior;

  if (:ldt_vencimento_anterior < '01.01.2000') then
  begin
    ldt_vencimento_anterior=current_date;
  end

  /* Calculando vencimento */
  select opcional, durabilidade, dt_vencimento
  from get_vencimento(:p_id_colaborador, :lid_epi, :lqtde_atual+:p_qtde_saida, :ldt_vencimento_anterior)
  into :lopcional,:ldurabilidade,:ldt_vencimento;

/*
    exception ERR 'debug :'||
     ' id_colaborador='||cast(:p_id_colaborador as varchar(10))||
     ' id_epi='||cast(:lid_epi as varchar(10))||
     ' id_ca='||cast(:p_id_ca as varchar(10))||
     ' dt_vencimento_anterior='||cast(:ldt_vencimento_anterior as varchar(10))||
     ' durabilidade='||cast(:ldurabilidade as varchar(10))||
     ' dt_vencimento='||cast(:ldt_vencimento as varchar(10))||
     '.';
     suspend;
     exit;
*/

  if (:ldt_vencimento < :ldt_vencimento_anterior) then
  begin
    exception ERR 'Erro no calculo do vencimento='||cast(:ldt_vencimento as varchar(10))||' !';
    suspend;
    exit;
  end

  if (:ldurabilidade=0) then
  begin
    exception ERR 'Erro no calculo da durabilidade do EPI='||cast(:lid_epi as varchar(8))||' !';
    suspend;
    exit;
  end

  /* atualiza o CARTEIRA */
  update CARTEIRA
  set qtde_atual=qtde_atual+:p_qtde_saida,
      durabilidade=:ldurabilidade,
      dt_vencimento=:ldt_vencimento
  where id_colaborador=:p_id_colaborador and id_epi=:lid_epi;

  /* gravando registro */
  llote=0;
  while (:loops < :p_qtde_saida) do
  begin
    loops=:loops+1;

    /* calculando o proximo id */
    select coalesce(max(id_movto),0) from ca_movtos into :lid_movto;
    lid_movto=:lid_movto+1;
    if (:llote=0) then llote=:lid_movto;
    insert into ca_movtos(
      id_movto,
      id_colaborador,
      id_ca,
      id_epi,
      lote,
      dt_saida,
      dt_retorno,
      dt_vencimento,
      tipo_retorno,
      opcional,
      durabilidade,
      last_update,
      last_owner,
      status)
    values(
      :lid_movto,
      :p_id_colaborador,
      :p_id_ca,
      :lid_epi,
      :llote,
      :p_dt_saida,
      '01.01.1970',
      '01.01.1970',
      '',
      :lopcional,
      :ldurabilidade,
      current_timestamp,
      current_user,
      'A');
  end


  if (:p_recalcular='S') then
  begin
    -- recalculando o novo vencimento desse epi
    execute procedure SP_CARTEIRA_RECALC_ITEM (:p_id_colaborador,:lid_epi)
      returning_values :result_value;
  end
  result_value=:lid_movto;


  suspend;
end ^

ALTER PROCEDURE SP_PARAMETROS (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_PARAMETRO D_CODIGO30,
P_VALOR_NUM TYPE OF COLUMN PARAMETROS.VALOR_NUM = 0,
P_VALOR_STR TYPE OF COLUMN PARAMETROS.VALOR_STR = '')
RETURNS (VALOR_NUM TYPE OF COLUMN PARAMETROS.VALOR_NUM,
VALOR_STR TYPE OF COLUMN PARAMETROS.VALOR_STR)
AS 
begin
  valor_num=0;
  valor_str='';
  if (:p_acao not in ('CONSULTAR','INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end

  if (:p_acao='CONSULTAR') then
  begin
    select valor_num, valor_str from parametros
    where parametro=:p_parametro
    into :valor_num,:valor_str;
    if (:valor_num is null) then valor_num=0;
    if (:valor_str is null) then valor_str='';
  end

  if (:p_acao in ('INCLUIR','ALTERAR')) then
  begin
    update or insert into parametros(parametro, valor_num, valor_str, last_update, last_owner)
    values(:p_parametro, :p_valor_num, :p_valor_str, current_timestamp, current_user)
    matching(parametro);
    valor_num=:p_valor_num;
    valor_str=:p_valor_str;
  end
  if (:p_acao='EXCLUIR') then
  begin
    delete from parametros
    where parametro=:p_parametro;
    valor_num=:p_valor_num;
    valor_str=:p_valor_str;
  end
  suspend;
end ^

ALTER PROCEDURE SP_PERFIL (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_PERFIL D_ROWID,
P_PERFIL D_PERFIL = '',
P_DESCRICAO D_TEXTO = '',
P_STATUS D_STATUS = 'A')
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_next d_rowid = 0;
declare variable l_permitido integer = 0;
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='PERFIL' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_PERFIL','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end
  if (:p_acao='INCLUIR') then
  begin
    select coalesce(max(id_perfil),0)+1 from perfil
    into :l_next;
    insert into perfil(id_perfil,perfil,descricao,last_update,last_owner,status)
    values(:l_next,:p_perfil,:p_descricao,current_timestamp,current_user,'A');
    result_value=:l_next;
  end
  if (:p_acao='ALTERAR') then
  begin
    update perfil
    set perfil=:p_perfil,
        descricao=:p_descricao,
        last_update=current_timestamp,
        last_owner=current_user,
        status=:p_status
    where id_perfil=:p_id_perfil;
    result_value=:p_id_perfil;
  end
  if (:p_acao='EXCLUIR') then
  begin
    if (exists(select * from perfil_epi where id_perfil=:p_id_perfil)) then
    begin
      exception ERR 'Não pode excluir um perfil usado por algum EPI !';
      suspend;
      exit;
    end
    if (exists(select * from colaborador_perfil where id_perfil=:p_id_perfil)) then
    begin
      exception ERR 'Não pode excluir um perfil que é usado por algum colaborador !';
      suspend;
      exit;
    end

    if (exists(select * from colaborador_perfil_movtos where id_perfil=:p_id_perfil)) then
    begin
      exception ERR 'Não pode excluir um perfil que tenha algum historico com algum colaborador !';
      suspend;
      exit;
    end

    delete from colaborador_perfil_movtos
    where id_perfil=:p_id_perfil;

    delete from perfil_epi
    where id_perfil=:p_id_perfil;

    delete from colaborador_perfil
    where id_perfil=:p_id_perfil;

    delete from perfil
    where id_perfil=:p_id_perfil;
  end
  suspend;
end ^

ALTER PROCEDURE SP_PERFIL_EPI (P_ACAO VARCHAR(30) CHARACTER SETISO8859_1 ,
P_ID_PERFIL TYPE OF COLUMN PERFIL_EPI.ID_PERFIL,
P_ID_EPI TYPE OF COLUMN PERFIL_EPI.ID_EPI,
P_OPCIONAL TYPE OF COLUMN PERFIL_EPI.OPCIONAL = 'N',
P_DURABILIDADE TYPE OF COLUMN PERFIL_EPI.DURABILIDADE = 0,
P_DURABILIDADE_EXPLICACAO TYPE OF COLUMN PERFIL_EPI.DURABILIDADE_EXPLICACAO = '',
P_PRORROGACAO_DIAS TYPE OF COLUMN PERFIL_EPI.PRORROGACAO_DIAS = 0,
P_PRORROGACAO_MAX_VEZES TYPE OF COLUMN PERFIL_EPI.PRORROGACAO_MAX_VEZES = 0)
RETURNS (RESULT_VALUE D_ROWID)
AS 
declare variable l_durabilidade type of column perfil_epi.durabilidade = 0;
declare variable l_permitido integer = 0;
declare variable l_dt_inauguracao d_data = '01.01.2000';
begin
  result_value=0;
  if (:p_acao not in ('INCLUIR','ALTERAR','EXCLUIR')) then
  begin
    exception ERR 'Ação solicitada ('||:p_acao||') está fora dos parametros permitidos !';
    suspend;
    exit;
  end
  /* Verifica se tem permissão para realizar manutenção */
  select valor_num from parametros where parametro='PERFIL_EPI' into :l_permitido;
  if (:l_permitido <=0) then
  begin
    execute procedure SP_LOG  'SP_PERFIL_EPI','Permissão negada, solicite acesso do administrador !','S';
    suspend;
    exit;
  end
  if ((:p_id_perfil=0) or (:p_id_epi=0)) then
  begin
    exception ERR 'Associação de perfil e epi é inválida !';
    suspend;
    exit;
  end

  if (:p_acao='INCLUIR') then
  begin
    insert into perfil_epi(id_perfil,id_epi,opcional,durabilidade,durabilidade_explicacao,prorrogacao_dias,prorrogacao_max_vezes)
    values(:p_id_perfil,:p_id_epi,:p_opcional,:p_durabilidade,:p_durabilidade_explicacao,:p_prorrogacao_dias,:p_prorrogacao_max_vezes);

    result_value=1;
  end

  if (:p_acao='ALTERAR') then
  begin
    select durabilidade from perfil_epi
    where id_perfil=:p_id_perfil and id_epi=:p_id_epi
    into :l_durabilidade;

    update perfil_epi
    set opcional=:p_opcional,
        durabilidade=:p_durabilidade,
        durabilidade_explicacao=:p_durabilidade_explicacao,
        prorrogacao_dias=:p_prorrogacao_dias,
        prorrogacao_max_vezes=:p_prorrogacao_max_vezes
    where id_perfil=:p_id_perfil and id_epi=:p_id_epi;

    if (:p_durabilidade<>:l_durabilidade) then
    begin
      select dt_inauguracao from GET_DT_INAUGURACAO into :l_dt_inauguracao;
      execute procedure sp_recalcular (:l_dt_inauguracao,current_date) returning_values :result_value;
    end

    result_value=1;
  end

  if (:p_acao='EXCLUIR') then
  begin
    if (exists(
        select * from colaborador_perfil a
        inner join perfil_epi b on (b.id_perfil=a.id_perfil)
        inner join ca_movtos c on (c.id_epi=b.id_epi)
        where a.id_perfil=:p_id_perfil and c.id_epi=:p_id_epi and c.status='A'
    )) then
    begin
      exception ERR 'Não pode excluir um EPI dum perfil que tenha alguma pendencia com algum colaborador !';
      suspend;
      exit;
    end

    delete from perfil_epi
    where id_perfil=:p_id_perfil and id_epi=:p_id_epi;
    result_value=1;
  end
  suspend;
end ^

ALTER PROCEDURE SP_RECALCULAR (P_DT_INICIAL D_DATA = '1970-01-01',
P_DT_FINAL D_DATA = '1970-01-01',
P_ID_COLABORADOR D_ROWID = 0)
RETURNS (RESULT_VALUE INTEGER)
AS 
declare variable l_id_colaborador d_rowid = 0;
declare variable l_id_epi d_rowid = 0;
declare variable stmt varchar(4096)='';
declare variable q char(1) = '''';
begin
  result_value=0;
  if (:p_dt_inicial < '01.01.2000') then
  begin
    execute procedure SP_LOG  'SP_RECALCULAR',
      'O recalculo não aceita datas anteriores a 2000-01-01 ('||cast(:p_dt_inicial as varchar(10))||') !',
      'S';
    suspend;
    exit;
  end


  /* Se a data inicial não for especificada então o recalculo incluirá desde o registro mais antigo */
  /* Se a data final não for especificada entao assume a data atual */
  if (:p_dt_final < '2000-01-01') then p_dt_final=current_date;
  stmt='select distinct id_colaborador, id_epi';
  stmt=:stmt||' from GET_CA_MOVTOS_RANGE(:st_dt_inicial,:st_dt_final,:st_id_colaborador)';
  stmt=:stmt||' where status='||:q||'A'||:q||';';


  result_value=0;

  for execute statement (:stmt) ( st_dt_inicial := :p_dt_inicial, st_dt_final := :p_dt_final, st_id_colaborador := :p_id_colaborador )
  into
    :l_id_colaborador,
    :l_id_epi do
  begin
    execute procedure SP_CARTEIRA_RECALC_ITEM (:l_id_colaborador, :l_id_epi)
     returning_values :result_value;
  end

  suspend;
end ^
SET TERM ; ^
COMMIT WORK ;
SET AUTODDL ON;

/* Grant roles for this database */

/* Role: R_SESMT, Owner: SYSDBA */
CREATE ROLE R_SESMT;

/* Grant permissions for this database */
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON AGENDA TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON CA TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON CARTEIRA TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON CA_MOVTOS TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON CA_MOVTOS_PRORROGACAO TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON COLABORADOR TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON COLABORADOR_PERFIL TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON COLABORADOR_PERFIL_MOVTOS TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON EPI TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON LOG_ERRORS TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON PARAMETROS TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON PERFIL TO ROLE R_SESMT;
GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON PERFIL_EPI TO ROLE R_SESMT;
GRANT RDB$ADMIN TO GLADISTON;
GRANT RDB$ADMIN TO RUDD;
GRANT R_SESMT TO CLEUDINEA;
GRANT R_SESMT TO FERREIRA;
GRANT R_SESMT TO FLAVIO;
GRANT R_SESMT TO FLAVIO_OBRAS;
GRANT R_SESMT TO FLAVIO_PROJETOS;
GRANT R_SESMT TO GLADISTON;
GRANT R_SESMT TO LUANA;
GRANT R_SESMT TO RUDD;
GRANT EXECUTE ON PROCEDURE GET_CARTEIRA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_CA_LISTA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_CA_MOVTOS_RANGE TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_DIAS_UTEIS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_DT_INAUGURACAO TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_DT_ULTIMO_VENCIMENTO TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_EPI_LISTA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_QS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_SE_DIA_UTIL TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_SOMA_DIAS_UTEIS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_USO_TABELAS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE GET_VENCIMENTO TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SET_DESTRUIR_DADOS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_AGENDA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_CA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_CARTEIRA TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_CARTEIRA_RECALC_ITEM TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_COLABORADOR TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_COLABORADOR_PERFIL TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_EPI TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_LOG TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_MOVTO_DEVOLVER TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_MOVTO_ENTREGAR TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_PARAMETROS TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_PERFIL TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_PERFIL_EPI TO ROLE R_SESMT;
GRANT EXECUTE ON PROCEDURE SP_RECALCULAR TO ROLE R_SESMT;
