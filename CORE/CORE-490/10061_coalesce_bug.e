/*
 *  Program type:   Embedded Static SQL
 *
 *  Name:  coalesce_bug.c
 *
 *  Description:
 *  This code is based on the Firebird file examples/stat.e.
 *  It demostrates that the gpre distributed with Firebird
 *  1.5.1 does not recognize the COALESCE() function.
 *
 *  Platform:  SuSE Linux 9.0
 *
 *  Firebird installed with:  FirebirdSS-1.5.1.4481-0.i686.tar.gz
 *
 *  Instructions:
 *  Compile  & execute as follows:
 *
 *  $ gpre coalesce_bug.e
 *  $ cc coalesce_bug.c -L/opt/firebird/lib -lfbclient -o coalesce_bug
 *  $./coalesce_bug
 *
 *  Now, comment out line #78:
 *
 *     SELECT first_name, last_name, phone_ext, dept_no
 *
 *  and uncomment lines #82-85:
 *
 *     SELECT first_name, last_name,
 *       COALESCE(phone_ext, "**NONE**"), dept_no
 *
 *  Try precomiling:
 *
 *  $ gpre coalesce_bug.e
 *  (E) coalesce_bug.e:84: expected FROM, encountered "("
 *  (E) coalesce_bug.e:94: expected <cursor name>, encountered "EMP_CUR"
 *  (E) coalesce_bug.e:105: expected <cursor name>, encountered "EMP_CUR"
 *  (E) coalesce_bug.e:121: expected <cursor name>, encountered "EMP_CUR"
 *    4 errors, no warnings
 *
 *  The same problem occurs if you uncomment lines #86-89.
 *  
 */
#include <stdlib.h>
#include <stdio.h>

EXEC SQL
    BEGIN DECLARE SECTION;
EXEC SQL 
    SET DATABASE empdb = '/opt/firebird/examples/employee.fdb';
EXEC SQL
    END DECLARE SECTION;


int main (void)
{
    BASED_ON employee.first_name  fname;
    BASED_ON employee.last_name   lname;
    BASED_ON employee.phone_ext   ext;
    BASED_ON employee.dept_no     dept;

    /* Trap all errors. */
    EXEC SQL
        WHENEVER SQLERROR GO TO Error;

    /* Trap SQLCODE = -100 (end of file reached during a fetch). */
    EXEC SQL
        WHENEVER NOT FOUND GO TO AllDone;

    /* Ignore all warnings. */
    EXEC SQL
        WHENEVER SQLWARNING CONTINUE;

    /* Create the query. */
    /* NOTE:  Either of the two SELECTs with COALESCE will 
     *         generate an error from gpre.
     */
    EXEC SQL
        DECLARE emp_cur CURSOR FOR

        SELECT first_name, last_name, phone_ext, dept_no
 
/*
 *         SELECT first_name, last_name, 
 *             COALESCE(phone_ext, "**NONE**"), dept_no
 */
/*
 *         SELECT first_name, last_name, 
 *             COALESCE(phone_ext, "**NONE**") as phone_ext, dept_no
 */
        FROM employee;

    /* Open the cursor. */
    EXEC SQL
        OPEN emp_cur;

    printf( "\n%-15s %-20s %-9s %-7s\n\n",
        "FIRST_NAME", "LAST_NAME", "PHONE_EXT", "DEPT_NO" );

    /*
     *  Select and display all rows.
     */
    while ( SQLCODE == 0 )
    {
        EXEC SQL
            FETCH emp_cur INTO :fname, :lname, :ext, :dept;

        /* 
         *  If FETCH returns with -100, the processing will jump
         *  to AllDone before the following printf is executed.
         */

        printf( "%-15s %-20s %-9s %-7s\n", 
            fname, lname, ext, dept );
    }

    /*
     *    Close the cursor and release all resources.
     */
AllDone:
    EXEC SQL
        CLOSE emp_cur;

    EXEC SQL
        COMMIT RELEASE;

    return 0;

    /*
     *    Print the error, and exit.
     */
Error:
    isc_print_sqlerror((short)SQLCODE, gds__status);
        
    return 1;
}
