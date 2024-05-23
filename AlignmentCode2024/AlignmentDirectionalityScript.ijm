//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Tamara Rossy/Results/2024/Alignment project/20240202 Alignment experiment 4/20240208 DM++ d5 - estim/Converted_Videos/";

dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Tamara Rossy/Results/2024/Alignment project/20240213 Alignment experiment 5/20240221 diff d6 e-stim/Converted_Videos/";

macroPathAndName = "";

grooveSizes = newArray("unstamped", "flat","12pt5","62pt5", "125");

reps = newArray("1", "2", "3");

locations = newArray("R", "center", "L", "top", "bottom");

saveName = "table.csv";

saveLoc = "C:/Users/laSch/Desktop/Raman Lab/AligmentProject2024Code/Directionality Tables Human/"

//print(lengthOf(grooveSizes)); 
fileNames = newArray(lengthOf(grooveSizes)*lengthOf(reps)*(lengthOf(locations)));

//now loop through all the files

for (i = 0; i < lengthOf(grooveSizes); i++) {
	for (j = 0; j < lengthOf(reps); j++) {
		for (k = 0; k < lengthOf(locations); k++) {
			
			//make the folder name
			folderName = grooveSizes[i] + "_rep" + reps[j] + "_10x_" + locations[k] + "_7.0-10.0sec";
			
			photoName = "/frame_0210.tiff"; 
			
			fullPath = dirLoc + folderName + photoName; 
			
			print(fullPath);
			
			open(fullPath); 
			
			// the macro code to run
			run("16-bit");
			run("Set Scale...", "distance=442.444 known=1 unit=mm");
			run("Directionality", "method=[Fourier components] nbins=90 histogram_start=0 histogram_end=180 display_table");
			
			savingName = saveLoc + folderName + saveName + ".csv"; 
			
			print(savingName);
			
			saveAs("Results", savingName);
			
			selectImage("frame_0210.tiff");
			close();
			
		}

	}

}