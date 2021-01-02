CREATE TABLE OPENING (
  OPENING_ID KEY_FIELD NOT NULL,
  PROJECT_ID KEY_FIELD NOT NULL,
  TAG LONG_CODE NOT NULL,
  ARCHITECTS_MARK LONG_CODE NOT NULL,
  QTY QUANTITY NOT NULL,
  UOM SHORT_CODE NOT NULL,
  HAND SHORT_CODE NOT NULL,
  KEYING_ID KEY_FIELD_ALLOW_NULL,
  DOOR_QTY QUANTITY NOT NULL,
  DEGREES SHORT_CODE NOT NULL,
  WIDTH MEASUREMENT NOT NULL,
  HEIGHT MEASUREMENT NOT NULL,
  DOOR_THICKNESS MEASUREMENT NOT NULL,
  LABEL_ID KEY_FIELD_ALLOW_NULL,
  DOOR_MATERIAL_ID KEY_FIELD_ALLOW_NULL,
  FRAME_MATERIAL_ID KEY_FIELD_ALLOW_NULL,
  LOCATION1 DESCRIPTION NOT NULL,
  FROM_TO SHORT_CODE NOT NULL,
  LOCATION2 DESCRIPTION NOT NULL,
  OPENING_DESCRIPTION LONG_DESCRIPTION NOT NULL,
  NOTES BLOB SUB_TYPE 2 SEGMENT SIZE 1,
  SORT_ALPHA LONG_CODE NOT NULL,
  SORT_NUMERIC INTEGER NOT NULL,
  AUDIT_USER_ID KEY_FIELD_ALLOW_NULL,
  PREDEFINED_ID KEY_FIELD_ALLOW_NULL,
  SORT_SEQ MYFLOAT NOT NULL,
  EXTERIOR "BOOLEAN" NOT NULL,
  OPENING_TYPE CHAR(1) CHARACTER SET ASCII DEFAULT 'D' NOT NULL COLLATE ASCII,
  DOOR_INDEX INTEGER,
  ID INTEGER,
  UID VARCHAR(50) CHARACTER SET ASCII,
  POSITION_X DOUBLE PRECISION,
  POSITION_Y DOUBLE PRECISION,
  POSITION_Z DOUBLE PRECISION);


ALTER TABLE OPENING ADD CONSTRAINT PK_OPENING PRIMARY KEY (PROJECT_ID,OPENING_ID);

ALTER TABLE OPENING ADD CONSTRAINT FK_OPENING FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT(PROJECT_ID) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX IDX_OPENING ON OPENING(PROJECT_ID,TAG);
