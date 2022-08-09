## AspectJ Code Generator Outputs

### Output Directory Structure

Below is the sample output directory structure created by the Java tool chain for the demo application. The AspectJ definitions and other artifacts, along with the original application, for each enclave is placed in a separate directory. In addition, the HAL configuration files (xdconf.ini and hal_*.cfg) are put at the top level.

![](docs/Java/images/output.png){#codeGenOutput}

Inside each enclave, AspectJ related files are placed under the aspect subdirectory. Below is a sample for the purple enclave.

![](docs/Java/images/purple.png){#purple}


### Sample AspectJ for the VideoRequesterHighClosureAspect Class {#video.aspectj}
The following is the AspectJ definition generated for the VideoRequesterHighClosure class, which is located in the orange enclave and accessed from the purple enclave in the partititoned demo application.

```java
package com.peratonlabs.closure.aspectj;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;

import org.aspectj.lang.reflect.ConstructorSignature;
import org.aspectj.lang.reflect.MethodSignature;

import com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh;
import com.peratonlabs.closure.remote.ClosureRemoteRMI;
import com.peratonlabs.closure.remote.ClosureShadow;

public aspect VideoRequesterHighClosureAspect {
    // declare error : noInstance() : "Instantiation of the VideoRequesterHigh class is not allowed in this enclave";

    declare precedence: purple_E, *;
    
    public void invalid(String message) {
        throw new RuntimeException(message);
    }
    
    // constructor invocation
    VideoRequesterHigh around(Object myObject) : call(VideoRequesterHigh.new(..)) && !within(VideoRequesterHighClosureAspect) && this(myObject) {
        ConstructorSignature signature = (ConstructorSignature) thisJoinPoint.getSignature();
        invalid("Not allowed to call the constructor: " + signature);

        return null;
    }
    
    // constructor execution: this also captures invocation via reflection
    Object around(Object myObject) : execution(VideoRequesterHigh.new(..)) && this(myObject) {
        ConstructorSignature signature = (ConstructorSignature) thisJoinPoint.getSignature();
        invalid("Not allowed to invoke this Constructor " + signature);
        return null;
    }

    // object finalization
    after(Object myObject) : execution(void VideoRequesterHigh.finalize()) && this(myObject) {
        ConstructorSignature signature = (ConstructorSignature) thisJoinPoint.getSignature();
        invalid("Not allowed to call finalize() " + signature);
    }
    
    /******* fields *******/
    // all class or instance field reads
    private pointcut fieldGet() : get(* com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.*) && !within(com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh);
    declare error : fieldGet() : "direct read from VideoRequesterHigh's fields is not allowed in this enclave. Use a getter";

    // all instance field writes
    private pointcut fieldSet() : set(* com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.*) && !within(com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh);
    declare error : fieldSet() : "direct write to VideoRequesterHigh's fields is not allowed in this enclave. Use a setter";
    
    // all field reads via reflection
    Object around(Field field, Object myObject):
        call(public Object Field.get(Object)) && 
        target(field) && 
        args(myObject) {
       
        Object result = null;
        if (field.getDeclaringClass() == com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.class)
            result = proceed(field, myObject);
        else {
            invalid("Not allowed to read field via reflection: com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh." + field.getName());
        }
        
        return result;
    }
    
    // all field writes via reflection
    void around(Field field, VideoRequesterHigh myObject, Object newValue): 
         call(public void Field.set(Object, Object)) && 
         target(field) &&
         args(myObject, newValue) {
        
        //Object result = null;
        if (field.getDeclaringClass() == com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.class)
            proceed(field, myObject, newValue);
        else {
            invalid("Not allowed to write field via reflection: com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh."  + field.getName());
        }
    }
    
    // static field reads via reflection
    Object around(Field field):
        call(public Object Field.get(Object)) && 
        target(field) {
       
        Object result = null;
        if (field.getDeclaringClass() == com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.class)
            result = proceed(field);
        else {
            invalid("Not allowed to read static field via reflection: com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh." + field.getName());
        }
        
        return result;
    }
    
    // all static field writes via reflection
    void around(Field field, Object newValue): 
         call(public void Field.set(Object, Object)) && 
         target(field) &&
         args(newValue) {
        
        if (field.getDeclaringClass() == com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.class)
            proceed(field, newValue);
        else {
            invalid("Not allowed to write static field via reflection: com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh."  + field.getName());
        }
    }
    
    /******* Method Invocations **********/
    
    // method invocation/execution
    private pointcut methodExec() : execution(* VideoRequesterHigh.*(..));
    
    // method invocation/execution: this also captures invocations via reflection
    Object around(Object myObject): methodExec() && target(myObject) {
        MethodSignature signature = (MethodSignature) thisJoinPoint.getSignature();
        
        invalid("Not allowed to invoke this method " + signature);
        
        return null;
    }
    
    // static method invocation/execution
    private pointcut staticMethod(): execution(static * VideoRequesterHigh.*());

    Object around(): staticMethod() {
        MethodSignature signature = (MethodSignature) thisJoinPoint.getSignature();

        invalid("Not allowed to invoke static method " + signature);
        
        return null;
    }
}
```

### ZeroMQ URL (ipc.txt) {#zeromq}
The ipc.txt file is loaded at application startup time to connect to the ZeroMQ for publication and subscriptions. The following is a sample for the purple enclave.
```
ipc:///tmp/tchalsubpurple_e
ipc:///tmp/tchalpubpurple_e
```

### XDCC Tags (tags.txt){#xdcc-tags}
The tags.txt file is loaded at application startup time to initialize mux/sec/type of cross-domain calls.
```
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String 4 4 1
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String_rsp 6 6 2
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String 3 3 3
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String_rsp 1 1 4
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest 4 4 5
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest_rsp 6 6 6
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest 3 3 7
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest_rsp 1 1 8
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[] 4 4 9
com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[]_rsp 6 6 10
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[] 3 3 11
com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[]_rsp 1 1 12
```

### Ant Build for AspectJ Weaving{#ant}
An ant build file, build-closure.xml, is generated to handle the AspectJ weaving task.
```xml
<project name="Build app and aspect lib then weave" default="weave">
  <property file="./build.properties"/>
  
  <taskdef classpath="${aspectj.home}/lib/aspectjtools.jar"
           resource="org/aspectj/tools/ant/taskdefs/aspectjTaskdefs.properties"/>
  
  <path id="project.class.path">
      <pathelement location="${aspectj.home}/lib/aspectjrt.jar"/>
      <pathelement location="${aspectj.home}/lib/codeGen.jar"/>
      <pathelement location="dist/TESTPROGRAM.jar"/>
      <fileset dir="./lib">
        <include name="**/*.jar" />
      </fileset>
  </path>

  <!-- build the CLOSURE aspectj library -->
  <target name="compile">
    <mkdir dir="dist" />
    <iajc 
      source="1.5" 
      classpathref="project.class.path" 
      outjar="dist/closure-aspect.jar" 
      xlintfile="xlint.properties">
      <sourceroots>
        <pathelement location="aspect" />
      </sourceroots>
    </iajc>
  </target>
  
  <target name="initialize" depends="compile">
    <mkdir dir="dist" />
    <copy todir="dist">
      <fileset dir="./dist">
        <include name="TESTPROGRAM.jar" />
      </fileset>
      <fileset dir="./dist">
        <include name="closure-aspect.jar" />
      </fileset>
    </copy>
  </target>

    <!-- weave the app and the CLOSURE aspectj library -->
  <target name="weave" depends="initialize">
    <mkdir dir="dist" />
    <iajc injars="dist/TESTPROGRAM.jar"
          aspectpath="dist/closure-aspect.jar"
          outjar="dist/weaved-TESTPROGRAM.jar"
          classpathref="project.class.path">
    </iajc>
    <delete file="dist/TESTPROGRAM.jar"/> 
  </target>  
</project>
```

### Slave Handler{#slave-handler}
The slave handler is used to listen for cross domain calls. It replaces the entrypoint of the original app via a AspectJ pointcut.

```java
package com.peratonlabs.closure.aspectj;

import com.peratonlabs.closure.remote.ClosureRemoteHalSlave;

public aspect VideoManagerMainAspect {
    // static method invocation/execution
    private pointcut staticMain(): execution(public static void com.peratonlabs.closure.eop2.video.manager.VideoManager.main(String[]));

    Object around(): staticMain() {
        ClosureRemoteHalSlave.init();
        return null;
    }
}
```

### Sample Config for CodeGenJava{#config.json}
Below is a sample configuration file for the CodeGenJava tool.
```json
{
  "dstDir": "/home/closure/xdcc",
  "cut": "test/cut.json",
  
  "srcDir": "/home/closure/gaps/capo/Java/examples/eop2-demo",
  "codeDir": ".",
  "jar": "TESTPROGRAM",
  "compile": true,
  
  "halCfg": "/home/closure/gaps/hal/java-eop2-demo-hal/hal_autoconfig-multienclave.py",
  "deviceFile": "/home/closure/gaps/hal/java-eop2-demo-hal/devices_eop2_java_alllocal.json"
}

```