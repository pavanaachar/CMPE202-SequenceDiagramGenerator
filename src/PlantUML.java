

import java.io.File;
import java.io.IOException;
import java.util.List;

import net.sourceforge.plantuml.GeneratedImage;
import net.sourceforge.plantuml.SourceFileReader;

public class PlantUML {
	
	private String plantUMLSource;
	
	public PlantUML(String source){
		this.plantUMLSource = source;
	}
public void GenerateUML(){
	
	try{
		File UMLsource = new File(plantUMLSource);
		SourceFileReader sourcereader = new SourceFileReader(UMLsource);
		List<GeneratedImage> images = sourcereader.getGeneratedImages();
		File ClassDiagram = images.get(0).getPngFile();		
		System.out.print(ClassDiagram.getAbsolutePath());
	}
	catch(IOException e){
		e.printStackTrace();
		
	}
	
	
	
}
}
