%General pipeline for LFPs data generation, processing and visualization, recorded from the %Medotronic Percept PC neurostimulator, implanted in the Anterior Nucleus of the Thalamus of %epilepsy patients
% @Elodie Lopes (elodie.m.lopes@inesctec.pt)
% Doctoral Program of Biomedical Engineering - FEUP
% Supervisor: João Paulo Cunha (INESC TEC, Porto, Portugal)
% 2024

clear all  
clc  

%========================= INPUTS AND PATH DIRECTORIES =========================

% User-defined patient and hospital information
hospital = 'HSJ';  % Hospital name (e.g. HSJ - Hospital São João)
PatID = 'PD01';  % Patient ID (e.g., PD01)

% Define the directory paths for the different data files based on the patient and hospital.
% The paths are tailored for a MacOS system in this case.

code_dir = pwd;  % Get the current working directory (path of the code)
cc = code_dir(1:56);  % Extract the first 56 characters from the current directory
patient_dir = [cc, '/DATA/', hospital, '/', PatID];  % Create the patient directory path

% Define specific sub-directories for the data, MATLAB files, and documentation
dir_data = [patient_dir, '/JsonFiles'];  % Directory for raw data files
dir_matFiles = [patient_dir, '/matFiles'];  % Directory for output .mat files
dir_timeline = [patient_dir, '/ClinicalTimeline'];  % Directory for clinical timeline files
dir_docs = [patient_dir, '/Docs'];  % Directory for storing documentation (e.g., EDF files)

% Add the MATLAB packages directory to the path (for MacOS)
addpath([code_dir, '/Matlab_Packages']);  
% Include necessary MATLAB functions and packages for processing
% The MATLAB package includes functions for electrophysiological data preprocessing and visualization.
% It should contain the 'joyPlot' and 'Electrophysiological-Data-Preprocessing-Visualization' functions.
% joyPlot could be found: https://www.mathworks.com/matlabcentral/fileexchange/125255-joyplot

%% (1) GENERATE MAT FILES
% Convert JSON data files into MATLAB .mat format and move them to the 'matFiles' directory

cd(dir_data)  % Change to the data directory
% PD = Json2mat(PatID, hospital, dir_data);  % Convert JSON data for the specific patient and hospital
copyfile('*.mat', dir_matFiles);  % Copy all .mat files from the data directory to the 'matFiles' directory
cd(code_dir);  % Return to the code directory

%% (2) Generate Clinical Event and Sleep Data (eve_file.mat and sleep_file.mat)
% Convert clinical events data (from Excel) into MATLAB .mat format and move to 'matFiles'

filename = 'ClinicTimeline.xlsx';  % Define the name of the clinical timeline Excel file
% NSz = 5;  % Number of seizures (commented out as it's not used)
% Define types of events (e.g., seizures, tappings, medication, etc.)
% Sz = 1;  % Seizures
% TA = 1;  % Tappings
% M = 1;  % Medication
% Mov = 1;  % Movements
% Stim = 1;  % Stimulation
% Arousal = 1;  % Arousal
% [eve_file, sleep_file] = Events2mat(PatID, hospital, dir_timeline, filename, NSz, Sz, TA, M, Mov, Stim, Arousal);  % Convert event data to .mat files

% Alternatively, use a simplified event conversion function
[eve_file, sleep_file] = Event2mat(PatID, hospital, dir_timeline, filename);  % Generate event and sleep data

% Copy the event and sleep .mat files to 'matFiles' directory
copyfile('*.mat', dir_matFiles);  
cd(code_dir);  % Return to the code directory

%% (3) Plot LFP Data (Local Field Potentials)
% Plot LFP data for various event windows and display clinical events

% Define inputs for plotting LFP data
file = '4';  % File number or identifier to be processed
data_type = 'IS';  % Type of data (e.g., 'lfpMTD', 'lfpM', 'IS', 'BSS', 'BST', 'LfpSnap')
delay = '00:00:00';  % Define delay in data (if any)
event_type = [];  % Define the event type, if needed (e.g., 'Sleep', 'Sz_P' for seizures, etc.)
% event_type = 'Sleep';  % Optionally, specify event type
% plot_interval can be left empty for all data or define specific time window to plot
plot_interval = {'12-04-2022 11:58:20', '12-04-2022 11:58:28'};  % Time window for data plotting

ymax = 1000;  % Maximum y-axis value (for BST data)

% Call PlotGenerator function to generate plots for LFP data
PlotGenerator(PatID, hospital, dir_matFiles, file, data_type, delay, event_type, plot_interval, ymax);
cd(code_dir);  % Return to the code directory

%% Plot Time-Domain (TD) Data and Export EDF Files to Docs
% Generate Time-Domain plots for data and export to EDF files for documentation

file = 17;  % File number or identifier
data_type = 'IS';  % Type of data ('lfpMTD', 'IS', 'BSS')
hemisphere = 'both';  % Specify hemisphere ('left', 'right', or 'both')
delay = '00:00:00';  % Define delay in data (if any)

% Call TD_Data function to plot time-domain data
TD_Data(PatID, hospital, dir_matFiles, file, data_type, delay, hemisphere);

% Move the generated EDF files to the Docs directory for documentation
movefile('*.edf', dir_docs);  
cd(code_dir);  % Return to the code directory

%% Plot Compressed Spectral Array of Frequency-Domain (FD) Data
% Plot frequency-domain data (using compressed spectral arrays)

files_lfpM = {'1', '4', '6'};  % List of files containing lfpMontage data
files_lfpS = {'18'};  % List of files containing lfpSnapShot data
delay = '00:00:05.47';  % Define delay in data (if any)
contacts = '0-2';  % Define the contacts to be used for plotting
hemispheres = 'both';  % Specify hemisphere ('left', 'right', or 'both')

% Call FD_Data function to plot frequency-domain data
FD_Data(PatID, hospital, dir_matFiles, files_lfpM, files_lfpS, delay, contacts, hemispheres);
cd(code_dir);  % Return to the code directory

%% Plot Power-Domain (PD) Data
% Generate Power-Domain (PD) plots for specific files

file = 18;  % File number or identifier
delay = '00:01:02';  % Define delay in data (if any)
hemisphere = 'both';  % Specify hemisphere ('left', 'right', or 'both')
ymax = 1000;  % Maximum y-axis value for PD plots
N_subplot = 2;  % Number of subplots to display
seizures = 1;  % Flag to indicate if seizures should be included in the plot

% Call PD_Data function to generate Power-Domain plots
PD_Data(PatID, hospital, file, dir_matFiles, delay, hemisphere, ymax, N_subplot, seizures);
cd(code_dir);  % Return to the code directory

%% GINPUT for Interactive Plot Selection
% Allow the user to select a point on the plot using mouse input (via GINPUT)

ax = gca;  % Get the current axes (for plotting)
[x, y] = ginput(1);  % Get a single mouse-click location (x, y coordinates)
xdate = num2ruler(x, ax.XAxis);  % Convert the x-axis position to a date/time value
xdate.Format = 'HH:mm:ss.SS';  % Set the date/time format for the output
