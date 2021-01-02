package jaybird;

import java.io.InputStream;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryUsage;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * 
 * create table TABLE1 (COL1 integer not null, COL2 blob sub_type 0, COL3 blob sub_type 0, primary key (COL1))
 * 
 *
 */
public class TestReadBlob
{
    public static void main(String[] args)
    {
        try
        {
            Class.forName("org.firebirdsql.jdbc.FBDriver");
            Connection connection = DriverManager.getConnection("jdbc:firebirdsql:localhost/3050:c:/base/database.fdb?charSet=utf-8",
                                                                "sysdba",
                                                                "masterkey");
            connection.setAutoCommit(false);

            long start = System.currentTimeMillis();
            Statement st = connection.createStatement();
            ResultSet rs = st.executeQuery("select first(300000) COL2, COL3 from TABLE1");
            int nbRows = 0;
            while (rs.next())
            {
                nbRows++;
                
                // Read first blob column
                InputStream stream1 = rs.getBinaryStream(1);
                if (!rs.wasNull())
                {
                    while (stream1.read() != -1)
                        ;
                    stream1.close();
                }

                // Read second blob column
                InputStream stream2 = rs.getBinaryStream(2);
                if (!rs.wasNull())
                {
                    while (stream2.read() != -1)
                        ;
                    stream2.close();
                }
                
                if (nbRows % 10000 == 0)
                {
                    System.out.println(nbRows + " rows fetched");
                }

            }
            System.out.println(nbRows + " rows fetched in " + (System.currentTimeMillis() - start) + " ms");
            rs.close();
            st.close();
            start = System.currentTimeMillis();
            connection.close();
            System.out.println("connection closed in " + (System.currentTimeMillis() - start) + " ms");

            MemoryUsage heapMemoryUsage = ManagementFactory.getMemoryMXBean().getHeapMemoryUsage();
            int used = (int) heapMemoryUsage.getUsed() / (1024 * 1024);
            System.out.println("heap memory usage : " + used + " MB");
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
}
