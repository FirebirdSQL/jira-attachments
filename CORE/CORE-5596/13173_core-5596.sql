SELECT mg.dbBrutto_Full
, COALESCE(
             Round((
      IIF( exists(select g.id from c_goodSpec gs, c_good g where gs.id = mg.idGoodspec and g.id = gs.idGood and g.idMera0 = 2)
        , mg.dbBrutto_Count0 * (mg.dbCount0 - (select count(mgi.id) from c_move_good_item mgi where mgi.idMoveGood = mg.id /*and mgi.iNumber <> 0*/ and mgi.dbBrutto > 0.001))
        , mg.dbBrutto_Count0 * (mg.dbCount0 - COALESCE((select sum(mgi.dbCountList) from c_move_good_item mgi where mgi.idMoveGood = mg.id /*and mgi.iNumber <> 0*/ and mgi.dbBrutto > 0.001), 0e0))
          )
       + (select (CASE(3)
           WHEN g.idMera0 THEN mg.dbCount0
           WHEN g.idMera1 THEN mg.dbCount1
           WHEN g.idMera2 THEN mg.dbCount2
           WHEN g.idMera3 THEN mg.dbCount3
           ELSE 0.0
           END) from c_goodSpec gs, c_good g
            where gs.id = mg.idGoodspec
              and g.id = gs.idGood
            ) * 28.58
       + COALESCE((select sum(mgi.dbBrutto) from C_Move_Good_Item mgi where mgi.idMoveGood = mg.id /*and mgi.iNumber <> 0*/ and mgi.dbBrutto > 0.001), 0e0)
      ),0)
      , 0)

FROM C_Move_Good mg
JOIN C_move m ON m.id=mg.idMove
    WHERE  m.dtDay >= '01.01.2017' AND m.iRouteType=2
  AND mg.ibRekv=0
      AND (mg.dbBrutto_Full  - COALESCE(
                               Round((IIF( exists(select g.id from c_goodSpec gs, c_good g where gs.id = mg.idGoodspec and g.id = gs.idGood and g.idMera0 = :idMera_Pack)
                                  , mg.dbBrutto_Count0 * (mg.dbCount0 - (select count(mgi.id) from c_move_good_item mgi where mgi.idMoveGood = mg.id  and mgi.dbBrutto > 0.001))
                                  , mg.dbBrutto_Count0 * (mg.dbCount0 - COALESCE((select sum(mgi.dbCountList) from c_move_good_item mgi where mgi.idMoveGood = mg.id  and mgi.dbBrutto > 0.001), 0e0))
                                    )
                                 + (select (CASE(3)
                                   WHEN g.idMera0 THEN mg.dbCount0
                                   WHEN g.idMera1 THEN mg.dbCount1
                                   WHEN g.idMera2 THEN mg.dbCount2
                                   WHEN g.idMera3 THEN mg.dbCount3
                                   ELSE 0.0
                                   END) from c_goodSpec gs, c_good g
                                    where gs.id = mg.idGoodspec
                                      and g.id = gs.idGood
                                   ) * 28.58
                                 + COALESCE((select sum(mgi.dbBrutto) from C_Move_Good_Item mgi where mgi.idMoveGood = mg.id and mgi.dbBrutto > 0.001), 0e0)
                                ),0)
                                , 0)
          )
          BETWEEN -0.001 AND 0.001
      AND EXISTS( select * from c_goodSpec gs, c_good g
                  where gs.id = mg.idGoodspec
                    and g.id = gs.idGood
                    and (g.idMera0 = 3 OR g.idMera1 = 3
                          OR g.idMera2 = 3 OR g.idMera3 = 3));

