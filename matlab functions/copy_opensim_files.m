function copy_opensim_files(subject)
%copy_opensim_files This function copies opensim files to parquet data

% input: subject -- string, e.g. "AB06"

%% Update command window

fprintf("Writing:\t"+"opensim files")
fprintf("\n")
fprintf("\n")

%% Copy files

% file containing opensim files in matlab data structure
matlab_location = fullfile("matlab Data", subject, "osimxml");

% location to copy files to 
parquet_location = fullfile("parquet Data", subject, "osimxml");

% move/copy the data
copyfile(matlab_location, parquet_location)

end