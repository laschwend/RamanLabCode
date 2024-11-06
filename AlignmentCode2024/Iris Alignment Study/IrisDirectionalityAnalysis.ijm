filePath = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Iris Alignment Study/"
fileNames = newArray("Iris_Flor_boundary.tif", "Iris_Flor_circumfrential_top.tif", "Iris_Flor_radial.tif");
//fileNames = newArray("Interface.tiff", "Radial.tiff", "Circumfrential.tiff");



saveCsvName = "_table";

for (i = 0; i < lengthOf(fileNames); i++) {
	
	fullPath = filePath + fileNames[i]; 
			
			print(fullPath);
			
			run("Bio-Formats Importer", "open=[" + fullPath + "] color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT stitch_tiles");
			setOption("ScaleConversions", true);
			
			//open(fullPath); 
			
			// the macro code to run
			run("16-bit");
			//run("Set Scale...", "distance=442.444 known=1 unit=mm");
		
			run("Directionality", "method=[Forier Series] nbins=90 histogram_start=0 histogram_end=90 display_table");
			
			savingName = filePath +fileNames[i] + saveCsvName + ".csv"; 
			
			print(savingName);
			
			saveAs("Results", savingName);
			
			//selectImage(fullPath);
			close("*");
			
	
	
	
}
