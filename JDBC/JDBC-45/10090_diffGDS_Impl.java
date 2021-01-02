cvs server: Diffing src/org/firebirdsql/jgds
Index: src/org/firebirdsql/jgds/GDS_Impl.java
===================================================================
RCS file: /cvsroot/firebird/client-java/src/org/firebirdsql/jgds/GDS_Impl.java,v
retrieving revision 1.34
diff -r1.34 GDS_Impl.java
869a870
>               xsqlda.sqlvar[i].sqlind = (row[i] == null ? -1 : 0);
