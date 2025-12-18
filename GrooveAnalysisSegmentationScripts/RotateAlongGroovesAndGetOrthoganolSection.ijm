// code for rotating images automatically
fileName = "B3_r3_D0_20x-Denoised"

//run("Directionality", "stackprojection=bins=90 method=fourier display_table");

tableName = "Directionality histograms for " + fileName + " (using Fourier components)";   // adjust based on what you see
selectWindow(tableName);

// Get headings
headings = Table.headings;
print(headings)

headings_split = split(headings, "z");

// Loop through rows
rows = Table.size;

print(headings_split[0])

for (i = 0; i < rows; i++) {
    angles = Table.get(headings_split[0], i);
    hist  = Table.get("z" + headings_split[1], i);
    print(angles + "\t" + hist);
}