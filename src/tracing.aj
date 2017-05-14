import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import org.aspectj.lang.reflect.MethodSignature;
import org.aspectj.lang.reflect.CodeSignature;

import net.sourceforge.plantuml.GeneratedImage;
import net.sourceforge.plantuml.SourceFileReader;

public aspect tracing {
	private ArrayList<String> umlsrc = new ArrayList<String>();	
	private int callDepth;
	private final String PATH = "C:\\Users\\Pavana\\Desktop\\202-DEMO-DAY\\sequence.txt";
	private final String NULL_CLASS = "null_class";
	Stack<String> stack = null;

	tracing() {
		umlsrc.add("@startuml");
		umlsrc.add("autonumber");
		stack = new Stack<String>();
		stack.push(NULL_CLASS);
	}

	pointcut traced(): !within(tracing) && (execution(public * *.*(..)));

	before():traced() {
		// Class name of the called method
		String className;
		try {
			System.out.println(thisJoinPoint.getThis().getClass().getName());
			className = thisJoinPoint.getThis().getClass().getName();
		} catch(NullPointerException e) {
			className = thisJoinPoint.getSignature().getDeclaringTypeName();
		}
		
		// Name of the function called 
		String funcName = thisJoinPoint.getSignature().getName();
		// Return type of the function
		String returnType = ((MethodSignature)thisJoinPoint.getSignature()).getReturnType().getSimpleName();
		// Names of parameters passed to the function
		String[] paramNames = ((CodeSignature) thisJoinPointStaticPart.getSignature()).getParameterNames();
		// Types of the parameters passed 
		Class[] paramTypes = ((CodeSignature) thisJoinPointStaticPart.getSignature()).getParameterTypes();

		// Boolean to check if multiple parameters are passed
		boolean multiple = false;

		String s = "(";
		for(int i = 0; i < paramNames.length; i++){
			if (multiple) {
				s += ", "; 
			}
			s = s + paramNames[i] + " : " + paramTypes[i].getSimpleName();
			multiple = true;
		}	

		s += ") :" + returnType;

		String lastClass = stack.peek();

		if (lastClass.equals(NULL_CLASS)) {
			umlsrc.add("[-> " + className + ": " + funcName + s);
		}
		else {
			umlsrc.add(lastClass + " -> " + className + ": " + funcName + s);
		}
		stack.push(className);
		umlsrc.add("activate " + className);
		callDepth++;
	}

	after()returning(Object r): traced(){
		String className;
		try {
			System.out.println(thisJoinPoint.getThis().getClass().getName());
			className = thisJoinPoint.getThis().getClass().getName();
		} catch(NullPointerException e) {
			className = thisJoinPoint.getSignature().getDeclaringTypeName();
		}
		
		callDepth--;

		stack.pop();

		String lastClass = stack.peek();
		String s = "";
		if (lastClass.equals(NULL_CLASS)) {
			s = "[<--";
		} 
		else {
			s = lastClass + " <-- "; 
		}
		s+=className;

		if(r!=null){
			s+=":"+r;
		}

		umlsrc.add(s);

		umlsrc.add("deactivate " + className);
		if (callDepth == 0) {
			umlsrc.add("@enduml");
			writer();
			GenerateUML();
		}
	}


	public void writer(){
		PrintWriter filewriter = null;
		try {
			filewriter = new PrintWriter(PATH);
			for(int i = 0; i<umlsrc.size();i++){
				filewriter.println(umlsrc.get(i));
			}
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		finally{
			filewriter.close();
		}
	}

	public void GenerateUML(){
		try{
			File UMLsource = new File(PATH);
			SourceFileReader sourcereader = new SourceFileReader(UMLsource);
			List<GeneratedImage> images = sourcereader.getGeneratedImages();
			File Sequence = images.get(0).getPngFile();		
			System.out.print("Sequence diagram generated at: "+Sequence.getAbsolutePath());
		}
		catch(IOException e){
			e.printStackTrace();
		}
	}
}
