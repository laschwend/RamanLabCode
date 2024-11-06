
#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix

list = getFileList(input);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
		
		print(list[i]);
		
			
		if(endsWith(list[i], suffix))
			{
				processFile(input, list[i]);
			}
	}

function processFile(input, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	open(file);
	run("Enhance Contrast", "saturation = 0.2");

	//run("Set Scale...", "distance=.442444 known=1 unit=um");
	run("Set Scale...", "distance=1.137686 known=1 unit=um");
	run("Scale Bar...", "width=200 height=200 thickness=10 font=60 bold overlay");
	saveAs("PNG", input + File.separator + file);
}



