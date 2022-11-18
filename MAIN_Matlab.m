%% Converting GA Tech Walking Database to an Open Source Format %%

% Author: Anthony Anderson. Seattle, WA.
% Matlab 2020b

%{

The Epic Lab at Georgia Tech created a really nice open-source database of
gait data collected from healthy subjects walking in a variety of
conditions. The details of the data collection can be found in:

Camargo et al., A comprehensive, open-source dataset of lower limb
biomechanics in multiple conditions of stairs, ramps, and level-ground
ambulation and transitions., Journal of Biomechanics, 2021.

I've found myself wanting to use this dataset for a variety of projects,
but as all of the files are stored as .mat files, I've been unable to load
them into Python (my scientific computing language of choice). It seems
like there should be a way to load a .mat file into Python, but I couldn't
figure it out.

Instead, I decided to write this script that copies the entire dataset over
to another open-source file format that is compatible with Matlab, Python,
and several other programing language. The file format that I've selected
is Apache Parquet, which is optimized for columnar data. Details are here:

https://parquet.apache.org/

This script is pretty straightforward. It assumes that you've got the
database in this directory, inside of a folder titled 'matlab data', where
each subfolder is a participant's data folder. This is the same way the
data is organzied when you download it from the Epic Lab website. You'll
need to unzip each participant folder (or you could modify this code to
unzip them for you). When you run this script, it will create another
subdirectory called 'parquet data' that mirrors the matlab data directory
and will fill each folder data. The only differences is that instead of
each file being a '.mat' file, it's a '.parquet' file. Parquet files can be
read by Matlab and by Python via the Pandas package. 

The GA Tech database uses the date of the data collection as the name of
one of the high level folder names. I've gathered the dates for each
participant in the file 'subject_date_key.csv', and one of the functions
uses this file to create the folder name.

Finally, this script takes a really long time to run. For all 22
participants, it too my powerful desktop computer ~6 hours to run. I
recommend running participants in batches by changing the names in the
'subjects' array in this script. 

Hopefully this is useful to someone else!

%}

clear; close all; clc;

%% Add functions folder to path

% the folder titled 'matlab functions' contains the code that does the
% file conversions. Add that folder to the path so that they can be
% called from this script.
p = genpath('matlab functions');
addpath(p)

%% Define which participants to conver

% There are 22 participants total. The identifiers for each participant are
% listed in the array below. This script will convert the files for
% whichever subject names are present in this list. It took my desktop PC
% about six hours to convert all of them, so I recommend running these in
% batches.
subjects = ["AB06",...
            "AB07",...
            "AB08",...
            "AB09",...
            "AB10",...
            "AB11",...
            "AB12",...
            "AB13",...
            "AB14",...
            "AB15",...
            "AB16",...
            "AB17",...
            "AB18",...
            "AB19",...
            "AB20",...
            "AB21",...
            "AB23",...
            "AB24",...
            "AB25",...
            "AB27",...
            "AB28",...
            "AB30"];

% example of how to run only the two subjects
% subjects = ["AB06", "AB07"];
        
%% Convert the Files

% create a csv holding participant demographic data for all participants
copy_participant_data()

% convert data for each participant in the 'subjects' array
for subject = subjects
    % this function mirrors the subject's entire matlab directory structure
    % and fills it with Parquet files. The function will print statements
    % to the command window as it makes progress.
    convert_to_parquet(subject);
end
