// ImageJ macro lsm2nrrdR.ijm
// Designed to open and rotate 2 channel LSM (or tif) image stacks and output 2 NRRD files
// Written by Robert Court - r.court@ed.ac.uk 

Angle = 45; // leave positive - rotation direction automated.

name = getArgument;
if (name=="") exit ("No argument!");
setBatchMode(true);

//run("LSM Reader", "open=[" + name + "]");
open(name);
wait(800);
ch1 = replace(replace(name, ".tif", ".lsm"), ".lsm", "-PP_C1.nrrd");
ch2 = replace(replace(name, ".tif", ".lsm"), ".lsm", "-PP_C2.nrrd");
logfile = replace(name, ".lsm", "-PP_Meta.log");
run("Split Channels");
wait(800);
slices = 0;
// we need to know only how many slices there are
getDimensions(dummy, dummy, dummy, slices, dummy);
run("Grouped Z Project...", "projection=[Max Intensity] group="+slices);
wait(300);
getMinAndMax(hmin, hmax);
wait(100);
levlog="Ch2:"+d2s(hmin,0)+","+d2s(hmax,0);
print ("Original background (min,max): " + d2s(hmin,0) + "," + d2s(hmax,0));
run("Enhance Contrast", "saturated=0.35");
wait(300);
getMinAndMax(hmin, hmax);
wait(100);
levlog=levlog+"->"+d2s(hmin,0)+","+d2s(hmax,0)+".";
print ("Adjusted to (min,max): " + d2s(hmin,0) + "," + d2s(hmax,0));


// check rotation direction
Iw = getWidth();
Ih = getHeight();
Imp = round(Iw/2);
Itp = round(Ih/10);
Iw = Iw -1;
makeRectangle(1, 1, Imp, Itp);
getStatistics(dummy, Lm);
makeRectangle(Imp, 1, Iw, Itp);
getStatistics(dummy, Rm);
if (Lm > Rm){
    Angle = Angle;
    print ("rotating clockwise " + d2s(Angle,0) + "degrees");
}else{
    print ("rotating anti-clockwise " + d2s(Angle,0) + "degrees");
    Angle = (360 - Angle);
}

close();
wait(300);
setMinAndMax(hmin, hmax);
wait(300);

run("Rotate... ", "angle=Angle grid=1 interpolation=Bilinear enlarge stack"); //remove diagonal tilt
wait(800);

levlog=levlog+"[A:" + d2s(Angle,0) + "]";

wait(300);
run("8-bit");
wait(300);
run("Nrrd ... ", "nrrd=[" + ch2 + "]");
wait(800);
close();
wait(100);
run("Grouped Z Project...", "projection=[Max Intensity] group="+slices);
wait(300);
getMinAndMax(hmin, hmax);
wait(100);
levlog=levlog+"Ch1:"+d2s(hmin,0)+","+d2s(hmax,0);
print ("Original signal (min,max): " + d2s(hmin,0) + "," + d2s(hmax,0));
run("Enhance Contrast", "saturated=0.35");
wait(300);
getMinAndMax(hmin, hmax);
wait(100);
levlog=levlog+"->"+d2s(hmin,0)+","+d2s(hmax,0)+".";
print ("Adjusted to (min,max): " + d2s(hmin,0) + "," + d2s(hmax,0));


close();
wait(300);
setMinAndMax(hmin, hmax);
wait(300);
run("Rotate... ", "angle=Angle grid=1 interpolation=Bilinear enlarge stack"); //remove diagonal tilt
wait(800);

levlog=levlog+"[A:" + d2s(Angle,0) + "]";


wait(300);
run("8-bit");
wait(300);
run("Nrrd ... ", "nrrd=[" + Ch1 + "]");
wait(800);
close();

File.saveString(levlog+"\r\n", logfile);

run("Quit");

