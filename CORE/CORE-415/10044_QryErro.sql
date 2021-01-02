SELECT debcred.nivel1,
       0 AS nivel2,
       0 AS nivel3,
       0 AS nivel4,
       SUM(debcred.vlr_cred)   AS vlr_cred   ,
       SUM(debcred.vlr_deb)    AS vlr_deb    ,
       SUM(debcred.vlr_lancto) AS vlr_lancto ,
       cf.descricao  AS descr_conta

  FROM itens_vlrdebcred_esconde  debcred
       INNER JOIN lancamentos lancto  ON (debcred.idlancamentos = lancto.idlancamentos)
       INNER JOIN contas_finan cf on (debcred.nivel1 = cf.nivel1 and cf.nivel2 = 0)

  WHERE debcred.dt_vencto >= :dt_dataIni AND
        debcred.dt_vencto <= :dt_dataFim AND
        debcred.dt_baixa >= :dt_dataIni AND
        debcred.dt_baixa <= :dt_dataFim AND
        lancto.excluido = 'N' AND
        cf.excluido = 'N'

GROUP BY debcred.nivel1,cf.descricao

