function date = create_directory_skeleton(subject)
%create_directory_skeleton Build an empty nested directory to store data
%   This function creates an empty directory for the given subject that
%   other functions will fill with data. The directory created here will
%   mirror the directory in the original GA Tech dataset exactly.
%
%   Created by Anthony Anderson
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

%% Update the command window

fprintf("\n")
fprintf("Creating subject directory...")
fprintf("\n")
fprintf("\n")

%% Get date string for folder name

% read date from csv for the given subject
dates_table = readtable("subject_date_key.csv");
date = string(dates_table{:, subject}{1});

%% Define folder names

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
            
%% Write nested folders           

% save the directory we are in now
base = pwd;

% create a directory for the converted data if it doesn't exist
if not(isfolder("Parquet Data"))
    mkdir("Parquet Data")
end

% Change directory to new data folder
cd("Parquet Data")

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

