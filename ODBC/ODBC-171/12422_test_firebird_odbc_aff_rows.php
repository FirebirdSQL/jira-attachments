<?php

$connection = odbc_connect( "Driver={Firebird/Interbase(r) driver};Server=localhost;Database=F:/Firebird_2_5/data/TEST_FIREBIRD.GDB;", "root", "pass" );
   
$rs = odbc_exec( $connection, "UPDATE emp_test SET l_name='Gomez' WHERE l_name='Jones'" );   

echo odbc_num_rows( $rs );

?>