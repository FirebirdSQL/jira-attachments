/********************************************
*                                           *
*              *BLOB BUG CASE*              *
*                                           *
*    -----------------------------------    *
*           ---------------------           *
*                                           *
*         ------------------------          *
*           --------------------            *
*                Versión 1.0                *
*                                           *
*********************************************
*                                           *
* Escrito por:        Martin A. Lara V.     *
* Escrito el:         29/05/2013            *
* Última revisión:    29/05/2013            *
*                                           *
*********************************************
*                                           *
* Herramientas utilizadas:                  *
*                                           *
*   Notepad++ 6.3.2                         *
*   IBExpert 2013.02.20                     *
*   Firebird 2.1.5.18496                    *
*                                           *
********************************************/

/********************************************

DESCRIPCIÓN


********************************************/

/********************************************

HISTORIAL DE REVISIONES

1.0: 20130529
-------------

Creación.

********************************************/

CREATE PROCEDURE "BLOB_CASE_SP"

AS

DECLARE VARIABLE i INTEGER;
DECLARE VARIABLE fmemo BLOB SUB_TYPE TEXT SEGMENT SIZE 80;

BEGIN

  fmemo = '';

  i = 1;
  WHILE (i < 1280) DO BEGIN

    fmemo = fmemo || '1*2*3*4*5*6*7*8*';

    i = i + 1;
  END

END
