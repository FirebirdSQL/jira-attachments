package test;

import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;

public class TestClassLoader {

	public static void main(String[] args) {
		try {
			URLClassLoader cl = new URLClassLoader(new URL[] { new URL("file:///C:/jaybird-full-2.1.6.jar"), new URL("file:///C:/test.jar") });
			Object test = cl.loadClass("test.TestConnection").newInstance();
			Method method = test.getClass().getMethod("main");
			method.invoke(test);
			
			cl = new URLClassLoader(new URL[] { new URL("file:///C:/jaybird-full-2.1.6.jar"), new URL("file:///C:/test.jar") });
			test = cl.loadClass("test.TestConnection").newInstance();
			method = test.getClass().getMethod("main");
			method.invoke(test);
			 
			
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
