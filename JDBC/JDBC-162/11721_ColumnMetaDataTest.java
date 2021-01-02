package firebird.reproduction;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 *
 * @author Mark
 */
public class ColumnMetaDataTest {
    
    // Standard 'EMPLOYEE' example database
    private static final String JDBC_URL = "jdbc:firebirdsql://localhost/D:/data/DB/EMPLOYEE.FDB";
    private static final String USER = "sysdba";
    private static final String PASSWORD = "masterke";

    @BeforeClass
    public static void prepareTest() throws ClassNotFoundException {
        Class.forName("org.firebirdsql.jdbc.FBDriver");
    }

    /**
     * Column label should equals column name without alias.
     *
     * @throws SQLException
     */
    @Test
    public void getColumnLabelNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUST_NO FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnLabel = rsmd.getColumnLabel(1);
            Assert.assertEquals("Unexpected column label", "CUST_NO", columnLabel);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Column name should be name of actual column.
     *
     * @throws SQLException
     */
    @Test
    public void getColumnNameNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUST_NO FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnName = rsmd.getColumnName(1);
            Assert.assertEquals("Unexpected column name", "CUST_NO", columnName);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Column label should be the alias if one is specified
     *
     * @throws SQLException
     */
    @Test
    public void getColumnLabelWithAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnLabel = rsmd.getColumnLabel(1);
            Assert.assertEquals("Unexpected column label", "CST_NAME", columnLabel);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Column name should be name of actual column, not the specified alias
     *
     * @throws SQLException
     */
    @Test
    public void getColumnNameWithAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnName = rsmd.getColumnName(1);
            Assert.assertEquals("Unexpected column name", "CUSTOMER", columnName);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Unspecified behavior for literals without an alias
     *
     * @throws SQLException
     */
    @Test
    public void getColumnLabelForLiteralNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT 'A Literal' FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnLabel = rsmd.getColumnLabel(1);
            Assert.assertEquals("Unexpected column label", "", columnLabel);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Unspecified behavior for literals without an alias
     *
     * @throws SQLException
     */
    @Test
    public void getColumnNameForLiteralNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT 'A Literal' FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnName = rsmd.getColumnName(1);
            Assert.assertEquals("Unexpected column name", "", columnName);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }


    /**
     * Column label for a literal should be the alias if one is specified
     *
     * @throws SQLException
     */
    @Test
    public void getColumnLabelForLiteralWithAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT 'A Literal' AS SOME_ALIAS FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnLabel = rsmd.getColumnLabel(1);
            Assert.assertEquals("Unexpected column label", "SOME_ALIAS", columnLabel);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Unspecified behavior for literals with an alias
     *
     * @throws SQLException
     */
    @Test
    public void getColumnNameForLiteralWithAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT 'A Literal' AS SOME_ALIAS FROM CUSTOMER");

            ResultSetMetaData rsmd = rs.getMetaData();
            String columnName = rsmd.getColumnName(1);
            Assert.assertEquals("Unexpected column name", "", columnName);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }


}
