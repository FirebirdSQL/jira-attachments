package org.firebirdsql.gds;


import org.firebirdsql.common.SimpleFBTestBase;

import java.io.ByteArrayOutputStream;
import java.util.Arrays;

public class TestXdrOutputStream extends SimpleFBTestBase {

    public TestXdrOutputStream(String name){
        super(name);
    }

    private XdrOutputStream xdrOutStream = null;

    public void setUp(){
        xdrOutStream = new XdrOutputStream(new ByteArrayOutputStream());
    }

    public void testWrite() throws Exception {
        for (int i = 0; i < 200; i++)
        {
            byte [] arr = new byte[250];
            Arrays.fill(arr, (byte)2);
            xdrOutStream.write(arr, arr.length, 2);
        }
    }

    public void testWriteString() throws Exception {
        for (int i = 0; i < 200; i++)
        {
            char [] arr = new char[250];
            Arrays.fill(arr, 'x');
            xdrOutStream.writeString(String.valueOf(arr));
        }
    }
}


