package de.procar.fbtest.ejb;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.annotation.Resource;
import javax.ejb.Remote;
import javax.ejb.SessionContext;
import javax.ejb.Stateless;
import javax.sql.DataSource;

@Stateless
@Remote(FBTestRemote.class)
public class FBTestBean implements FBTestRemote{

	@Resource(mappedName = "java:/jdbc/FirebirdDB")
	private DataSource fbDataSource;

	@Resource
	private SessionContext ctx;

	public void test() throws Exception {

		Connection con = null;
		Statement stmt = null;
		ResultSet result = null;

		try {
			con = fbDataSource.getConnection();
			stmt = con.createStatement();
//			try{
//			stmt.executeUpdate("INSERT INTO TABLE1 (COLUMN1) VALUES ('TEST')");
//			}
//			catch(Exception e){
//				e.printStackTrace();
//			}
//			// execute an other query
//			result = stmt.executeQuery("SELECT COUNT(*) FROM TABLE1");
//			if (result.next()){
//				int count = result.getInt(0);
//				if (count > 1){
//					throw new Exception("Count is greater than 1!");
//				}
//			}
			ctx.setRollbackOnly();

		} catch (Exception e) {
			e.printStackTrace();
//			ctx.setRollbackOnly();
			throw e;
		} finally {
			if (result != null) {
				try {
					result.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			if (con != null) {
				try {
					con.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

	}

}
