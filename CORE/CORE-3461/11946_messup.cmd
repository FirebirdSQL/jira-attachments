del aa.fdb
isql -i messup1.sql
gbak -b aa.fdb aa.fbk
gbak -rep aa.fbk aa.fdb
isql aa.fdb -i messup2.sql
