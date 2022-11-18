function copy_participant_data()
%copy_participant_data Replicate the participant demographics table as csv

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

