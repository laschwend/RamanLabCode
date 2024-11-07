//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Tamara Rossy/Results/2024/Alignment project/20240202 Alignment experiment 4/20240208 DM++ d5 - estim/Converted_Videos/";

//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Tamara Rossy/Results/2024/Alignment project/20240213 Alignment experiment 5/20240221 diff d6 e-stim/Converted_Videos/";
//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240530 alignment 6 good IF/4x stitched pics/other replicates/";
dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240603 Alignment Experiment 7 - human tc twitch/20240607 alignment 7 good IF/4x stitched images/"
macroPathAndName = "";

grooveSizes = newArray( "12pt5", "25", "62pt5", "125", "flat", "unstamped");

reps = newArray("1", "2", "3");

//locations = newArray("R", "center", "L", "top", "bottom");
locations = newArray("");

saveName = "_table.csv";

saveLoc = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_3/"

//print(lengthOf(grooveSizes)); 
fileNames = newArray(lengthOf(grooveSizes)*lengthOf(reps)*(lengthOf(locations)));

//now loop through all the files

for (i = 0; i < lengthOf(grooveSizes); i++) {
	for (j = 0; j < lengthOf(reps); j++) {
		for (k = 0; k < lengthOf(locations); k++) {
			
			//make the folder name
			//folderName = grooveSizes[i] + "_rep" + reps[j] + "_4x_stitched_stack" + locations[k] + "-MaxIP";
			folderName = grooveSizes[i] + "_rep" + reps[j] + "4x_fullWellFiltered";
			
			photoName = ".tif"; 
			
			fullPath = dirLoc + folderName + photoName; 
			
			print(fullPath);
			
			run("Bio-Formats Importer", "open=[" + fullPath + "] color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT stitch_tiles");
			setOption("ScaleConversions", true);
			
			//open(fullPath); 
			
			// the macro code to run
			run("16-bit");
			//run("Set Scale...", "distance=442.444 known=1 unit=mm");
			makeRectangle(1000, 1704, 5000, 3660);
			run("Crop");
			
			run("Directionality", "method=[Local gradient orientation] nbins=90 histogram_start=0 histogram_end=180 display_table");
			
			savingName = saveLoc + folderName + saveName + ".csv"; 
			
			print(savingName);
			
			saveAs("Results", savingName);
			
			//selectImage(fullPath);
			close("*");
			
		}

	}

}