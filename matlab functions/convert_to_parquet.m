function convert_to_parquet(subject)
%convert_to_parquet Convert one subject's data to the parquet format.

% input: subject -- string, e.g. "AB06"

%% Update the command window

fprintf("\n")
fprintf("#### Converting data for subject "+subject+" ####")
fprintf("\n")

%% Create an empty directory for this subject

% this function creates an empty set of folders with the right names in the
% 'parquet data' directory
subject_date = create_directory_skeleton(subject);

%% Copy opensim data to new directory

% this function copies this participant's opensim models/files over to the
% parquet directory
copy_opensim_files(subject);

%% Write parquet files for non table data

% this function copies this participant's metadata files over to the
% parquet directory. The metadata doesn't work well in parquet files
% because it just contains a few parameters like 'stair height' or 'ramp
% incline', so I write these to csv files instead.
convert_metadata(subject, subject_date);

%% Write all data

% this function copies this participant's files over to the parquet
% directory (as parquet files).
convert_data(subject, subject_date);

%% Update the command window 

fprintf("\n")
fprintf("Conversion Completed!")
fprintf("\n")

end

