import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Map;
import java.util.Properties;

import org.firebirdsql.gds.impl.GDSFactory;
import org.firebirdsql.gds.impl.GDSType;
import org.firebirdsql.jca.FBSADataSource;
import org.firebirdsql.jdbc.FBDriverPropertyManager;

public class DpbTest {
  public static void main(String[] args) throws SQLException {
    final String databaseURL = "localhost:C:\\TEST.FDB";
    final String jdbcUrl = "jdbc:firebirdsql:" + databaseURL + "?lc_ctype=WIN1251";
    final GDSType type = GDSFactory.getTypeForProtocol(jdbcUrl);
    final Properties props = new Properties();
    props.setProperty("user", "SYSDBA");
    props.setProperty("password", "masterkey");

    final Map<String, String> normalizedInfo = FBDriverPropertyManager.normalize(jdbcUrl, props);
    final FBSADataSource fbDataSource = new FBSADataSource(type);
    fbDataSource.setDatabase(databaseURL);
    for (Map.Entry<String, String> entry : normalizedInfo.entrySet())
      fbDataSource.setNonStandardProperty(entry.getKey(), entry.getValue());

    final String processName = "ÀÈÑ ÔÑÑÏ Ðîññèè";
    fbDataSource.setNonStandardProperty("isc_dpb_process_name", processName);

    final Connection c = fbDataSource.getConnection();
    final Statement st = c.createStatement();
    final ResultSet rs = st.executeQuery("select * from mon$attachments");
    while (rs.next()) {
      System.out.println(rs.getString("mon$remote_process"));
    }
  }
}
