// Author: Laura Schwendeman
// Date: 6/16/2025
//Purpose: To generally batch process my images in a massive super folder experiment

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
	
	for(s=0; s<nSeries; s++)
	{
	
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
    
		    // Perform Z-projection (Max Intensity)
		    if(slices > 1){
		    	run("Z Project...", "projection=[Max Intensity]");
		    	print("projecting " + c); 
		    }
		    //run("Subtract Background...", "rolling=50 light sliding");
			//run("Smooth");
		    run("Enhance Contrast", "saturated=0.35");
		    saveAs("png", output + File.separator + file + "-channel_" + c);
		    // Save projection
		    projected[c] = getTitle(); // Save title to access later
		    //close("C" + (c+1)); // Close original Z-stack
		    
		}
		
		print(projected[0]); 
		
		run("Merge Channels...", "c1=["+projected[0]+"]" + " c4=["+projected[1]+"]"); // + " c4=["+projected[2] + "]");
		
		run("Make Composite");
	
		
		run("RGB Color");
		
	}
    
 
	saveAs("png", output + File.separator + file + "_series " + s);
	close("*");
	
	}
	
	print("Saving to: " + output);
}

//to check for if a file has multiple series x-y locations 
function

