//set SQL DIALECT 3;
//
//set names UTF8;
//
//create database 'c:\test.fdb'
//user 'SYSDBA' password 'xxxxxx'
//page_size 16384
//default character set UTF8;
//
//create table TEST (
//    A  varchar(10),
//    B  varchar(10)
//);
//
//insert into TEST (A, B) values ('as', 'as');
//
//commit work;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import org.firebirdsql.pool.FBWrappingDataSource;


public class TestCase
{

	static Map<String,Object> settings = new HashMap<String,Object>();

	static FBWrappingDataSource dataSource;


	private static void test()
	{
		Connection connection = null;
		PreparedStatement deleteStatement = null;
		PreparedStatement insertStatement = null;
		try {
			connection = dataSource.getConnection();
			connection.setAutoCommit(  false  );
			deleteStatement = connection.prepareStatement( "delete from test" );
			deleteStatement.executeUpdate();
			insertStatement = connection.prepareStatement( "insert into test ( a, b ) values ( ?, ? )" );
			insertStatement.setString( 1, "test" );
			insertStatement.executeUpdate();
			connection.commit();
		} catch ( SQLException e ) {
			e.printStackTrace();
		} finally {
			try { deleteStatement.close(); } catch ( Throwable t ) {} 
			try { insertStatement.close(); } catch ( Throwable t ) {}
			try { connection.close(); } catch ( Throwable t ) {}
		}
	}


	@SuppressWarnings( "boxing" )
	public final static void main( String[] args )
		throws Exception
	{
		if ( args.length == 0 )
			args = new String[] { "127.0.0.1:c:/test.fdb", "sysdba", "xxxxxx" };

		dataSource = new FBWrappingDataSource();
		dataSource.setCharSet( "utf-8" );
		dataSource.setDatabase( args[ 0 ] );
		dataSource.setNonStandardProperty( "sql_dialect", Integer.toString( 3 ) );
		dataSource.setEncoding( "utf8" );
		dataSource.setMaxPoolSize( 1 );
		dataSource.setPassword( args[ 2 ] );
		dataSource.setUserName( args[ 1 ] );
		try {
			test();
		} catch ( Exception e ) {
			System.out.println( "First try failed." );
		}
//		try {
//			test();
//		} catch ( Exception e ) {
//			System.out.println( "Second try failed." );
//		}
		dataSource.shutdown();
	}

}
