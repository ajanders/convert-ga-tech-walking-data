function convert_metadata(subject, subject_date)
%convert_metadata Convert one participant's metadata to parquet

% input: subject -- string, e.g. "AB06"
% input: subject_date -- string, e.g. "10_09_18"

%% Write metadata

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

