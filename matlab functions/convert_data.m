function convert_data(subject, subject_date)
%convert_data Convert one participant's data to parquet

% input: subject -- string, e.g. "AB06"
% input: subject_date -- string, e.g. "10_09_18"

%% Create subject's directory

subject_dir = fullfile("matlab data", subject, subject_date);

%% Prepare to write paquet files

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

%% Write parquet files

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
                                       "Matlab Data",...
                                       "Parquet Data");
                                   
            parquet_file_dir = replace(parquet_file_dir,...
                                       ".mat",...
                                       ".parquet");
            
            % write the file!
            parquetwrite(parquet_file_dir, data_table)
            
        end
            
    end
    
end
end

