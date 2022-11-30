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

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import scipy.signal as sg

# %% Define data location

# get the name of the current directory
directory = os.getcwd()


# parquet data directory
root = directory+'\\Parquet Data'

# %% Figure 1: Subject AB06 IK/ID on levelground

### Define file, subject, and condition ###

# subject
subject = 'AB06'
date = "10_09_18"

# conditon
condition = 'levelground'

# file to load
file = 'levelground_ccw_normal_01_01.parquet'

### Load data as pandas dataframes ###

# load inverse kinematics data
sensor = 'ik'
ik_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
ik_data = pd.read_parquet(ik_path, engine='pyarrow')

# load metadata describing activity labels
sensor = 'conditions'
label_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
label_data = pd.read_parquet(label_path, engine='pyarrow')

### Extract signals from dataframes ###

# get joint angles
t1 = ik_data['Header']
ankle_angle = ik_data['ankle_angle_r']
knee_angle = ik_data['knee_angle_r']

# get labels
t0 = label_data['Header']
label = label_data['Label']

### Create a subplot ###

fig, axes = plt.subplots(3, 1, sharex=True, figsize=(10,6))

axes[0].plot(t0, label, '#4357AD')
axes[0].grid()
axes[0].set_ylabel('Label')
axes[0].set_title(subject+', '+file)

axes[1].plot(t0, ankle_angle, '#48A9A6')
axes[1].grid()
axes[1].set_ylabel('Ankle Angle (deg)')

axes[2].plot(t1, -knee_angle, '#C1666B')
axes[2].grid()
axes[2].set_ylabel('Knee Angle (deg)')
axes[2].set_xlabel('Time (s)')

# %% Figure 2: Subject AB15 shank IMU on treadmill

### Define file, subject, and condition ###

# subject
subject = 'AB15'
date = "11_07_2018"

# conditon
condition = 'treadmill'

# file to load
file = 'treadmill_05_01.parquet'

### Load data as pandas dataframes ###

# load inverse kinematics data
sensor = 'imu'
imu_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
imu_data = pd.read_parquet(imu_path, engine='pyarrow')

# load metadata describing activity labels
sensor = 'conditions'
label_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
label_data = pd.read_parquet(label_path, engine='pyarrow')

### Extract signals from dataframes ###

# get imu signals
t1 = imu_data['Header']
ax = imu_data['shank_Accel_X']
ay = imu_data['shank_Accel_Y']
az = imu_data['shank_Accel_Z']
gx = imu_data['shank_Gyro_X']
gy = imu_data['shank_Gyro_Y']
gz = imu_data['shank_Gyro_Z']

# get belt speed
t0 = label_data['Header']
label = label_data['Speed']

### Create a subplot ###

fig, axes = plt.subplots(3, 1, sharex=True, figsize=(10,6))

axes[0].plot(t0, label, 'k')
axes[0].grid()
axes[0].set_ylabel('Treadmill Speed (m/s)')
axes[0].set_title(subject+', '+file)

axes[1].plot(t1, ax, '#E8C547')
axes[1].plot(t1, ay, '#124E78')
axes[1].plot(t1, az, '#A63A50')
axes[1].grid()
axes[1].set_ylabel('Shank Accel (g)')

axes[2].plot(t1, gx, '#E8C547')
axes[2].plot(t1, gy, '#124E78')
axes[2].plot(t1, gz, '#A63A50')
axes[2].grid()
axes[2].set_ylabel('Shank Gyro (rad/s)')
axes[2].set_xlabel('Time (s)')
axes[2].set_xlim([42.5, 85])

# %% Figure 3: Subject AB30 on stairs

### Define file, subject, and condition ###

# subject
subject = 'AB30'
date = "03_09_2019"

# conditon
condition = 'stair'

# file to load
file = 'stair_1_r_01_01.parquet'

### Load data as pandas dataframes ###

# load inverse kinematics data
sensor = 'emg'
emg_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
emg_data = pd.read_parquet(emg_path, engine='pyarrow')

# load metadata describing activity labels
sensor = 'markers'
marker_path = root+'\\'+subject+'\\'+date+'\\'+condition+'\\'+sensor+'\\'+file
marker_data = pd.read_parquet(marker_path, engine='pyarrow')

# extract emg signals
t1 = emg_data['Header']
soleus = emg_data['soleus']
glute_med = emg_data['gluteusmedius']

soleus_rect = np.abs(soleus)
glute_med_rect = np.abs(glute_med)

b, a = sg.butter(4, 5/500)
sol_env = sg.filtfilt(b, a, soleus_rect)
glute_med_env = sg.filtfilt(b, a, glute_med_rect)

# get markers
t0 = marker_data['Header']
r_heel_y = marker_data['R_Heel_y']
r_toe_y = marker_data['R_Toe_Tip_y']

### Create a subplot ###

fig, axes = plt.subplots(3, 1, sharex=True, figsize=(10,6))

axes[0].plot(t0, r_heel_y, '#445E93', label='heel')
axes[0].plot(t0, r_toe_y, '#524632', label='toe')
axes[0].grid()
axes[0].set_ylabel('Height (mm)')
axes[0].legend()
axes[0].set_title(subject+', '+file)

axes[1].plot(t1, soleus, '#86CB92', label='raw')
axes[1].plot(t1, sol_env, 'k', label='linear envelope')
axes[1].grid()
axes[1].legend()
axes[1].set_ylabel('Soleus (mV)')

axes[2].plot(t1, glute_med, '#FE654F', label='raw')
axes[2].plot(t1, glute_med_env, 'k', label='linear envelope')
axes[2].grid()
axes[2].set_ylabel('Glute Med (mV)')
axes[2].legend()
axes[2].set_xlabel('Time (s)')