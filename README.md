# convert-ga-tech-walking-data

The Epic Lab at Georgia Tech created a really nice open-source database of gait data collected from healthy subjects walking in a variety of conditions. The details of the data and collection procedures can be found in:

[Camargo et al., A comprehensive, open-source dataset of lower limb
biomechanics in multiple conditions of stairs, ramps, and level-ground
ambulation and transitions., Journal of Biomechanics, 2021.](https://www.sciencedirect.com/science/article/pii/S0021929021001007)

I've found myself wanting to use this dataset for a variety of projects, but as all of the files are stored as .mat files, I've been unable to load
them into Python (my scientific computing language of choice). [.mat files](https://www.mathworks.com/help/matlab/import_export/mat-file-versions.html) are a proprietary binary file format created by MathWorks for use with Matlab. It seems like there should be a way to load a .mat file into Python. There is a [function in the scipy package](https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.loadmat.html) that supposedly loads .mat files, but I couldn't make it load anything intelligible.

Instead, I decided to write a Matlab script (and set of functions) that copies the entire dataset over to another open-source file format that is compatible with Matlab, Python, and other programing languages. The file format that I've selected is Apache Parquet, which is optimized for columnar data. Details are here:

https://parquet.apache.org/

## Matlab Code

The conversion script (MAIN_Matlab.m) is pretty straightforward. It assumes that you've got the database in this directory, inside of a folder titled 'matlab data', where each subfolder is a participant's data folder. This is the same way the data is organzied when you download it from the [Epic Lab website](https://www.epic.gatech.edu/opensource-biomechanics-camargo-et-al/). You'll need to unzip each participant folder (or you could modify this code to unzip them for you). When you run this script, it will create another subdirectory called 'parquet data' that mirrors the matlab data directory and will fill each folder data. The only differences is that instead of each file being a '.mat' file, it's a '.parquet' file. Parquet files can be read by Matlab and by Python via the Pandas package. The main matlab script calls custom functions in the 'matlab functions' folder. 

The GA Tech database uses the date of the data collection as the name of one of the high level folder names. I've gathered the dates for each participant in the file 'subject_date_key.csv', and one of the functions uses this file to create the folder name.

The Main_Matlab.m script takes a really long time to run. For all 22 participants, it too my powerful desktop computer ~6 hours. I recommend running participants in batches by changing the names in the 'subjects' array in this script.

## Python Code

I've also written a simple Python script that loads and plots some of the converted data for verification (MAIN_Python.py). The data is from one subject walking on a treadmill that increases in speed partway through the trial. I've plotted treadmill speed, ground reaction force, right ankle angle, and right ankle moment. Here is the (zoomed/adjusted) plot that is generated by the Python script:

<img src="python_script_output.png" width=500>

Looks good to me! Hopefully this is useful for someone else out there. 
