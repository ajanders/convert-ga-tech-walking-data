# -*- coding: utf-8 -*-
"""
Created on Sat Nov 11 17:38:55 2023

@author: antho
"""

import os
import time
import zipfile

extension = ".zip"
dir_name = os.getcwd()

for item in os.listdir(dir_name): 
    if item.endswith(extension): 
        print("Unzipping " + item)
        file_name = os.path.abspath(item)
        with zipfile.ZipFile(file_name, 'r') as zip_ref: 
            zip_ref.extractall(dir_name)

        # Delay before deletion
        time.sleep(1)

        # Attempt to delete with error handling
        try:
            os.remove(file_name)
        except OSError as e:
            print(f"Error: {e.filename} - {e.strerror}.")
