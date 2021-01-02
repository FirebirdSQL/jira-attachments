package test.java;

import java.sql.Connection;
import java.sql.DataTruncation;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class TestEncodingFB
{

    Connection cx = null;
    PreparedStatement vPrepareStatement = null;

    @Before
    public void setUp() throws Exception
    {
        Class.forName("org.firebirdsql.jdbc.FBDriver");
        cx = DriverManager.getConnection("jdbc:firebirdsql:localhost/3050:D:/W/bdd/test/TEST.fdb?encoding=UTF8&charSet=UTF8", "user", "mdp");
        vPrepareStatement = cx.prepareStatement("SELECT * from TEST WHERE CODE=?");
    }

    @After
    public void tearDown() throws Exception
    {
        if (vPrepareStatement != null)
        {
            try
            {
                vPrepareStatement.close();
            }
            catch (SQLException vException)
            {
                vException.printStackTrace();
            }
        }
        if (cx != null)
        {
            try
            {
                cx.close();
            }
            catch (SQLException vException)
            {
                vException.printStackTrace();
            }
        }
    }

    @Test
    public void testBeforeSQLLimit()
    {
        try
        {
            // 5 chars
            vPrepareStatement.setString(1, "eeeee");
            vPrepareStatement.execute();
        }
        catch (SQLException vException)
        {
            Assert.fail("Normally no exception to catch");
        }
    }

    @Test
    public void testAfterSQLLimit()
    {
        try
        {
            // 6 chars
            vPrepareStatement.setString(1, "eeeeee");
            vPrepareStatement.execute();
            Assert.fail("DataTruncation Exception must be thrown.");
        }
        catch (SQLException vException)
        {
            Assert.assertEquals("DataTruncation Exception must be thrown.", DataTruncation.class, vException.getClass());
        }
    }

    @Test
    public void testBeforeJaybirdLimitSize()
    {
        try
        {
            // 20 chars
            vPrepareStatement.setString(1, "eeeeeeeeeeeeeeeeeeee");
            vPrepareStatement.execute();
            Assert.fail("DataTruncation Exception must be thrown.");
        }
        catch (SQLException vException)
        {
            Assert.assertEquals("DataTruncation Exception must be thrown.", DataTruncation.class, vException.getClass());
        }
    }

    @Test
    public void testAfterJaybirdLimitSize()
    {
        try
        {
            // 21 chars
            vPrepareStatement.setString(1, "eeeeeeeeeeeeeeeeeeeee");
            vPrepareStatement.execute();
            Assert.fail("DataTruncation Exception must be thrown.");
        }
        catch (SQLException vException)
        {
            Assert.assertEquals("DataTruncation Exception must be thrown.", DataTruncation.class, vException.getClass());
        }
    }

    @Test
    public void testBeforeJaybirdLimitSizeWithExtendedChar()
    {
        try
        {
            // 10 accented chars (2 bytes)
            vPrepareStatement.setString(1, "éééééééééé");
            vPrepareStatement.execute();
            Assert.fail("DataTruncation Exception must be thrown.");
        }
        catch (SQLException vException)
        {
            Assert.assertEquals("DataTruncation Exception must be thrown.", DataTruncation.class, vException.getClass());
        }
    }

    @Test
    public void testAfterJaybirdLimitSizeWithExtendedChar()
    {
        try
        {
            // 11 accented chars (2 bytes)
            vPrepareStatement.setString(1, "ééééééééééé");
            vPrepareStatement.execute();
            Assert.fail("DataTruncation Exception must be thrown.");
        }
        catch (SQLException vException)
        {
            Assert.assertEquals("DataTruncation Exception must be thrown.", DataTruncation.class, vException.getClass());
        }
    }
}
