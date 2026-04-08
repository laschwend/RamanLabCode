// Author: Laura Schwendeman
// Date: 4/7/2026
//Purpose: process z stack images and export an orthnogonal view of it 

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".nd2") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input, output);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input,output) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output + File.separator +list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	
	
	//get the number of series in a file
	run("Bio-Formats Macro Extensions"); 
	Ext.setId(input + File.separator + file); 

	Ext.getSeriesCount(nSeries);
	print(nSeries);
	//for each image in the series
	for(s=1; s<=nSeries; s++)
	{
		print("Series Num: " + s); 
	run("Bio-Formats Importer", "open=["+input + File.separator + file+"] color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + s);
    setOption("ScaleConversions", true);
    
    
    getDimensions(width, height, channels, slices, frames);
    print("Processing Series: " + s +" out of "+ nSeries);
    print("num slices: " + slices); 
    //for a normal picture, no z_stack
    if(channels == 1){
		//for no z stack
		if(slices == 1){
			//just save as .png
		}
		//for z stack
		else{
			run("Z Project...", "projection=[Max Intensity]");
		}
		//run("Subtract Background...", "rolling=50 light sliding");
		run("Smooth");
		run("Enhance Contrast", "saturated=0.35");
		run("RGB Color");
    }	
	//multiple channels
	else{
		//snagged from gpt
		projected = newArray(channels);
		names = newArray(channels);

		
		//
		ogTitle = getTitle();
		
		run("Split Channels");
		
		//get the name of the channels
		for (c = 0; c < channels; c++) {
    		selectWindow("C" + (c+1) +"-" +ogTitle);
    
		   
		    
		    //run("Subtract Background...", "rolling=50 light sliding");
			//run("Smooth");
		    //run("Enhance Contrast", "saturated=0.35");
		    //saveAs("png", output + File.separator + file + "-channel_" + c + "_series_" + s);
		    // Save projection
		    projected[c] = getTitle(); // Save title to access later
		    //close("C" + (c+1)); // Close original Z-stack
		    
//		    if(c == 0){
//		    	run("Set Measurements...", "area mean standard min max integrated redirect=None decimal=3");
//				run("Measure");
//		    }
		    
		}
		
		print(projected[0]); 
		
		//run("Merge Channels...", "c1=["+projected[0]+"]" + " c4=["+projected[1]+"]"); // + " c4=["+projected[2] + "]");
		
run("Merge Channels...", "c1=["+projected[1]+"] c3=["+projected[3]+"] c6=["+projected[2]+"]");

//selectImage("Composite");
run("Orthogonal Views");
// give ImageJ a moment to create the windows
wait(200);

// get all open window titles
titless = getList("image.titles");

// find the XZ view dynamically
for (l = 0; l < titless.length; l++) {
    if (indexOf(titless[l], "XZ") != -1) {
        selectWindow(titless[l]);
        run("Hide Overlay");
        break;
    }
}
	
		
		//run("RGB Color");
		
	
	print("here 1");
}
		
	}
    
	saveAs("png", output + File.separator + file + "_series " + s);
	close();
    
	selectWindow("Composite");
    close();
	
	
	print("here"); 
	//break;
	
//	print("Saving to: " + output);
//	selectWindow("Results");
//	saveAs("Results", output + File.separator +"results.csv");
}

//to check for if a file has multiple series x-y locations 
