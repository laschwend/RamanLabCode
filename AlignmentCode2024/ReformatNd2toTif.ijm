// script for opening multichannel .nd2 files and then converting them to .jpg files for fusion 
// index analysis

//c2c12
//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240530 alignment 6 good IF/40x pancakes/";
splitName = "-C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240...lignment 6 good IF/40x pancakes/";
//human
dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240603 Alignment Experiment 7 - human tc twitch/40x pancakes/"
splitName = "-C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240...iment 7 - human tc twitch/40x pancakes/"

//saveLoc = dirLoc; 
//these should match the file convention
grooveSizes = newArray("12pt5","25", "6pt25", "125","flat", "unstamped");

reps = newArray("1", "2", "3");

for (i = 0; i < lengthOf(grooveSizes); i++) {
	for (j = 0; j < lengthOf(reps); j++) {
		
		//get the name of the photo based of rep and groove size
		photoName = grooveSizes[i] + "_rep" + reps[j] + "_40x_pancake";
		fullPathName = dirLoc + photoName; 
		
		//open the image file -- opens .nd2
		run("Bio-Formats Importer", "open=[" + fullPathName + ".nd2] color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT stitch_tiles");
		setOption("ScaleConversions", true);
		 
		//split all the color channels
		//run("8-bit");
		run("Split Channels");
		
		//save the nuclei channel
		selectImage("C1" + splitName + photoName + ".nd2");
		run("Enhance Contrast", "saturation = 0.35");
		//run("Merge Channels...", "c1=[C1-" + fullPathName + ".nd2] c2=[C2-" + fullPathName + ".nd2] create");
		saveAs("tiff", fullPathName + "_nuclei.tif");
		
		//save the fiber channel
		selectImage("C2" + splitName + photoName + ".nd2");
		run("Enhance Contrast", "saturation = 0.35");
		//run("Merge Channels...", "c1=[C1-" + fullPathName + ".nd2] c2=[C2-" + fullPathName + ".nd2] create");
		saveAs("JPEG", fullPathName + "_fibers.jpg");
		
		//save the brightfield channel -- sometimes is easier to trace if the staining is bad
		selectImage("C3" + splitName + photoName + ".nd2");
		run("Enhance Contrast", "saturation = 0.35");
		saveAs("JPEG", fullPathName + "_fibersBrightField_.jpg");
		
		//close("*");
		
	}
		
}
