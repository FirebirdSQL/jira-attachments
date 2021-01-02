package test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;

public class FBParametersTestCase {

    private final String url;
    private final String username;
    private final String password;

    private static final String TEST_TABLE_NAME = "TEST_TABLE";
    private static final String DRIVER_CLASS = "org.firebirdsql.jdbc.FBDriver";

    public FBParametersTestCase(final String url, final String username, final String password) {
        super();
        this.url = url;
        this.username = username;
        this.password = password;
    }

    public static void main(final String[] args) throws Exception {

        if (args.length != 3) {
            log("usage : java " + FBParametersTestCase.class.getName() + " <dbUrl> <dbUsername> <dbPassword>");

            System.exit(1);
        }

        final String url = args[0];
        final String username = args[1];
        final String password = args[2];

        final FBParametersTestCase tester = new FBParametersTestCase(url, username, password);

        tester.test();

    }

    private static void log(final String string) {
        System.out.println(string);
    }

    protected void test() throws Exception {

        Class.forName(DRIVER_CLASS);

        // drop and create the table
        setupTestTable();

        // Will execute the same requests to fill, update and query data, first using only sql orders without parameters,
        // then with sql orders with parameters.
        // The results should be the same but its not the case at all...

        // Could add sql orders like 'UPDATE MY_TABLE SET NAME = XXX WHERE NAME = YYY', using a too long value for the WHERE clause.
        // Without parameters, it would update 0 rows. With parameters, it would throw an error.

        executeTestsWithoutParametersInRequests();

        executeTestsWithParametersInRequests();
    }

    private void executeTestsWithoutParametersInRequests() {

        log("\n\n====== Beginning tests using requests without parameters ======");

        log("\nWill insert a line with a short name");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (1, 'a')", false);

        log("\nWill insert a line with a name whose length is the max length");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (2, 'abcdefghij')", false);

        log("\nWill insert a line with a name whose length is max length + 1. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (3, 'abcdefghij1')", true);

        log("\nWill insert a line with a name whose length is max length + 2. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (4, 'abcdefghij12')", true);

        log("\nWill insert a line with a name whose length is max length + 3. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (5, 'abcdefghij123')", true);

        log("\nWill try to update line 2 with a name whose length is max length + 1. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = 'abcdefghij1' WHERE ID = 1", true);

        log("\nWill try to update line 2 with a name whose length is max length + 2. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = 'abcdefghij12' WHERE ID = 1", true);

        log("\nWill try to update line 2 with a name whose length is max length + 3. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = 'abcdefghij123' WHERE ID = 1", true);

        log("\nWill select lines with \"NAME = 'abcdefghij'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = 'abcdefghij'");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE 'abcdefghij'");

        log("\nWill select lines with \"NAME = 'abcdefghij%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = 'abcdefghij%'");

        log("\nWill select lines with \"NAME = '%abcdefghij%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = '%abcdefghij%'");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij%'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE 'abcdefghij%'");

        log("\nWill select lines with \"NAME LIKE '%abcdefghij%'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE '%abcdefghij%'");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij1'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE 'abcdefghij1'");

        log("\nWill select lines with \"NAME LIKE '%abcdefghij1%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE '%abcdefghij1%'");
    }

    private void executeTestsWithParametersInRequests() {

        log("\n\n====== Beginning tests using requests with parameters ======");

        log("\nWill insert a line with a short name");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (?, ?)", false, 101, "a");

        log("\nWill insert a line with a name whose length is the max length");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (?, ?)", false, 102, "abcdefghij");

        log("\nWill insert a line with a name whose length is max length + 1. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (?, ?)", true, 103, "abcdefghij1");

        log("\nWill insert a line with a name whose length is max length + 2. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (?, ?)", true, 104, "abcdefghij12");

        log("\nWill insert a line with a name whose length is max length + 3. This must fail.");
        update("INSERT INTO " + TEST_TABLE_NAME + " values (?, ?)", true, 105, "abcdefghij123");

        log("\nWill try to update line 2 with a name whose length is max length + 1. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = ? WHERE ID = ?", true, "abcdefghij1", 101);

        log("\nWill try to update line 2 with a name whose length is max length + 2. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = ? WHERE ID = ?", true, "abcdefghij12", 101);

        log("\nWill try to update line 2 with a name whose length is max length + 3. This must fail.");
        update("UPDATE " + TEST_TABLE_NAME + " SET NAME = ? WHERE ID = ?", true, "abcdefghij123", 101);

        log("\nWill select lines with \"NAME = 'abcdefghij'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = ?", "abcdefghij");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE ?", "abcdefghij");

        log("\nWill select lines with \"NAME = 'abcdefghij%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = ?", "abcdefghij%");

        log("\nWill select lines with \"NAME = '%abcdefghij%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME = ?", "%abcdefghij%");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij%'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE ?", "abcdefghij%");

        log("\nWill select lines with \"NAME LIKE '%abcdefghij%'\"");
        select(1, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE ?", "%abcdefghij%");

        log("\nWill select lines with \"NAME LIKE 'abcdefghij1'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE ?", "abcdefghij1");

        log("\nWill select lines with \"NAME LIKE '%abcdefghij1%'\"");
        select(0, "SELECT * FROM " + TEST_TABLE_NAME + " WHERE NAME LIKE ?", "%abcdefghij1%");
    }

    private void select(final int expectedResultsNb, final String req, final Object... args) {
        Connection conn = null;
        try {
            conn = getConnection();

            final PreparedStatement ps = conn.prepareStatement(req);

            if (args != null) {

                int i = 1;
                for (final Object arg : args) {

                    ps.setObject(i++, arg);
                }
            }

            final ResultSet rs = ps.executeQuery();

            int rowcount = 0;
            while (rs.next()) {
                rowcount++;
            }

            log("For request '" + req + "', expected " + expectedResultsNb + " line(s), got " + rowcount + " : "
                    + (expectedResultsNb == rowcount ? "ok" : "KO !"));

        } catch (final Exception e) {

            log("====== ERROR : request \"" + req + "\" failed for args " + toString(args)
                    + ", should not have. Stacktrace is :");
            e.printStackTrace();
        } finally {
            closeConnection(conn);
        }
    }

    private Integer update(final String req, final boolean mustFail) {
        Connection conn = null;
        try {
            conn = getConnection();

            final Statement st = conn.createStatement();
            return st.executeUpdate(req);
        } catch (final Exception e) {

            if (!mustFail) {
                log("====== ERROR : request \"" + req + "\" failed, should not have. Stacktrace is :");
                e.printStackTrace();
            } else {
                log("Request \"" + req + "\" failed as expected, error message : " + e);
            }

            return null;
        } finally {
            closeConnection(conn);
        }
    }

    private void select(final int expectedResultsNb, final String req) {
        Connection conn = null;
        try {
            conn = getConnection();

            final ResultSet rs = conn.createStatement().executeQuery(req);

            int rowcount = 0;
            while (rs.next()) {
                rowcount++;
            }

            log("For request '" + req + "', expected " + expectedResultsNb + " line(s), got " + rowcount + " : "
                    + (expectedResultsNb == rowcount ? "ok" : "KO !"));

        } catch (final Exception e) {

            log("====== ERROR : request \"" + req + "\" failed, should not have. Stacktrace is :");
            e.printStackTrace();
        } finally {
            closeConnection(conn);
        }
    }

    private Integer update(final String req, final boolean mustFail, final Object... args) {
        Connection conn = null;
        try {
            conn = getConnection();

            final PreparedStatement ps = conn.prepareStatement(req);

            if (args != null) {

                int i = 1;
                for (final Object arg : args) {

                    ps.setObject(i++, arg);
                }
            }

            final Integer result = ps.executeUpdate();

            if (mustFail) {
                log("====== ERROR : request \"" + req + "\" succeeded for args " + toString(args)
                        + ", should have failed.");
            }

            return result;

        } catch (final Exception e) {

            if (!mustFail) {
                log("====== ERROR : request \"" + req + "\" failed for args " + toString(args)
                        + ", should not have. Stacktrace is :");
                e.printStackTrace();
            } else {
                log("Request \"" + req + "\" failed as expected for args " + toString(args) + ", error message : " + e);
            }

            return null;
        } finally {
            closeConnection(conn);
        }
    }

    private String toString(final Object[] args) {

        if (args == null) {
            return "null";
        }

        return Arrays.asList(args).toString();
    }

    private void setupTestTable() throws Exception {
        Connection conn = null;

        try {
            conn = getConnection();

            final Statement st = conn.createStatement();

            try {
                st.execute("DROP TABLE " + TEST_TABLE_NAME);
                log("Removed table " + TEST_TABLE_NAME);
            } catch (final Exception e) {
                log("Table " + TEST_TABLE_NAME + " did not exist or could not delete it : " + e);
            }

            st.execute("CREATE TABLE " + TEST_TABLE_NAME + " (ID INTEGER PRIMARY KEY, NAME VARCHAR(10))");
            log("Created table " + TEST_TABLE_NAME);

        } finally {
            closeConnection(conn);
        }
    }

    private Connection getConnection() throws SQLException {
        final Connection result = DriverManager.getConnection(url, username, password);

        log("Got connection " + result);

        return result;
    }

    private void closeConnection(final Connection conn) {
        if (conn != null) {

            try {

                final boolean ok = testConnection(conn);

                if (ok) {
                    log("Connection " + conn + " is still valid");
                } else {
                    log("Connection " + conn + " is NO LONGER valid !");
                }

                log("Closing connection " + conn);
                conn.close();
            } catch (final Exception e) {
                e.printStackTrace();
                log("Could not close connection : " + e);
            }
        }

    }

    private boolean testConnection(final Connection conn) {

        try {
            if (conn.isClosed()) {
                return false;
            }

            conn.createStatement().executeQuery("select count(*) from rdb$relations");

            return true;

        } catch (final Exception e) {
            log("Error testing connection " + conn + " : " + e);

            return false;
        }
    }
}
