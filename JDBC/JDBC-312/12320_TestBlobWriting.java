package jaybird;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import junit.framework.Assert;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * 
 * create table table1
 * (
 *   col1 blob sub_type 0
 * );s
 * 
 *
 */
public class TestBlobWriting
{
    private static final int BATCH_SIZE = 10;
    private static final String JDBC_DRIVER_CLASSNAME = "org.firebirdsql.jdbc.FBDriver";
    private static final String JDBC_URL = "jdbc:firebirdsql:localhost/3050:d:/base/test_firebird.fdb";
    private static final String USER = "sysdba";
    private static final String PASSWORD = "masterkey";
    private static final byte[] BYTE_ARRAY = new byte[] {0x0a, 0x0b};

    private static Connection connection;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception
    {
        // GET CONNECTION
        Class.forName(JDBC_DRIVER_CLASSNAME);
        connection = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
        connection.setAutoCommit(false);
    }

    @AfterClass
    public static void tearDownAfterClass() throws Exception
    {
        // CLOSE CONNECTION
        connection.close();
    }

    @Before
    public void setUp() throws Exception
    {
        // CLEAR TABLE
        clearTable();
        connection.commit();
        Assert.assertEquals(0, count());
    }

    @Test
    public void test1() throws Exception
    {
        // WRITE BLOB
        PreparedStatement insertPreparedStatement = connection.prepareStatement("insert into table1 (col1) values (?)");

        // ONE BATCH INSERT
        insert(insertPreparedStatement, true);

        insertPreparedStatement.close();
        connection.commit();

        Assert.assertEquals(BATCH_SIZE, count());

        // READ BLOB
        readTable();
    }

    @Test
    public void test2() throws Exception
    {
        // WRITE BLOB
        PreparedStatement insertPreparedStatement = connection.prepareStatement("insert into table1 (col1) values (?)");

        // FIRST INSERT
        insert(insertPreparedStatement, false);

        // SECOND INSERT
        insert(insertPreparedStatement, false); // Problem here : setBinaryStream inserts an empty BLOB !!!

        insertPreparedStatement.close();
        connection.commit();

        Assert.assertEquals(2 * BATCH_SIZE, count());

        // READ BLOB
        readTable();
    }

    @Test
    public void test3() throws Exception
    {
        // WRITE BLOB
        PreparedStatement insertPreparedStatement = connection.prepareStatement("insert into table1 (col1) values (?)");

        // FIRST BATCH INSERT
        insert(insertPreparedStatement, true);

        // SECOND BATCH INSERT
        insert(insertPreparedStatement, true); // Problem here : setBinaryStream inserts an empty BLOB !!!

        // THIRD BATCH INSERT
        insert(insertPreparedStatement, true); // Problem here : setBinaryStream inserts an empty BLOB !!!

        insertPreparedStatement.close();
        connection.commit();

        Assert.assertEquals(3 * BATCH_SIZE, count());

        // READ BLOB
        readTable();
    }

    private void clearTable() throws SQLException
    {
        Statement statement = connection.createStatement();
        statement.executeUpdate("delete from table1");
        statement.close();
    }

    private int count() throws SQLException
    {
        int count = 0;
        Statement statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery("select count(*) from table1");
        if (resultSet.next())
        {
            count = resultSet.getInt(1);
        }
        resultSet.close();
        statement.close();
        return count;
    }

    private void insert(PreparedStatement insertPreparedStatement, boolean useBatch) throws SQLException
    {
        for (int i = 0; i < BATCH_SIZE; i++)
        {
            InputStream inputStream = new ByteArrayInputStream(BYTE_ARRAY);
            insertPreparedStatement.setBinaryStream(1, inputStream, BYTE_ARRAY.length);
            if (useBatch)
            {
                insertPreparedStatement.addBatch();
            }
            else
            {
                insertPreparedStatement.executeUpdate();
            }
        }
        if (useBatch)
        {
            insertPreparedStatement.executeBatch();
        }
    }

    private void readTable() throws SQLException, IOException
    {
        Statement selectStatement = connection.createStatement();
        ResultSet resultSet = selectStatement.executeQuery("select col1 from table1");
        while (resultSet.next())
        {
            Blob blob = (Blob) resultSet.getBlob(1);
            Assert.assertEquals(2, blob.length());
            byte[] buffer = new byte[2];
            blob.getBinaryStream().read(buffer);
            Assert.assertEquals(2, buffer.length);
            Assert.assertEquals(BYTE_ARRAY[0], buffer[0]);
            Assert.assertEquals(BYTE_ARRAY[1], buffer[1]);
        }
        resultSet.close();
        selectStatement.close();
    }
}
