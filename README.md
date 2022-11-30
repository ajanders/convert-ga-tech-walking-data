# convert-ga-tech-walking-data

The Epic Lab at Georgia Tech created a really nice open-source database of gait data collected from healthy subjects walking in a variety of conditions.
The details of the data and collection procedures can be found in:

[Camargo et al., A comprehensive, open-source dataset of lower limb
biomechanics in multiple conditions of stairs, ramps, and level-ground
ambulation and transitions., Journal of Biomechanics, 2021.](https://www.sciencedirect.com/science/article/pii/S0021929021001007)

I've found myself wanting to use this dataset for a variety of projects, but as all of the files are stored as .mat files, I've been unable to load
them into Python (my scientific computing language of choice). [.mat files](https://www.mathworks.com/help/matlab/import_export/mat-file-versions.html) are
a proprietary binary file format created by MathWorks for use with Matlab. It seems like there should be a way to load a .mat file into Python. There is a
[function in the scipy package](https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.loadmat.html) that supposedly loads .mat files, but I couldn't
make it load anything intelligible.

Instead, I decided to write a Matlab script (and set of functions) that copies the entire dataset over to another open-source file format that is compatible
with Matlab, Python, and other programing languages. The file format that I've selected is Apache Parquet, which is optimized for columnar data. Details are here:

https://parquet.apache.org/

## Matlab Code

The conversion script (MAIN_Matlab.m) is pretty straightforward. It assumes that you've got the database in this directory, inside of a folder titled 'matlab data', where each
subfolder is a participant's data folder. This is the same way the data is organzied when you download it from the
[Epic Lab website](https://www.epic.gatech.edu/opensource-biomechanics-camargo-et-al/). You'll need to unzip each participant folder (or you could modify this code to unzip them
for you). When you run this script, it will create another subdirectory called 'parquet data' that mirrors the matlab data directory and will fill each folder data. The only
differences is that instead of each file being a '.mat' file, it's a '.parquet' file. Parquet files can be read by Matlab and by Python via the Pandas package. The main matlab
script calls custom functions in the 'matlab functions' folder. 

The GA Tech database uses the date of the data collection as the name of one of the high level folder names. I've gathered the dates for each participant in the file
'subject_date_key.csv', and one of the functions uses this file to create the folder name.

The Main_Matlab.m script takes a really long time to run. For all 22 participants, it took my powerful desktop computer ~6 hours. I recommend running participants in batches by
changing the names in the 'subjects' array in this script.

The script "verification_plots.m" creates three subplots of the matlab data that can be compared to data from the converted parquet database to verify that the conversion worked.
These figures are shown below. 

## Python Code

I've also written a simple Python script that loads and plots the same three files from the parquet database (MAIN_Python.py). The figures from each database show good agreement
and are shown below:

### AB06 Levelground Walking

Matlab:

<img src="img/AB06_levelground_ccw_normal_01_01_matlab.png" width=500>

Python:

<img src="img/AB06_levelground_ccw_normal_01_01_python.png" width=500>

This trial contained data from one subject walking on levelground with two turns. The top row shows the activity labels for the trial, the middle and bottom rows show the ankle
and knee angles, respectively, as calculated with OpenSim's inverse kinematics tools.

### AB15 Treadmill Walking

Matlab:

<img src="img/AB15_treadmill_05_01_matlab.png" width=500>

Python:

<img src="img/AB15_treadmill_05_01_python.png" width=500>

This trial contained data from another subject walking on a treadmill at multiple speeds. The top row shows treadmill speed. The middle row shows three channels of acceleration
data from a shank-mounted IMU. The bottom row shows the gyroscope data from the same IMU.

### AB30 Stair Climbing

Matlab:

<img src="img/AB30_stair_1_r_01_01_matlab.png" width=500>

Python:

<img src="img/AB30_stair_1_r_01_01_python.png" width=500>

This trial contained data from a third subject climbing and descending a flight of stairs. The top row shows the heel/toe motion capture marker height over time. The middle and
bottom rows show the EMG signals from the soleus and gluteus medius. I've also computed and plotted the linear envelope for the two signals.

Across all three randomly selected trials, the .mat and .parquet files show good agreement, so I'm reasonably certain there are no bugs. Hopefully this is useful for someone
else out there. 
