#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <strings.h>
#include <errno.h>
#include <unistd.h>

int okToLive = 1;
int dbConnected = 0;
char dbUser[100] = "sysdba";
char dbPasswd[100] = "masterkey";
char dataBase[256] = "qq.fdb";

EXEC SQL SET DATABASE db1 = COMPILETIME 'qq.fdb' RUNTIME:dataBase;

void
dbDisconnect ()
{
  fprintf (stderr, "Begin: dbDisconnect()\n");
  EXEC SQL ROLLBACK;
  EXEC SQL DISCONNECT ALL;
  fprintf (stderr, "End: dbDisconnect()\n");
}

// callback function for shutdown
static int abortShutdown(const int reason, const int mask, void* object)
{
	return reason == fb_shutrsn_signal ? 1 : 0;
}

void
dbErrCheck (fn, opr)
     char *fn, *opr;
{
  if ((SQLCODE != 0) && (SQLCODE != 100))
    {
      char buf[1000] = { '\0' };

      fprintf (stderr, "func: %s, opr: %s, SQLCODE: %d\n", fn, opr, SQLCODE);
      isc_sql_interprete (SQLCODE, buf, sizeof (buf));
      fprintf (0, "-SQLMSG: %s\n", buf);
      if (SQLCODE < -1)
	{
	  ISC_STATUS *v;
	  char buf2[1000] = { '\0' };

	  v = isc_status;
	  while (isc_interprete (buf2, &v))
	    fprintf (stderr, "-ISCMSG: %s\n", buf2);
	}
      fprintf (stderr, "program aborted.\n");
      exit (-1);
    }
  else
    {
      /* for some reason, some of the embedded EXEC SQL statements
       * generate non zero errno-s even if they succeed. Since we
       * are only interested in ERRORS if SQLCODE is not 0 or 100,
       * always reset errno to 0 in all other cases so output
       * messages do not reflect false values of errno.
       */
      errno = 0;
    }
  fprintf (stderr, "func: %s, opr: %s, SQLCODE: %d.\n", fn, opr, SQLCODE);
}

void
connectToDb ()
{
  fprintf (stderr, "Begin: connectToDb()\n");
  EXEC SQL CONNECT db1 USER:dbUser PASSWORD:dbPasswd;
  dbErrCheck ("connectToDb", "CONNECT");
  dbConnected = 1;
  fprintf (stderr, "connected to database %s\n", dataBase);
  fprintf (stderr, "End: connectToDb()\n");
}

void
stopServer (int sig)
{
  okToLive = 0;
}

int
main ()
{
  ISC_STATUS_ARRAY scbStat;
  if (fb_shutdown_callback(scbStat, abortShutdown, fb_shut_confirmation, NULL) != 0)
  {
	isc_print_status(scbStat);
	// continue execution anyway...
  }

  struct sigaction act;

  fprintf (stderr, "okToLive is %d. errno=%d\n", okToLive, errno);
  bzero (&act, sizeof (act));

  act.sa_handler = stopServer;
  act.sa_flags = SA_RESTART;
  sigaction (SIGTERM, &act, NULL);

  /* comment out this call to make program work without crash */
  connectToDb ();

  while (okToLive)
    {
      fprintf (stderr, "TOP: okToLive is %d. errno=%d\n", okToLive, errno);
      sleep (2);
      fprintf (stderr, "AFTER: okToLive is %d. errno=%d\n", okToLive, errno);
    }

  fprintf (stderr, "AFTER LOOP1: okToLive is %d. errno=%d\n", okToLive,
	   errno);
  errno = 0;
  fprintf (stderr, "AFTER LOOP2: okToLive is %d. errno=%d\n", okToLive,
	   errno);
  fprintf (stderr, "AFTER LOOP3: okToLive is %d. errno=%d\n", okToLive,
	   errno);
  sleep (5);
  fprintf (stderr, "AFTER SLEEP: okToLive is %d. errno=%d\n", okToLive,
	   errno);
  dbDisconnect ();
  fprintf (stderr, "LAST LINE: okToLive is %d. errno=%d\n", okToLive, errno);
  exit (0);
}
