% --- Script for processing JSON data from experimental sessions ---
% This script loads experimental data from JSON files, processes signals from
% LFP, BrainSense, and other modalities, and organizes the data into 
% a structure for further analysis or saving.

% Author: Elodie M. Loeps (elodie.m.lopes)
% Doctoral Program of Biomedical Engineering (FEUP)
% Supervisor: João P. Cunha (INESC TEC, Porto, Portugal)
% 2024

%% Initialization and Directory Setup

% Set the directory containing the data
cd(dir_data)

% Get information about files in the specified directory
fileinfo = dir(dir_data);
filenames = {fileinfo.name};  % Store all filenames in a cell array

% Filter to include only files containing 'file' in their name
id = contains(filenames, 'file');
filenames(id == 0) = [];  % Keep only the JSON files
n = numel(filenames);  % Number of JSON files to process

% Load a reference file (PDX_Hospital.mat) - this can be an experimental configuration or data
load('PDX_Hospital.mat'); 

%% User Input for File Selection
% Specify which file to load (for example, file 17)
i_file = 17; 

% Construct the filename based on the selected file index
f = num2str(i_file);    
id_f = find(contains(filenames, ['file', f, '_']));  % Search for the specific file
filename = filenames(id_f); clear id_f;
filename2 = filename{1, 1};

% Read the JSON file
json = fileread(filename2);  % Open the JSON file 
val = jsondecode(json);  % Decode the JSON data into a structure

%% General Information Extraction

% Extract session start and end times, and calculate the session duration
beginSession = datetime(val.SessionDate, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''Z');
finalSession = datetime(val.SessionEndDate, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''Z');
dtSession = finalSession - beginSession;  % Duration as datetime object
dtSession_s = seconds(dtSession);  % Duration in seconds

% Store general information into the structure
file.filename = filename2;  % Store the filename
file.beginSession = beginSession;
file.finalSession = finalSession;
file.dtSession = dtSession;

% Stimulation Status information
file.InitialStim = val.Stimulation.InitialStimStatus;
file.FinalStim = val.Stimulation.FinalStimStatus;

% Programs of Stimulation (Groups)
file.groups = val.Groups;

%% Processing LFP Montage Time Domain Signals (LfpMTD)

% Check if LfpMontageTimeDomain data exists in the JSON
if isfield(val, 'LfpMontageTimeDomain')

    % Define possible LfpMTD labels for different passes
    labels_Pass1 = {'0-3 L', '1-3 L', '0-2 L', '0-3 R', '1-3 R', '0-2 R'};
    labels_Pass2 = {'0-1 L', '1-2 L', '2-3 L', '0-1 R', '1-2 R', '2-3 R'};

    % Extract sampling frequency and initialize data structures
    sf = val.LfpMontageTimeDomain(1).SampleRateInHz;  % Sampling frequency
    lfpMTD = val.LfpMontageTimeDomain;
    Pass = {lfpMTD.Pass};  % Determine pass information

    % Case 1: Only pass 1 data (no "SECOND" pass)
    if isfield(val, 'LfpMontageTimeDomain') && numel(find(contains(Pass, 'SECOND'))) == 0
        % Process data for LEFT hemisphere
        id_L = find(contains({lfpMTD.Channel}, 'LEFT'));
        Nseg_L = numel(id_L);  % Number of segments for LEFT data
        lfpMTD_L = lfpMTD(id_L);  % Extract LEFT hemisphere data
        data_L = cell(1, Nseg_L / 6);  % Placeholder for segmented data

        % Process LEFT hemisphere data in chunks (6 channels per segment)
        for i = 1:Nseg_L / 6
            idx = 1 + (i - 1) * 6;
            ti = datetime(lfpMTD_L(idx).FirstPacketDateTime, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''.000Z');  % Segment start time
            LFPs_L = cell(1, 6);
            Ch_L = cell(1, 6);

            % Extract time domain data and channels for each segment
            for j = 1:6
                LFPs_L{1, j} = lfpMTD_L(6*(i-1) + j).TimeDomainData;
                Ch_L{1, j} = lfpMTD_L(6*(i-1) + j).Channel;
            end

            % Store data for the LEFT hemisphere
            data_L{i}.LFPs = LFPs_L;
            data_L{i}.channels = Ch_L;
            data_L{i}.ti = ti;
        end
        % Store processed LEFT hemisphere data
        file.lfpMTD.Left = data_L;

        % Process RIGHT hemisphere data similarly (using id_R and similar steps)
        id_R = find(contains({lfpMTD.Channel}, 'RIGHT'));
        Nseg_R = numel(id_R);
        lfpMTD_R = lfpMTD(id_R);
        data_R = cell(1, Nseg_R / 6);

        % Process RIGHT hemisphere data in chunks (6 channels per segment)
        for i = 1:Nseg_R / 6
            idx = 1 + (i - 1) * 6;
            ti = datetime(lfpMTD_R(idx).FirstPacketDateTime, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''.000Z');
            LFPs_R = cell(1, 6);
            Ch_R = cell(1, 6);

            % Extract time domain data and channels for each segment
            for j = 1:6
                LFPs_R{1, j} = lfpMTD_R(6*(i-1) + j).TimeDomainData;
                Ch_R{1, j} = lfpMTD_R(6*(i-1) + j).Channel;
            end

            % Store data for the RIGHT hemisphere
            data_R{i}.LFPs = LFPs_R;
            data_R{i}.channels = Ch_R;
            data_R{i}.ti = ti;
        end
        % Store processed RIGHT hemisphere data
        file.lfpMTD.Right = data_R;
    end

%% LFP Montage (LfpM) Signals Processing

% Process LFP Montage signals if data exists
if isfield(val, 'LFPMontage')
    % Case 1: Single hemisphere data
    if isfield(val.LFPMontage, 'Hemisphere') && numel({val.LFPMontage.Hemisphere}) == 6
        if contains(val.LFPMontage(1).Hemisphere, 'Right')
            % Right hemisphere data processing
            mag_R = [];
            ch = cell(1, 6);
            for i = 1:6
                mag_R(:, i) = val.LFPMontage(i).LFPMagnitude;
                ch{1, i} = val.LFPMontage(i).SensingElectrodes;
            end
            file.lfpM.freq = val.LFPMontage(1).LFPFrequency;  % Store the frequency for right hemisphere
            file.lfpM.channels_R = ch;
            file.lfpM.mag_R = mag_R;
        end
        
        if contains(val.LFPMontage(1).Hemisphere, 'Left')
            % Left hemisphere data processing (similar to right)
            mag_L = [];
            ch = cell(1, 6);
            for i = 1:6
                mag_L(:, i) = val.LFPMontage(i).LFPMagnitude;
                ch{1, i} = val.LFPMontage(i).SensingElectrodes;
            end
            file.lfpM.freq = val.LFPMontage(1).LFPFrequency;  % Store the frequency for left hemisphere
            file.lfpM.channels_L = ch;
            file.lfpM.mag_L = mag_L;
        end
    end
end

%% Processing Other Signals (Indefinite Streaming, BrainSense, etc.)

% Process Indefinite Streaming signals if present
if isfield(val, 'IndefiniteStreaming')
    IS = val.IndefiniteStreaming;
    labels = {'0-3 L', '1-3 L', '0-2 L', '0-3 R', '1-3 R', '0-2 R'};  % Labels for IS
    sf = IS.SampleRateInHz;  % Sampling frequency
    file.IS.labels = labels;
    file.IS.sf = sf;

    Nseg_IS = numel(IS) / 6;  % Number of segments (6 channels per segment)

    % Process IS data in chunks of 6 channels
    for i = 1:Nseg_IS
        idx = 1 + (i - 1) * 6;
        ini_time = datetime(IS(idx).FirstPacketDateTime, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''.000Z');
        delta_t =
