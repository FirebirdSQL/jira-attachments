#!/usr/bin/perl

use DBD::InterBase;

$dbh = DBI->connect("dbi:InterBase:db=/opt/mbserver/firebird/MBDB.GDB;host=localhost/3050", "sysdba", "masterkey");
$dbh->{LongReadLen} = 1000000000;
#$dbh->{LongTruncOk}=100000000;
my $sth=$dbh->prepare("SELECT XML_REPORT FROM MBREPORTS WHERE MBREPORT_ID IN (1344, 1697, 1805, 777, 650, 965, 883, 770, 659, 774, 652, 773, 775, 660, 772, 779, 778, 693, 694, 780, 731, 730, 882, 881, 884, 1259, 1318, 1319, 1320, 1321, 1674, 1261, 1346, 2064, 1345, 1802, 1803, 2065, 1806, 1807)");
$sth->execute();

while (@data=$sth->fetchrow_array()) {
	$dumbbuffer = $dumbbuffer.$data[0].$data[1];
}

$dbh->disconnect();
