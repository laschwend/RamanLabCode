// script for opening multichannel .nd2 files and then converting them to .jpg files for fusion 
// index analysis

//c2c12
//dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240530 alignment 6 good IF/40x pancakes/";
//human
dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240603 Alignment Experiment 7 - human tc twitch/20240607 alignment 7 good IF/4x stitched images/"
dirLoc = "C:/Users/laSch/Dropbox (MIT)/Raman Lab/Laura Schwendeman/20240530 alignment 6 good IF/4x stitched pics/other replicates/";

//saveLoc = dirLoc; C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240603 Alignment Experiment 7 - human tc twitch\20240607 alignment 7 good IF\4x stitched images

grooveSizes = newArray("12pt5", "25","62pt5", "125", "flat", "unstamped");

reps = newArray("1", "2", "3");

for (i = 0; i < lengthOf(grooveSizes); i++) {
	for (j = 0; j < lengthOf(reps); j++) {
		
		photoName = grooveSizes[i] + "_rep" + reps[j] + "_4x_stitched_stack-MaxIP";
		fullPathName = dirLoc + photoName; 
		
		run("Bio-Formats Importer", "open=[" + fullPathName + ".nd2] color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT stitch_tiles");
		setOption("ScaleConversions", true);
		 
		//run("8-bit");
		run("Enhance Contrast", "saturation = 0.35");
		
		//run("Merge Channels...", "c1=[C1-" + fullPathName + ".nd2] c2=[C2-" + fullPathName + ".nd2] create");
		saveAs("tiff", fullPathName + ".tif");
		
		close("*");
		
	}
		
}
