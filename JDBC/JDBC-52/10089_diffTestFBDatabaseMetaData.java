Index: src/test/org/firebirdsql/jca/TestFBDatabaseMetaData.java
===================================================================
RCS file: /cvsroot/firebird/client-java/src/test/org/firebirdsql/jca/TestFBDatabaseMetaData.java,v
retrieving revision 1.2
diff -r1.2 TestFBDatabaseMetaData.java
335a336
> 	    // expanded tests added by Jeremy Williams 2002.
338c339,340
< 
---
> 	createProcedure("testproc1", true);
> 	createProcedure("testproc2", false);
340a343,390
> 	boolean gotproc1 = false;
> 	boolean gotproc2 = false;
> 	while (rs.next()) {
> 		String name = rs.getString(3);
> 		String lit_name = rs.getString("PROCEDURE_NAME");
> 		assertTrue("result set from getProcedures schema mismatch: field 3 should be PROCEDURE_NAME",
> 			   name.equals(lit_name));
> 		String remarks = rs.getString(7);
> 		String lit_remarks = rs.getString("REMARKS");
> 		if (remarks == null || lit_remarks == null)
> 			if (remarks != null || lit_remarks != null)
> 				assertTrue("result set from getProcedures schema mismatch only one of field 7 or 'REMARKS' returned null", false);
> 			else
> 				assertTrue("all OK on the western front", true);
> 		else
> 			assertTrue ("result set from getProcedures schema mismatch: field 7 should be REMARKS",
> 			   remarks.equals(lit_remarks));
> 	        short type = rs.getShort(8);
> 		short lit_type = rs.getShort("PROCEDURE_TYPE");
> 		assertTrue("result set from getProcedures schema mismatch: field 8 should be PROCEDURE_TYPE",
> 			   type == lit_type);
> 		if (log !=null) log.info(" got procedure " + name);
> 	        if (name.equals("TESTPROC1")){
> 			assertTrue("result set from getProcedures had duplicate entry for TESTPROC1",
> 				!gotproc1);
> 			gotproc1 = true;
> 			assertTrue("result set from getProcedures had wrong procedure type for TESTPROC1 " +
> 				"(should be procedureReturnsResult)", type == DatabaseMetaData.procedureReturnsResult);
> 			assertTrue("result set from getProcedures did not return a value for REMARKS.", remarks != null);
> 			assertTrue("result set from getProcedures did not return correct REMARKS section.", remarks.equals("Test description"));
> 		}
> 		else if (name.equals("TESTPROC2")) {
> 			assertTrue("result set from getProcedures had duplicate entry for TESTPROC2",
> 				!gotproc2);
> 			gotproc2 = true;
> 			assertTrue("result set from getProcedures had wrong procedure type for TESTPROC2 " +
> 				"(should be procedureNoResult)", type == DatabaseMetaData.procedureNoResult);
> 		}
> 		else
> 		  assertTrue("result set from getProcedures returned unknown procedure " + name, false);
> 	}
> 	assertTrue ("result set from getProcedures did not return procedure testproc1", gotproc1);
> 	assertTrue ("result set from getProcedures did not return procedure testproc2", gotproc2);
> 	rs.close();
> 	dropProcedure("testproc1");
> 	dropProcedure("testproc2");
> 	if (ex != null)
> 	   throw ex;
345a396,397
> 	createProcedure("testproc1", true);
> 	createProcedure("testproc2", false);
348a401,466
> 	int rownum = 0;
> 	while (rs.next()) {
> 		rownum++;
> 		String procname = rs.getString(3);
> 		String colname = rs.getString(4);
> 		short coltype = rs.getShort(5);
> 		short datatype = rs.getShort(6);
> 		String typename = rs.getString(7);
> 		int precision = rs.getInt(8);
> 		int length = rs.getInt(9);
> 		short scale = rs.getShort(10);
> 		short radix = rs.getShort(11);
> 		short nullable = rs.getShort(12);
> 		String remarks = rs.getString(13);
> 		log.info ("row " + (new Integer(rownum)).toString() + "proc " + procname + " field " + colname);
> 
> 		// per JDBC 2.0 spec, there is a very specific order these
> 		// rows should come back, so if field names don't match
> 		// what I'm expecting, in the order I expect them, there
> 		// is a bug.
> 		switch (rownum) {
> 	          case 4:
> 		    assertTrue("wrong pr name.", procname.equals("TESTPROC1")); 
> 		    assertTrue("wrong f name.", colname.equals("IN1"));
> 		    assertTrue("wrong c type.", coltype ==
> 				    DatabaseMetaData.procedureColumnIn);
> 		    assertTrue("wrong d type.", datatype == Types.INTEGER);
> 		    assertTrue("wrong t name.", typename.equals("INTEGER"));
> 		    assertTrue("wrong radix.", radix == 10);
> 		    assertTrue("wrong nullable.", nullable == 
> 				    DatabaseMetaData.procedureNullable);
> 		    assertTrue("wrong comment.", remarks == null);
> 		    break;
> 		  case 5:
> 		    assertTrue("wrong pr name", procname.equals("TESTPROC1"));
> 		    assertTrue("wrong f name", colname.equals("IN2"));
> 		    break;
> 		  case 1:
> 		    assertTrue("wrong pr name", procname.equals("TESTPROC1"));
> 		    assertTrue("wrong f name", colname.equals("OUT1"));
> 		    assertTrue("wrong c type", coltype == 
> 				    DatabaseMetaData.procedureColumnOut);
> 		    break;
> 		  case 2:
> 		    assertTrue("wrong pr name", procname.equals("TESTPROC1"));
> 		    assertTrue("wrong f name", colname.equals("OUT2"));
> 		    break;
> 		  case 3:
> 		    assertTrue("wrong pr name", procname.equals("TESTPROC1"));
> 		    assertTrue("wrong f name", colname.equals("OUT3"));
> 		    break;
> 		  case 6:
> 		    assertTrue("wrong pr name", procname.equals("TESTPROC2"));
> 		    assertTrue("wrong f name", colname.equals("INP"));
> 		    break;
> 		  default:
> 		    assertTrue("stray field returned from getProcedureColumns.",
> 				    false);
> 		} // end-switch
> 		
> 
> 	} // end-while
> 	dropProcedure("testproc1");
> 	dropProcedure("testproc2");
> 	if (ex != null)
> 	   throw ex;
356c474
<         assertTrue("No resultset returned from getProcedureColumns", rs != null);
---
>         assertTrue("No resultset returned from getColumnPrivileges", rs != null);
401a520,544
>     private void createProcedure(String procedureName, boolean returnsData) throws Exception {
> 	dropProcedure(procedureName);
> 	t.begin();
> 	try {
> 	    if (returnsData) {
> 	      s.execute("CREATE PROCEDURE " + procedureName + "(IN1 INTEGER, IN2 FLOAT)" +
> 			    "RETURNS (OUT1 VARCHAR(20), OUT2 DOUBLE PRECISION, OUT3 INTEGER) AS "+
> 			    "DECLARE VARIABLE X INTEGER;"+
> 			    "BEGIN" +
> 			    " OUT1 = 'Out String';" +
> 			    " OUT2 = 45;" +
> 			    " OUT3 = IN1;" +
> 			    "END");
> 	      s.execute("UPDATE RDB$PROCEDURES SET RDB$DESCRIPTION='Test description' WHERE RDB$PROCEDURE_NAME='" + procedureName.toUpperCase() + "'");
> 	    }
> 	    else
> 	      s.execute("CREATE PROCEDURE " + procedureName + " (INP INTEGER) AS BEGIN exit; END");
> 	}
> 	catch (Exception e) {
> 		if (log != null) log.warn("error creating procedure: " + e.getMessage());
> 		ex = e;
> 	}
> 	t.commit();
>     }
> 
409a553,562
>     }
> 
>     private void dropProcedure(String procedureName) throws Exception {
> 	t.begin();
> 	try {
> 	    s.execute("DROP PROCEDURE " + procedureName);
> 	}
> 	catch (Exception e) {
> 	}
> 	t.commit();
