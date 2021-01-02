package testFBbug;

//import java.awt.*;
import javax.swing.*;
import java.sql.ResultSet;
import java.sql.Statement;




public class testfb extends JFrame {
  
  private static JLabel labConnString;
  
  private static JLabel labVersion;

  private static JLabel labInfo;

  private static db myDb;
    
  public testfb(){
    myDb = new db();
    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
    setSize(400, 300);
    setTitle("Developing the First Swing Application");    
    setDefaultCloseOperation(EXIT_ON_CLOSE);
    labConnString = new JLabel("Connection string: " + db.getConnectionString());
    labVersion = new JLabel("Driver: " + db.getDriver());
    labInfo = new JLabel("");
    add(labConnString);
    add(labVersion);
    add(labInfo);
    try {

      Statement stm = db.getConn().createStatement();
    
      ResultSet rs = stm.executeQuery("SELECT * FROM PR_PARCELLA_DESCR(125, 2)");
    
      if(rs.next()) {
      
        // Accessing any field of the resultset causes the err_pid log to appear
        // remove the following line and nothing should happen
        rs.getString("DESCRIZIONE");
        
        labInfo.setText("Statement executed, exit program and check if err.log appears after few seconds");
      
      }
      
    } catch(Exception e) {
        
       labInfo.setText("Something went worng..." + e.getMessage());
        
    } finally {
		try {
			db.getConn().close();
		} catch (java.sql.SQLException ex) {
			ex.printStackTrace();
		}
	}
    
  }

  public static void main(String[] args) {
    testfb demo = new testfb();
    demo.setVisible(true);
  }
}
