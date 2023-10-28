/*
 * MATLAB Compiler: 6.4 (R2017a)
 * Date: Tue Oct 24 13:39:32 2023
 * Arguments: 
 * "-B""macro_default""-W""java:hello,hello1""-T""link:lib""-d""E:\\MATLAB_2017a\\Project\\hello\\for_testing""class{hello1:E:\\MATLAB_2017a\\Project\\hello.m}"
 */

package hello;

import com.mathworks.toolbox.javabuilder.*;
import com.mathworks.toolbox.javabuilder.internal.*;

/**
 * <i>INTERNAL USE ONLY</i>
 */
public class HelloMCRFactory
{
   
    
    /** Component's uuid */
    private static final String sComponentId = "hello_0E5422287CBE676EE5BD67900FAE2EB8";
    
    /** Component name */
    private static final String sComponentName = "hello";
    
   
    /** Pointer to default component options */
    private static final MWComponentOptions sDefaultComponentOptions = 
        new MWComponentOptions(
            MWCtfExtractLocation.EXTRACT_TO_CACHE, 
            new MWCtfClassLoaderSource(HelloMCRFactory.class)
        );
    
    
    private HelloMCRFactory()
    {
        // Never called.
    }
    
    public static MWMCR newInstance(MWComponentOptions componentOptions) throws MWException
    {
        if (null == componentOptions.getCtfSource()) {
            componentOptions = new MWComponentOptions(componentOptions);
            componentOptions.setCtfSource(sDefaultComponentOptions.getCtfSource());
        }
        return MWMCR.newInstance(
            componentOptions, 
            HelloMCRFactory.class, 
            sComponentName, 
            sComponentId,
            new int[]{9,2,0}
        );
    }
    
    public static MWMCR newInstance() throws MWException
    {
        return newInstance(sDefaultComponentOptions);
    }
}
