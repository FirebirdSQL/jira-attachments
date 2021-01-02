package com.gentlesoft.gdao.test;

import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.gentlesoft.commons.util.database.DatabaseUtil;
import com.gentlesoft.commons.util.database.DatabaseUtil.ColumnCheckInfo;
import com.gentlesoft.commons.util.database.util.NameUtil;
import com.gentlesoft.commons.util.database.util.TableUtil;

public class TestTable {

	/**
	 * @param args
	 * @throws ClassNotFoundException 
	 * @throws IllegalAccessException 
	 * @throws InstantiationException 
	 * @throws SQLException 
	 */
	public static void main(String[] args) throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException {

		
		//CREATE TABLE TUSER (name varchar (200) ,strclob BLOB SUB_TYPE TEXT,id varchar (200) NOT NULL ,tlob BLOB  ,o integer  ,PRIMARY KEY(id)) ;
		TestTable.testnp();
	}
	
	public static void testnp() throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException{
		DriverManager.registerDriver((Driver)Class.forName("org.firebirdsql.jdbc.FBDriver").newInstance());
		Connection connection=DriverManager.getConnection("jdbc:firebirdsql://localhost:3050/dev?lc_ctype=UTF8", "sysdba", "masterkey");
		Statement ss=connection.createStatement();
		ResultSet rs=ss.executeQuery("select * from TUSER where name ='aaaaaaaaaaaaaaaaaaaaaaaadddddddddd11111111'");
		rs.close();
		ss.close();
		connection.close();
		
	}
	
	public static void testp() throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException{
		DriverManager.registerDriver((Driver)Class.forName("org.firebirdsql.jdbc.FBDriver").newInstance());
		Connection connection=DriverManager.getConnection("jdbc:firebirdsql://localhost:3050/dev?lc_ctype=UTF8", "sysdba", "masterkey");
		PreparedStatement ss=connection.prepareStatement("select * from TUSER where name =?");
		ss.setString(1, "aaaaaaaaaaaaaaaaaaaaaaaadddddddddd11111111");
		ResultSet rs=ss.executeQuery();
		rs.close();
		ss.close();
		connection.close();
		
	}
	public static void test11(){
		TableUtil tu=new TableUtil();
		System.out.println(tu.getCateTableSql(UserObj.class, "ID"));
		System.out.println(NameUtil.javaNameToDbName("WfTaskList"));
		System.out.println(NameUtil.javaNameToDbName("WfActList"));
		System.out.println(NameUtil.dbNameToVarName("WF_ACT_LIST"));		
	}
	public static void getData() throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException
	{
		DriverManager.registerDriver((Driver)Class.forName("oracle.jdbc.driver.OracleDriver").newInstance());
		Connection connection=DriverManager.getConnection("jdbc:oracle:thin:@192.168.0.129:1521:OA", "GENTLE", "GENTLE");
		DatabaseUtil du=new DatabaseUtil(connection, "GENTLE");
	    Set<String> tableNames=new HashSet<String>();
	    tableNames.add("CMS_CHANNEL");
	    Map<String ,Map<String,ColumnCheckInfo>> sss=du.getColumnInfo(tableNames, true);
	    System.out.println(sss);

 
	 
		connection.close();
	 
	}
}
