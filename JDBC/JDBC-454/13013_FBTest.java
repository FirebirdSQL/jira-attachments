

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class FBTest {
    public static void main(String args[]) throws SQLException {
        System.out.println("System encoding: " + System.getProperty("file.encoding"));
        Connection conn = DriverManager.getConnection("jdbc:firebirdsql:dtzaverp:ZE05_PROD?encoding=ISO8859_1", "INTRANET", "#5servic");
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM BSAKTX A WHERE A.ID=39371");
        
        while(rs.next()) {
            byte bytes[] = rs.getBytes("TEXT");
            System.out.println(printByteMap(bytes));
            
            String txt = rs.getString("TEXT");
            byte txtBytes[] = txt.getBytes();
            System.out.println(printByteMap(txtBytes));
        }
        
        rs.close();
        stmt.close();
        conn.close();
    }
    
    public static String printByteMap(final byte[] bytemap) {
        StringBuilder strByte = new StringBuilder("Contains ").append(bytemap.length).append(" Bytes: ");

        for (byte currByte : bytemap) {
            strByte.append(Integer.toHexString(currByte)).append(" ");
        }

        return strByte.toString();
    }    
}
