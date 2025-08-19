// Author: Laura Schwendeman
// Date: 8/11/2025
// Purpose: process the tif images and brighten them

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

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
	
	
	run("Bio-Formats Importer", "open=["+input + File.separator + file+"] color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT stitch_tiles");
    setOption("ScaleConversions", true);
    
    run("16-bit");
    
    getDimensions(width, height, channels, slices, frames);
    
   
	run("Enhance Contrast", "saturated=0.35");
	setMinAndMax(0, 15);
	//run("RGB Color");
    	
	
	
    
 
	saveAs("png", output + File.separator + file);
	close("*");
	
	print("Saving to: " + output);
}

