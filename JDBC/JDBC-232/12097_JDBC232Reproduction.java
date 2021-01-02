package com.progpol.test;


import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import org.firebirdsql.event.DatabaseEvent;
import org.firebirdsql.event.EventListener;
import org.firebirdsql.event.FBEventManager;
import org.firebirdsql.gds.impl.GDSType;


/**
 * Reproduction case for <a href="http://tracker.firebirdsql.org/browse/JDBC-125">JDBC-125</a>
 *
 * @author T.Kujalow
 */
public class JDBC232Reproduction {

	
	
    /**
     * Thread id=9 in my situation is this thread which generate 100% CPU consumption after stopping Firebird server
     *  
     */
	static long thId=9;	
	
	
	private static ThreadMXBean tMXB1=null;
	private static boolean cpuTimeEnabled=false;
    public static void main(String[] args) throws SQLException, InterruptedException {
    	
    	
    	tMXB1 = ManagementFactory.getThreadMXBean();
		if( tMXB1!=null && tMXB1.isThreadCpuTimeSupported() ){
			tMXB1.setThreadCpuTimeEnabled(true);
			if (tMXB1.isThreadCpuTimeEnabled()){
				cpuTimeEnabled=true;
			}
		}

		try {
			Class.forName("org.firebirdsql.event.FBEventManager");
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
        FBEventManager eventMgr = new FBEventManager(GDSType.getType("PURE_JAVA"));
        eventMgr.setHost("127.0.0.1");
        /**
         * Any firebird database path. Event registering is not necessary.
         * */
        eventMgr.setDatabase("t:\\test.gdb");
        eventMgr.setUser("sysdba");
        eventMgr.setPassword("masterkey");
        eventMgr.setPort(3050);        
        eventMgr.connect();
        
        
        
        eventMgr.addEventListener("someevent", new EventListener() {
            public void eventOccurred(DatabaseEvent de) {
                System.out.println("Registered event " + de.getEventName());
            }
        });

        
        System.out.println("    Host: "+eventMgr.getHost());
        System.out.println("    Port: "+eventMgr.getPort());
        System.out.println("Database: "+eventMgr.getDatabase());        
        System.out.println("    User: "+eventMgr.getUser());
        System.out.println("Password: "+eventMgr.getPassword());
        System.out.println(getSystemProperty("java.version"));
        System.out.println(getSystemProperty("java.vm.version"));
        System.out.println(getSystemProperty("java.vm.vendor"));
        System.out.println(getSystemProperty("java.vm.name"));
        System.out.println(getSystemProperty("java.compiler"));
        System.out.println(getSystemProperty("java.vendor"));
        System.out.println(getSystemProperty("os.arch"));
        System.out.println(getSystemProperty("os.name"));
        System.out.println(getSystemProperty("os.version"));
        
        
        
        showSubThreads();
        System.out.println();System.out.println();System.out.println();
        System.out.println("-----------------------------------------");
        System.out.println("Stop now the Firebird server to see CPU spike (for thread id="+thId+")");
        
        
        
        long prevCpuTime=-1;
        long prevCpuTimeTS=-1;
        long currCpuTime=-1;
        long currCpuTimeTS=-1;
        float cpuTimePerc=-1;
        int loopCnt=0;
        
        
        while(eventMgr.isConnected()){
        	loopCnt++;
        	Thread.sleep(1000);
        	if (loopCnt%10==0){
        		System.out.println();
        	}
        	
        	
			if (cpuTimeEnabled){
				currCpuTime=tMXB1.getThreadCpuTime(thId);
				currCpuTimeTS = new Date().getTime()*1000000;
				if (prevCpuTime>=0){
					cpuTimePerc=(float)((100*(double)(currCpuTime-prevCpuTime))/(currCpuTimeTS-prevCpuTimeTS));
				}else{
					cpuTimePerc=-1;
				}
				prevCpuTime=currCpuTime;
				prevCpuTimeTS=currCpuTimeTS;				
			}

					
        	System.out.print(""+cpuTimePerc+"[%] ");
        	
        	
        	/**
        	 * Some more information for thread id=thId
        	 * In my situation thId=9
        	 * If you want, uncomment it
        	 */
        	//System.out.println("CPU= "+cpuTimePerc+" [%]  "+"trace= "+getSomeInfoForThreadId(thId));
        	
        	
        	
        	System.out.print("-> ");
        	
        	
        }
        
        
        eventMgr.disconnect();
    }

    
    
	public static ArrayList<Thread> getSubThreads(){
		
		ArrayList<Thread> threadList= new ArrayList<Thread>();
		ThreadGroup root = Thread.currentThread().getThreadGroup().getParent();
		while (root.getParent() != null) {
			root = root.getParent();
		}
		getSubThreadsVisit(root, 0, threadList);
		return threadList;
	}
	public static void getSubThreadsVisit(ThreadGroup group, int level, ArrayList<Thread> threadList) {
		
		try{
			//Thread currThread = Thread.currentThread();
			
			int numThreads = group.activeCount();
			Thread[] threads = new Thread[numThreads*2];
			numThreads = group.enumerate(threads, false);
			
			//System.out.println("["+group.getName()+"] "+group.getMaxPriority());
			for (int i=0; i<numThreads; i++) {
				// Get thread
				Thread thread = threads[i];
				if (   thread!=null
					){
					threadList.add(thread);
				}
			}
			int numGroups = group.activeGroupCount();
			ThreadGroup[] groups = new ThreadGroup[numGroups*2];
			numGroups = group.enumerate(groups, false);
			for (int i=0; i<numGroups; i++) {
				getSubThreadsVisit(groups[i], level+1, threadList);
			}
		}catch(Exception e){
			System.out.println(e.getMessage());
		}
	}

	
	public static void showSubThreads(){

		System.out.println("+-------------------------------------------");
		ArrayList<Thread> threadList= getSubThreads();
		System.out.println("| Threads:");
		for (int t=0; t<threadList.size(); t++){
			Thread thread = threadList.get(t);
			System.out.println("|   "+formatSubThread(thread));
			
		}
		Thread thread = Thread.currentThread();
		System.out.println("|   current Thread:  "+formatSubThread(thread));		
		System.out.println("+-------------------------------------------");
		
	}    
    
	private static String formatSubThread(Thread thread){
		
		String t="";
		t+="["+thread.getThreadGroup().getName()+"]";
		t+=" "+thread.getName();
		t+=" "+thread.getId();
		t+=" P("+thread.getPriority()+")";
		t+=" A("+thread.isAlive()+")";
		t+=" I("+thread.isInterrupted()+")";
		t+=" D("+thread.isDaemon()+")";
		
		if (thread.getContextClassLoader()!=null){
			t+=" "+thread.getContextClassLoader().toString();
		}else{
			t+=" <null>";
		}
		if (tMXB1!=null){
			t+=" "+tMXB1.getThreadCpuTime(thread.getId());
		}
		
		//t+=" "+getSomeInfoForThreadId(thread.getId());
		
		
		
		
		
		return t;
	}

	public static String stackTraceToString(StackTraceElement [] steTab){
		StringBuilder steStr=new StringBuilder("");			
		if (steTab!=null){
			StackTraceElement ste;
			for (int i=0; i<steTab.length; i++){
				ste=steTab[i];
				if (ste!=null){
					steStr.append(ste.toString());
					steStr.append("\n");
				}
			}
		}
		steTab=null;
		return steStr.toString();
	}

  
	private static String getSomeInfoForThreadId(long id){
		
		String retStr="";
		Thread thread=null;
		ArrayList<Thread> threadList= getSubThreads();
		for (int t=0; t<threadList.size(); t++){
			thread = threadList.get(t);
			if (thread.getId()==id){
				break;
			}else{
				thread=null;
			}			
		}
		if (thread!=null){
			retStr=thread.getThreadGroup().getName();
			retStr+=" {"+thread.getClass().getName()+"}";
			
			retStr+=stackTraceToString(thread.getStackTrace());
			
			
		}
		return retStr;
	}
	
	
	
	private static String getSystemProperty(String name){
		String value=name+": ";
		try{
			value+=System.getProperty(name);
		}catch (Exception e){
		}
		return value;
	}
} 