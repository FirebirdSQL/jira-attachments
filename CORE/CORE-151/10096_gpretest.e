#include <stdio.h>

#include "iscintf.h"

	EXEC SQL
		SET DATABASE DB0 = COMPILETIME "c:\\program files\\firebird\\examples\\employee.gdb";

	EXEC SQL
   	BEGIN DECLARE SECTION;

			BASED ON DB0.COUNTRY.COUNTRY db0_country_country;
			BASED ON DB0.CUSTOMER.CUSTOMER db0_customer_customer;

	EXEC SQL
   	END DECLARE SECTION;

	EXEC SQL
		DECLARE a_nice_long_long_long_cusor_name_for_country CURSOR FOR
          SELECT COUNTRY
              FROM COUNTRY;
	EXEC SQL
		DECLARE a_nice_long_long_long_cusor_name_for_customer CURSOR FOR
          SELECT CUSTOMER
              FROM CUSTOMER;

int		main(int argv, char ** argv) {

	return(0);
}
