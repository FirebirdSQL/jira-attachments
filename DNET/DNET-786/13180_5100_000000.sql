/******************************************************************************/
/****                              Exceptions                              ****/
/******************************************************************************/

CREATE EXCEPTION EXC_SM_CD_EF_CFOP 'CFOP Não Encontrado.';

CREATE EXCEPTION EXC_SM_CD_ES_PRODUTO 'Produto Não Cadastrado.';

CREATE EXCEPTION EXC_SM_CD_PARAMETROS 'Falha no Parâmetro.';

CREATE EXCEPTION EXC_SM_MV_CT_CB_CONTA_MO 'Movimentador Inválido para Esse tipo de Conta.';

CREATE EXCEPTION EXC_SM_MV_FI_CA_PA_TITULO_BX 'Existe(m) Parcela(s) de Cartão Crédito/Débito com Baixa.';

CREATE EXCEPTION EXC_SM_MV_FI_CH_TP_TITULO_MOV 'Existe(m) Movimentação do Cheque de Terceiros.';

CREATE EXCEPTION EXC_SM_MV_FI_TL_BX_PA_TITULO_BX 'Existe(m) Parcela(s) Paga(s) Para esse Titulo.';
