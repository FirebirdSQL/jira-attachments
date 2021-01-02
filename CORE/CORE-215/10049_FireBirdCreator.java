
import org.firebirdsql.management.FBManager;

public class FireBirdCreator
{
	public FireBirdCreator() 
	{
		FBManager fbManager = new FBManager(org.firebirdsql.gds.GDSType.getType("EMBEDDED"));
		
		try
		{							
			fbManager.start();
			fbManager.createDatabase("c:/teste.fdb","sysdba","masterkey");
		
		}
		catch(Exception e)
		{
			System.out.println(e);
		}	
	}	
	
	public static void main (String args[])
	{
		FireBirdCreator fbc = new FireBirdCreator();
	}
}