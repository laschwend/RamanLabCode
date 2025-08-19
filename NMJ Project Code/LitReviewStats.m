%quick code for getting lit review stats


%Number of total NMJ Chips Referenced 

numberNMJ = sum(~isundefined(LitReview.DNMJSystem))

%number of 2d
numberNMJ2d = sum(LitReview.DNMJSystem == "2D NMJ System")

%number of 3d
numberNMJ2d = sum(LitReview.DNMJSystem == "3D NMJ System")

%number of other
numberNMJOther = sum(LitReview.DNMJSystem == "Other NMJ System")

%number of neuron only
numberNeuron = sum(LitReview.DNMJSystem == "Other NMJ System")

%make bar chart
figure(1)
vals = LitReview.DNMJSystem(~isundefined(LitReview.DNMJSystem));
catCounts = countcats(vals);
categoriesNMJ = categories(vals);

bar(catCounts)
set(gca, 'XtickLabel', categoriesNMJ);
xlabel("NMJ type")
title("Model Type")

%hydrogel types, Matrigel, Collagen, Fibrinogen, other

catNames = ["Matrigel", "Collagen", "Fibrinogen"];
catCounts = zeros(1,length(catNames));
for i = 1:length(catNames)
    catCounts(i) = sum(contains(LitReview.polyLlysineCoatingGlassPDMS, catNames(i), 'IgnoreCase', true));
end
figure(2)
bar(catCounts)
set(gca, 'XtickLabel', catNames);
xlabel("Hydrogel Type")
title("Common Hydrogels Used")


%number of iPSCs
numiPSCs = sum(contains(LitReview.None, "iPSC"))

%num c2c12
numC2C12 = sum(contains(LitReview.None, "C2C12", 'IgnoreCase',true))

%number using PDMS
numPDMS = sum(contains(LitReview.PDMSGlassSlide, "PDMS"))

%% days in culture

T = LitReview.DIVProbablyMeantsDaysInVitro; 



numberStrings = regexp(T, '\d+', 'match');

flat = [numberStrings{:}];        % flatten all matches into one cell array
numbers = str2double(flat); 


figure(3);

histogram(numbers, "BinWidth", 1);
xlabel("Days in Culture"); 
ylabel("BinCount")
title("Device Longevity");
xticks(linspace(min(numbers), max(numbers), 50));

