%% Converting GA Tech Walking Database to an Open Source Format %%

% Author: Anthony Anderson. Seattle, WA.
% Matlab 2023b

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

% example of how to run only one subject
subjects = ["AB07"];
        
%% Convert the Files

% create a csv holding participant demographic data for all participants
copy_demographic_data()

% convert data for each participant in the 'subjects' array
for subject = subjects

    % Update the command window
    fprintf("\n")
    fprintf("#### Converting data for subject "+subject+" ####")
    fprintf("\n")
    
    % Create an empty directory for this subject
    
    % this function creates an empty set of folders with the right names in
    % the 'parquet data' directory
    subject_date = create_directory_skeleton(subject);
    
    % Copy opensim data to new directory
    
    % this function copies this participant's opensim models/files over to
    % the parquet directory
    copy_opensim_files(subject);
    
    % Write parquet files for non table data
    
    % this function copies this participant's metadata files over to the
    % parquet directory. The metadata doesn't work well in parquet files
    % because it just contains a few parameters like 'stair height' or 'ramp
    % incline', so I write these to csv files instead.
    convert_metadata(subject, subject_date);
    
    % Write all data
    
    % this function copies this participant's files over to the parquet
    % directory (as parquet files).
    convert_data(subject, subject_date);
    
    % Update the command window 
    
    fprintf("\n")
    fprintf("Conversion Completed!")
    fprintf("\n")

end

%% ##### HELPER FUNCTIONS ##### %%

%% Copy Demographic Data

function copy_demographic_data()
    %copy_demographic_data Replicate the participant demographics table as
    % csv
    
    % create a directory for the converted data if it doesn't exist
    if not(isfolder("parquet data"))
        mkdir("parquet data")
    end
    
    % get the directory of the existing subject info
    dir = fullfile("matlab Data", "SubjectInfo.mat");
    
    % load the data
    data = load(dir);
    
    % extract the table
    participant_table = data.data;
    
    % write the table as a csv file in the parquet folder
    dir = fullfile("parquet data", "SubjectInfo.csv");
    writetable(participant_table, dir);

end

%% Create Directory Skeleton

function date = create_directory_skeleton(subject)
%create_directory_skeleton Build an empty nested directory to store data
%   This function creates an empty directory for the given subject that
%   other functions will fill with data. The directory created here will
%   mirror the directory in the original GA Tech dataset exactly.
%
%   The steps are:
%
%       1. Get the date the data was collected by looking it up in a csv.
%          Date is required because the second-level folder for each
%          subject is named by the date of the data collection. I created a
%          .csv file that maps subject names/identifiers to dates of data
%          collection. It is called subject_date_key.csv.
%
%       2. Define a list of folder names.
%
%       3. Write the folders in the "Parquet Data" directory under the
%          subject name.

    % Update the command window
    
    fprintf("\n")
    fprintf("Creating subject directory...")
    fprintf("\n")
    fprintf("\n")
    
    % Get date string for folder name
    
    % read date from csv for the given subject
    dates_table = readtable("subject_date_key.csv");
    date = string(dates_table{:, subject}{1});
    
    % Define folder names
    
    % first level folders to create. These are subfolders for the date.
    first_level = ["levelground", "ramp", "stair", "treadmill"];
    
    % second level folders to create. These are subfolders for each up the
    % first level folders.
    second_level = ["conditions"...
                    "emg"...
                    "fp"...
                    "gcLeft"...
                    "gcRight"...
                    "gon"...
                    "id"...
                    "ik"...
                    "imu"...
                    "jp"...
                    "markers"];
    
    % folder levels            
    lists = {first_level, second_level};
                
    % Write nested folders           
    
    % save the directory we are in now
    base = pwd;
    
    % create a directory for the converted data if it doesn't exist
    if not(isfolder("parquet data"))
        mkdir("parquet data")
    end
    
    % Change directory to new data folder
    cd("parquet data")
    
    % create a directory for this subject
    mkdir(subject)
    cd(subject)
    mkdir(date)
    mkdir("osimxml")
    cd(date)
    
    % build the cartesian product of elements of lists:
    cartprod = cell(size(lists));
    [cartprod{:}] = ndgrid(lists{:});
    
    % pass the cartesian product to fullfile to build the paths
    allpaths = fullfile(cartprod{:});
    
    %now iterate over all the paths and create a directory for each
    for pidx = 1:numel(allpaths)
      mkdir(allpaths(pidx));  
    end
    
    % return to original directory when complete
    cd(base)

end

%% Copy OpenSim Files

function copy_opensim_files(subject)
%copy_opensim_files This function copies opensim files to parquet data

% input: subject -- string, e.g. "AB06"

    % Update command window
    
    fprintf("Writing:\t"+"opensim files")
    fprintf("\n")
    fprintf("\n")
    
    % Copy files
    
    % file containing opensim files in matlab data structure
    matlab_location = fullfile("matlab Data", subject, "osimxml");
    
    % location to copy files to 
    parquet_location = fullfile("parquet Data", subject, "osimxml");
    
    % move/copy the data
    copyfile(matlab_location, parquet_location)

end

%% Convert Metadata

function convert_metadata(subject, subject_date)
%convert_metadata Convert one participant's metadata to parquet

% input: subject -- string, e.g. "AB06"
% input: subject_date -- string, e.g. "10_09_18"

    % Write metadata
    
    % first level folders to iterate over for this subject
    activities = ["levelground", "ramp", "stair", "treadmill"];
    subject_dir = fullfile("matlab data", subject, subject_date);
    
    for activity = activities
        
        % create a directory pointing to the conditions folder for this
        % activity
        activity_dir = fullfile(subject_dir, activity, "conditions");
        files = dir(fullfile(activity_dir, '*.mat'));
        num_files = length(files);
        
        fprintf("Writing:")
        fprintf("\t"+activity+" metadata")
        fprintf("\n")
        
        for i = 1:num_files
                
            % create the path to this file
            matlab_file_dir = fullfile(activity_dir, files(i).name);
    
            % load the data for this file as a struct
            data = load(matlab_file_dir);
            
            % the exact metadata varies based on walking condition, so this
            % if-elseif statement writes the appropriate data based on the 
            % activity.
            if activity == "levelground"
                
                % extract level ground metadata
                file = string(data.file);
                label_error = data.labelError;
                labels = data.labels;
                leading_leg_start = string(data.leadingLegStart{1});
                leading_leg_stop = string(data.leadingLegStop{1});
                speed = string(data.speed);
                subject = string(data.subject);
                trial_ends = data.trialEnds;
                trial_starts = data.trialStarts;
                trial_type = string(data.trialType);
                turn = string(data.turn);
    
                % create a table from the data that will fit in one
                data_table = table(file, label_error, leading_leg_start, leading_leg_stop, speed, subject, trial_ends, trial_starts, trial_type, turn);
                
            elseif activity == "ramp"
                
                file = string(data.file);
                labels = data.labels;
                ramp_incline = data.rampIncline;
                subject = string(data.subject);
                trans_leg_ascent = string(data.transLegAscent(1))+string(data.transLegAscent(2));
                trans_leg_descent = string(data.transLegDescent(1))+string(data.transLegDescent(2));
                trial_ends = data.trialEnds;
                trial_starts = data.trialStarts;
                
                data_table = table(file, ramp_incline, subject, trans_leg_ascent, trans_leg_descent, trial_ends, trial_starts);
                
            elseif activity == "stair"
                
                file = string(data.file);
                labels = data.labels;
                stair_height = data.stairHeight;
                subject = string(data.subject);
                trans_leg_ascent = string(data.transLegAscent(1))+string(data.transLegAscent(2));
                trans_leg_descent = string(data.transLegDescent(1))+string(data.transLegDescent(2));
                trial_ends = data.trialEnds;
                trial_starts = data.trialStarts;
                
                data_table = table(file, stair_height, subject, trans_leg_ascent, trans_leg_descent, trial_ends, trial_starts);
                
            elseif activity == "treadmill"
                
                labels = data.speed;
                trial_ends = data.trialEnds;
                trial_starts = data.trialStarts;
                
                data_table = table(trial_ends, trial_starts);
                
            end
            
            % create the file name with the parquet directory
            % create the path for this file in the parquet directory
            csv_file_dir = replace(matlab_file_dir,...
                                   "matlab data",...
                                   "parquet data");
                                       
            csv_file_dir = replace(csv_file_dir,...
                                   ".mat",...
                                   ".csv");
                                   
            parquet_file_dir = replace(csv_file_dir,...
                                       ".csv",...
                                       ".parquet");
            
            writetable(data_table, csv_file_dir);
            parquetwrite(parquet_file_dir, labels)
            
        end
        
    end 
    
    fprintf("\n")
end

%% Convert Data

function convert_data(subject, subject_date)
%convert_data Convert one participant's data to parquet

% input: subject -- string, e.g. "AB06"
% input: subject_date -- string, e.g. "10_09_18"

    % Create subject's directory
    
    subject_dir = fullfile("matlab data", subject, subject_date);
    
    % Prepare to write paquet files
    
    % first level folders to iterate over for this subject
    activities = ["levelground", "ramp", "stair", "treadmill"];
    
    % second level folders loop over. These folders contain data in .mat files.
    % "conditions" is left out here, becuase it contains metadata only
    sensors = ["emg"...
               "fp"...
               "gcLeft"...
               "gcRight"...
               "gon"...
               "id"...
               "ik"...
               "imu"...
               "jp"...
               "markers"];
    
    % Write parquet files
    
    % loop over each high level activity
    for activity = activities
        
        % create a reference to the directory for this activity, e.g., 
        % "Matlab Data\AB06\10_09_18\levelground"
        activity_dir = fullfile(subject_dir, activity);
        
        % The directory just created will contain folders for each sensing
        % modality in the database. E.g., EMG, IMU, etc. Now loop over
        % each sensing modality.
        for sensor = sensors
            
            sensor_dir = fullfile(activity_dir, sensor);
            files = dir(fullfile(sensor_dir, '*.mat'));
            num_files = length(files);
            
            % Within each sensor folder, there are files for each trial. We
            % Now need to loop over each file and write it as a Parquet file
            % in the mirror directory.
            fprintf("Writing:")
            fprintf("\t"+activity+" "+sensor+" data")
            fprintf("\n")
            
            for i = 1:num_files
                
                % create the path to this file
                matlab_file_dir = fullfile(sensor_dir, files(i).name);
                
                % load the data for this file as a table
                data_struct = load(matlab_file_dir);
                data_table = data_struct.data;
                
                % create the path for this file in the parquet directory
                parquet_file_dir = replace(matlab_file_dir,...
                                           "matlab data",...
                                           "parquet data");
                                       
                parquet_file_dir = replace(parquet_file_dir,...
                                           ".mat",...
                                           ".parquet");
                
                % write the file!
                parquetwrite(parquet_file_dir, data_table)
                
            end
                
        end
        
    end
end



