import fdb
import time, thread, datetime, sys, os
import traceback

def log(msg):
    print "%s %s" % (datetime.datetime.now(), msg)

def doProcessEvents():
    log("doProcessEvents()")

if __name__ == '__main__':
    SQLServerAddress = 'localhost'
    SQLDatabaseLocation = 'TEST.FDB'
    SQLUserName = 'SYSDBA'
    SQLUserPassword = 'password'
    SQLDialect = 3
    SQLCharset = 'UTF8'
    SQLRole = ''
    timeout = 0.8
    minTimeout = 0.2
    con = fdb.connect(host=SQLServerAddress, database=SQLDatabaseLocation, user=SQLUserName, password=SQLUserPassword, sql_dialect=SQLDialect, charset=SQLCharset, role=SQLRole)
    try:
        while True:
            # listen for event
            try:
                eventNames = ['EVENT']
                con.begin(tpb= (fdb.isc_tpb_read,
                       fdb.isc_tpb_read_committed,
                       fdb.isc_tpb_rec_version,
                       fdb.isc_tpb_nowait))
                log("event_conduit(%s)" % eventNames)
                event_listener = con.event_conduit(eventNames)
                if minTimeout:
                    time.sleep(minTimeout)
                events = event_listener.wait(timeout)
                event_listener.close()
                con.commit()
                processEvents = None
                if events is not None:
                    for eventName in eventNames:
                        if eventName in events and events[eventName] > 0:
                            processEvents = True
                            break
                if processEvents:
                    doProcessEvents()
            except KeyboardInterrupt:
                sys.exit(0)
            except:
                log(repr(traceback.format_exc()))
    finally:
        con.close()
    log("Bye!")

