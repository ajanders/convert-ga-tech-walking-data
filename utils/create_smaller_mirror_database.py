# -*- coding: utf-8 -*-
"""
Created on Thu Nov  9 20:44:36 2023

@author: Anthony Anderson

# Code to make a mirrored database with selected signals, tasks, and
# participants. This is a convenience function that allow you to work with a
# much smaller version of the database if you only need imu signals, for
example.

"""

import os
import shutil

# %% Define the function to use

def extract_relevant_data(participant_id, tasks, sensors):
    """
    Extracts and copies specific sensor data for a given participant from a
    structured database into a specified destination directory.

    This function is designed to work with a database where each participant's
    data is stored in a unique folder, structured with a single date folder
    containing subfolders for different tasks and sensors. The function
    identifies the required data based on the provided participant identifier, 
    tasks, and sensors, and then copies this data into a mirrored directory
    structure in the specified destination folder.

    Assumptions:
    - The script is executed from a directory containing a 'parquet data' folder.
    - Inside the 'parquet data' folder, there are participant folders named with unique
      identifiers.
    - Each participant folder contains exactly one date folder and an 'osimxml'
      folder.
    - Inside each date folder, there are subfolders for various tasks.
    - Inside each task folder, there are subfolders for different sensor
      modalities.

    Parameters:
    - participant_id (str): The identifier of the participant (e.g., "AB07").
    - tasks (list of str): A list of tasks to extract data from (e.g.,
      ["levelground", "stair"]).
    - sensors (list of str): A list of sensors whose data is to be extracted
      (e.g., ["emg", "fp"]).

    The function creates a mirrored directory structure in the root folder and
    copies the relevant files from the specified tasks and sensors of the given
    participant.

    Example usage:
    extract_relevant_data("AB07", ["levelground", "stair"], ["emg", "fp"])
    """
    
    # Base directory where the script is run, containing the 'parquet data' folder
    base_dir = os.getcwd()

    # Path to the 'parquet data' directory
    data_dir = os.path.join(base_dir, 'parquet data')

    # Path to the participant's directory within the 'parquet data' directory
    participant_dir = os.path.join(data_dir, participant_id)

    # Check if participant directory exists
    if not os.path.exists(participant_dir):
        print(f"Participant directory {participant_id} not found.")
        return

    # Find the single date directory within the participant's folder
    date_dirs = [d for d in os.listdir(participant_dir)
                 if os.path.isdir(os.path.join(participant_dir, d))
                 and d != "osimxml"]
    if len(date_dirs) != 1:
        print(f"Unexpected number of date directories found for participant {participant_id}.")
        return
    date_dir = date_dirs[0]
    date_path = os.path.join(participant_dir, date_dir)

    # Destination directory for the extracted data
    dest_participant_dir = os.path.join(base_dir,
                                        participant_id+'_modified',
                                        date_dir)
    if not os.path.exists(dest_participant_dir):
        os.makedirs(dest_participant_dir)

    # Iterate over the specified tasks
    for task in tasks:
        task_path = os.path.join(date_path, task)

        # Check if the task directory exists
        if not os.path.exists(task_path):
            print(f"Task directory {task} not found in {date_dir}.")
            continue

        # Iterate over the specified sensors
        for sensor in sensors:
            sensor_path = os.path.join(task_path, sensor)

            # Check if the sensor directory exists
            if os.path.exists(sensor_path):
                # Define destination path
                dest_sensor_path = os.path.join(dest_participant_dir,
                                                task,
                                                sensor)

                # Create directories if they do not exist
                os.makedirs(os.path.dirname(dest_sensor_path), exist_ok=True)

                # Copy the sensor data
                shutil.copytree(sensor_path, dest_sensor_path)

    print(f"Data extraction for {participant_id} complete.")

# %% Call the function to create a mirrored database

# define participants
participants = ["AB18", "AB19", "AB20", "AB21", "AB23", "AB24", "AB25",
                "AB27", "AB28", "AB30"]

# define sensors
sensors = ["imu", "conditions", "gcRight"]

# define tasks
tasks = ["levelground", "stair", "ramp"]

for participant in participants:
    extract_relevant_data(participant, tasks, sensors)
