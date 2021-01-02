package test;

import java.sql.*;

public class Test {

	/**
	 * @param args
	 * @throws SQLException 
	 * @throws IOException
	 * @throws DocumentException
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Statement state=null;
		Connection conn=null;
		
		try {
			Class.forName("org.firebirdsql.jdbc.FBDriver").newInstance();
			String url = "jdbc:firebirdsql:localhost/3050:/Users/zhaoce/Documents/Database/Core.fdb";
			conn = DriverManager.getConnection(url, "SYSDBA", "masterkey");

			state = conn.createStatement();
			conn.setAutoCommit(false);
			conn.setSavepoint();
			String sql = "insert into USERS values('zhaoce','fdjakl')";
			state.executeUpdate(sql);
			conn.commit();
		} catch (Exception e) {
			e.printStackTrace();
			try {
				conn.rollback();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				System.out.println("roll back fail");
				e1.printStackTrace();
			}
		}finally{
			if(state!=null) try{state.close();}catch(Exception e){}
			if(conn!=null) try{conn.close();}catch(Exception e){}
		}
		
	}

}
