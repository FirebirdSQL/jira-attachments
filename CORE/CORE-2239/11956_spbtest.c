#include <ibase.h>

main()
{
	short value = 0x1234;
	char s[2];
	char *p = s;
	ADD_SPB_LENGTH(p, value);

	printf("%02x%02x\n", s[0], s[1]);
}
