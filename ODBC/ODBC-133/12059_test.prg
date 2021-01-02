&& 1st create a new SYSTEM DSN in control panel called FBTEST whith the correct parameters 
&& for the database name , user and password, the from the forxpro command line execute this
&& program. For example: DO test.prg

CLEAR
xconec=SQLCONNECT("FBTEST")

&& lcsql="SELECT SUM(QUANTITY1) AS Q1,SUM(QUANTITY2) AS Q2,SUM(QUANTITY3) AS Q3,SUM(QUANTITY4) AS Q4   FROM TEST"

lcsql="SELECT CAST(SUM(QUANTITY1) AS INTEGER) AS Q1,CAST(SUM(QUANTITY2) AS INTEGER) AS Q2,SUM(QUANTITY3) AS Q3,SUM(QUANTITY4) AS Q4  FROM TEST"

aux = sqlexec(xconec,lcsql,"temp")
if aux<1
	MESSAGEBOX("SQLEXEC ERROR")
	RETURN
ENDIF

SELECT temp

? "TEMP.Q1: "+TYPE("temp.q1")
? "TEMP.Q2: "+TYPE("temp.q2")
? "TEMP.Q3: "+TYPE("temp.q3")
? "TEMP.Q4: "+TYPE("temp.q4")

&&
&& TYPE returns N for numeric fields and C for character fields
&&

USE IN temp
=SQLDISCONNECT(xconec)


