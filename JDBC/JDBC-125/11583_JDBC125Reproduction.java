package jdbc125;

import java.sql.SQLException;
import java.util.Scanner;
import org.firebirdsql.event.DatabaseEvent;
import org.firebirdsql.event.EventListener;
import org.firebirdsql.event.FBEventManager;

/**
 * Reproduction case for <a href="http://tracker.firebirdsql.org/browse/JDBC-125">JDBC-125</a>
 *
 * @author Mark Rotteveel
 */
public class JDBC125Reproduction {

    public static void main(String[] args) throws SQLException, InterruptedException {
        FBEventManager eventMgr = new FBEventManager();
        eventMgr.setHost("127.0.0.1");
        eventMgr.setDatabase("D:/data/DB/TESTDB.FDB");
        eventMgr.setUser("sysdba");
        eventMgr.setPassword("masterke");
        
        eventMgr.connect();

        eventMgr.addEventListener("someevent", new EventListener() {
            public void eventOccurred(DatabaseEvent de) {
                System.out.println("Registered event " + de.getEventName());
            }
        });

        System.out.println("Stop the Firebird server to see CPU spike");
        System.out.println("Press enter to terminate event manager");
        Scanner scn = new Scanner(System.in);
        scn.nextLine();

        eventMgr.disconnect();
    }

}
