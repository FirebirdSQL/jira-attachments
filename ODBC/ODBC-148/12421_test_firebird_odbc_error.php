<?php

$connection = odbc_connect( "Driver={Firebird/Interbase(r) driver};Server=localhost;Database=F:/Firebird_2_5/data/TEST_FIREBIRD.GDB;", "root", "pass" );
   
odbc_autocommit( $connection, false );
            
$rs = odbc_exec( $connection, "UPDATE emp_test SET l_name='Braddox' WHERE l_name='Gomez'" );   

odbc_exec( $connection, "SAVEPOINT svp1" );
        
$rs = odbc_exec( $connection, "UPDATE emp_test SET l_name='Allen' WHERE l_name='Braddox'" );     
    
odbc_exec( $connection, "ROLLBACK TO SAVEPOINT svp1" );
odbc_commit( $connection );

?>