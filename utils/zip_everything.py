# -*- coding: utf-8 -*-
"""
Created on Sat Nov 11 19:41:04 2023

@author: Anthony Anderson

This function will zip all of the folders in a directory and delete the
folders. It is useful when moving the entire database around.

This script should be placed in the same directory as all of the folders to be 
zipped and run from there.

"""

import os
import shutil
import zipfile

def zip_folder(folder_path, output_path):
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                zipf.write(os.path.join(root, file),
                           os.path.relpath(os.path.join(root, file),
                           os.path.join(folder_path, '..')))

dir_name = os.getcwd() # Directory from which to zip folders

for item in os.listdir(dir_name):
    item_path = os.path.join(dir_name, item)
    if os.path.isdir(item_path):
        print(f"Zipping folder: {item}")
        output_zip_path = os.path.join(dir_name, f"{item}.zip")
        try:
            zip_folder(item_path, output_zip_path)
            print(f"Created: {output_zip_path}")
            # Delete the folder after zipping
            shutil.rmtree(item_path)
            print(f"Deleted folder: {item_path}")
        except Exception as e:
            print(f"Error processing {item_path}: {e}")
