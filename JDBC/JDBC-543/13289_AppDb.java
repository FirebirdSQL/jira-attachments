package app.core;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.Scanner;

import org.firebirdsql.event.DatabaseEvent;
import org.firebirdsql.event.EventListener;
import org.firebirdsql.event.FBEventManager;

import com.mchange.v2.c3p0.ComboPooledDataSource;


public class AppDb {

	private ComboPooledDataSource dbpool = null;
	private FBEventManager evman = null;

	private static AppDb _self = null;
	public static AppDb getAppDb() {
		if (_self != null) {
			return _self;
		}
		_self = new AppDb();
		return _self;
	}

	@SuppressWarnings("deprecation")
	private AppDb() {
		dbpool = new ComboPooledDataSource();
		
		dbpool.setJdbcUrl("jdbc:firebirdsql://localhost:3050/<PATH_TO_FDB_FILE>?encoding=NONE&charSet=ISO-8859-1");
		dbpool.setUser("<USERNAME>");
		dbpool.setPassword("<PASSWORD>");
		// Optional Settings
		dbpool.setInitialPoolSize(5);
		dbpool.setMinPoolSize(3);
		dbpool.setAcquireIncrement(5);
		dbpool.setMaxPoolSize(15);
		dbpool.setMaxStatements(100);
		
		evman = new FBEventManager();

		evman.setHost("localhost");
		evman.setPort(3050);
		evman.setUser("<USERNAME>");
		evman.setPassword("<PASSWORD>");
		evman.setDatabase("<PATH_TO_FDB_FILE>");

		eventManagerConnect();
        Scanner scn = new Scanner(System.in);
        scn.nextLine();
        try {
			evman.disconnect();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public void eventManagerConnect() {
		if (evman.isConnected()) {
			return;
		}
		try {
			evman.connect();
			evman.addEventListener("someevent", new EventListener() {
	            public void eventOccurred(DatabaseEvent de) {
	                System.out.println("Registered event " + de.getEventName());
	            }
	        });

	        System.out.println("Stop the Firebird server to see CPU spike");
	        System.out.println("Press enter to terminate event manager");
			System.out.println("Database event manager active");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public ComboPooledDataSource getDbpool() {
		return dbpool;
	}


	public Connection getDbConnection() {
		Connection conn = null;
		try {
			conn = dbpool.getConnection();
		}
		catch (SQLException e) {
			e.printStackTrace();
		}
		return conn;
	}

	// Closing the connection
	public static void close(Connection dbConn, Statement stmt, ResultSet rs) {
		try {
			if (dbConn != null) {
				dbConn.close();
				dbConn = null;
			}
			if (rs != null) {
				rs.close();
				rs = null;
			}
			if (stmt != null) {
				stmt.close();
				stmt = null;
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
