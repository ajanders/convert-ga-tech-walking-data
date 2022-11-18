# -*- coding: utf-8 -*-
"""
Converting GA Tech Epic Lab's Walking Database to Python

@author: Anthony Anderson, Seattle WA

This script verifies that the conversion from the .mat to the .parquet file
format was successful. One of the files is loaded from the converted version of
the database and some of the signals are plotted.

This works with Python 3.7.6.

"""

# %% Import packages

import pandas as pd
import matplotlib.pyplot as plt
import os

# %% Setup the participant and file

# get the name of the current directory
directory = os.getcwd()

# parquet data directory
data_dir = directory+'\\Parquet Data'

# subject
subject = 'AB12'
date = "11_04_2018"

# conditon
condition = 'treadmill'

# file to load
file = 'treadmill_02_01.parquet'

# %% Load data as pandas dataframes

# load ground reaction force data
sensor = 'fp'
grf_path = data_dir+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
grf_data = pd.read_parquet(grf_path, engine='pyarrow')

# load inverse kinematics data
sensor = 'ik'
ik_path = data_dir+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
ik_data = pd.read_parquet(ik_path, engine='pyarrow')

# load inverse dynamics data
sensor = 'id'
id_path = data_dir+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
id_data = pd.read_parquet(id_path, engine='pyarrow')

# load metadata describing treadmill speed
sensor = 'conditions'
speed_path = data_dir+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
speed_data = pd.read_parquet(speed_path, engine='pyarrow')

# %% Extract signals from dataframes

# get ground reaction force data
t0 = grf_data['Header']
Fy = grf_data['Treadmill_R_vy']

# get ankle angle
t1 = ik_data['Header']
ankle_angle = ik_data['ankle_angle_r']

# get ankle torque
t2 = id_data['Header']
ankle_moment = id_data['ankle_angle_r_moment']

# get treadmill speed
t3 = speed_data['Header']
speed = speed_data['Speed']

# %% Create a subplot

fig, axes = plt.subplots(4, 1, sharex=True)

axes[0].plot(t3, speed, '#118AB2')
axes[0].grid()
axes[0].set_ylabel('Speed (m/s)')

axes[1].plot(t0, Fy, '#EF476F')
axes[1].grid()
axes[1].set_ylabel('Ground Reaction Force (N)')

axes[2].plot(t1, ankle_angle, '#FFD166')
axes[2].grid()
axes[2].set_ylabel('Ankle Angle (deg)')

axes[3].plot(t2, ankle_moment, '#06D6A0')
axes[3].grid()
axes[3].set_ylabel('Ankle Moment (Nm)')
axes[3].set_xlabel('Time (s)')
