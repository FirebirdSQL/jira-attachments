#include <ibase.h>

#ifdef cygwin
  #define EXPORT __declspec( dllexport )
#else
  /* linux */
  #define EXPORT
#endif

typedef unsigned char  SC_UCHAR;
typedef struct par_vary {
    ISC_USHORT          vary_length;
    SC_UCHAR            vary_string[1];
} PAR_VARY;


extern "C" ISC_LONG EXPORT fn_2cstring (char *sz, char *sz2)
{
  return 1;
}


extern "C" ISC_LONG EXPORT fn_2varchar ( PAR_VARY const& s, PAR_VARY const& s2 )
{
  return 2;
}


extern "C" ISC_LONG EXPORT fn_2byDescriptor(const paramdsc* v, const paramdsc *v2)
{
  return 3;
}

