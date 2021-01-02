package nl.lawinegevaar.fb;

import org.firebirdsql.gds.GDSException;
import org.firebirdsql.management.FBManager;
import org.firebirdsql.management.FBStatisticsManager;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLWarning;

/**
 * @author <a href="mailto:mrotteveel@users.sourceforge.net">Mark Rotteveel</a>
 */
public class DialectTest {

    private static final String USER = "sysdba";
    private static final String PASSWORD = "masterkey";
    private static final String HOST = "localhost";
    private static final int PORT = 3050;
    private static final String DB_PATH = "D:/data/db/dialecttest.fdb";
    private static final String JDBC_URL = String.format(
            "jdbc:firebirdsql://%s:%d/%s",
            HOST, PORT, DB_PATH);

    public static void main(String[] args) throws Exception {
        FBManager manager = new FBManager();
        manager.setServer(HOST);
        manager.setPort(PORT);
        manager.setUserName(USER);
        manager.setPassword(PASSWORD);
        manager.setFileName(DB_PATH);
        manager.setCreateOnStart(true);
        manager.setDropOnStop(true);
        try {
            manager.start();

            FBStatisticsManager stats = new FBStatisticsManager();
            stats.setHost(HOST);
            stats.setPort(PORT);
            stats.setUser(USER);
            stats.setPassword(PASSWORD);
            stats.setDatabase(DB_PATH);
            stats.setLogger(System.out);
            stats.getHeaderPage();

            try (Connection con = DriverManager.getConnection(JDBC_URL + "?charSet=iso-8859-1&set_db_sql_dialect=1", USER, PASSWORD)) {
                SQLWarning warning = con.getWarnings();
                if (warning != null) {
                    for (Throwable e : warning) {
                        e.printStackTrace();
                    }
                }
            }

            stats.getHeaderPage();
        } finally {
            manager.stop();
        }
    }
}
