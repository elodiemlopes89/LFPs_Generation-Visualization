function f = FD_Data(PatID, hospital, dir_matFiles, files_lfpM, files_lfpS, delay, contacts, hemispheres)
% FD_Data - Function to load, process, and plot LFP data in the frequency domain.
%
% This function processes LFP data from multiple files, organizes it by hemisphere,
% and plots the data in the frequency domain using a Compressed Spectral Array (CSA).
% It also handles data delay and can plot either left, right, or both hemispheres.
%
% Elodie M. Lopes (elodie.m.lopes@inesctec.pt)
% Doctoral Program in Biomedical Engineering (FEUP)
% Superivosor: João P. Cunha
% 2024
%
% INPUTS:
%   PatID        - Patient ID (string).
%   hospital     - Hospital ID (string).
%   dir_matFiles - Directory containing the `.mat` files (string).
%   files_lfpM   - List of files containing LFP data for the mismatch time domain (cell array of strings).
%   files_lfpS   - List of files containing snapshot LFP data (cell array of strings).
%   delay        - Delay in the format 'hh:mm:ss' (string).
%   contacts     - List of contacts to filter LFP data by (cell array of strings).
%   hemispheres  - Hemisphere(s) to plot ('both', 'left', 'right') (string).
%
% OUTPUT:
%   f - Output structure (optional, not defined in code).

%% Step 1: Load files matching the patient and hospital
listing = dir(dir_matFiles);  % Get file listing in the specified directory
filenames = {listing.name};   % List all file names
filenames = filenames(contains(filenames, [PatID, '_', hospital, '.mat']));  % Filter for relevant files

cd(dir_matFiles)  % Change directory to where the files are located

for i = 1:numel(filenames)
    filename = filenames{i};
    load(filename)  % Load data from the file
end

%% Step 2: Process LFP Mismatch Time Domain (lfpM) files
if numel(files_lfpM) > 0
    N_lfpM = numel(files_lfpM);  % Number of mismatch time domain files
    times_lfpM = cell(1, N_lfpM);
    data_lfpM_L = cell(1, N_lfpM);
    data_lfpM_R = cell(1, N_lfpM);
    freq_lfpM = cell(1, N_lfpM);
    stru_lfpM = cell(N_lfpM, 5);  % Structure to store processed data
    
    for i_files = 1:N_lfpM
        f = ['file', files_lfpM{i_files}];  % Extract data for each file
        lfps_data = PD.(f);  % Load data for the specific file
        
        if isfield(lfps_data, 'lfpM')  % Check if 'lfpM' data exists
            data_lfpMTD = lfps_data.lfpMTD;
            data_lfpM = lfps_data.lfpM;  % Extract lfpM data
            ti = data_lfpMTD.tseg_i{1, 1};  % Get time segment
            stru_lfpM{i_files, 1} = ti;
            stru_lfpM{i_files, 5} = 'lfpM';  % Label for lfpM
            stru_lfpM{i_files, 2} = data_lfpM.freq;  % Store frequency data
            
            id_contacts = find(contains(data_lfpM.channels_L, contacts));  % Find relevant contacts
            magL = data_lfpM.mag_L;
            magR = data_lfpM.mag_R;
            stru_lfpM{i_files, 3} = magL(:, id_contacts);  % Store left hemisphere data
            stru_lfpM{i_files, 4} = magR(:, id_contacts);  % Store right hemisphere data
        end
    end
end

%% Step 3: Process LFP Snapshot (LfpSnap) files
if numel(files_lfpS) > 0
    N_lfpS = numel(files_lfpS);  % Number of snapshot files
    times_lfpS = cell(1, N_lfpS);
    data_lfpS_L = cell(1, N_lfpS);
    data_lfpS_R = cell(1, N_lfpS);
    freq_lfpS = cell(1, N_lfpS);
    stru_lfpS = cell(1, N_lfpS);  % Structure to store processed data
    
    for i_files = 1:N_lfpS
        f = ['file', files_lfpS{i_files}];  % Extract data for each file
        lfps_data = PD.(f);  % Load data for the specific file
        
        if isfield(lfps_data, 'LfpSnap')  % Check if 'LfpSnap' data exists
            data_lfpS = lfps_data.LfpSnap;  % Extract LfpSnap data
            
            % Process data for both hemispheres if available
            if isfield(data_lfpS, 'LeftHemisphere') && isfield(data_lfpS, 'RightHemisphere')
                data_lfpS_LH = data_lfpS.LeftHemisphere;
                data_lfpS_RH = data_lfpS.RightHemisphere;
                ev_LH = numel(data_lfpS_RH);
                stru = cell(ev_LH, 5);  % Structure to store data for both hemispheres
                
                for i = 1:ev_LH
                    stru{i, 1} = data_lfpS_LH(i).time;
                    stru{i, 2} = data_lfpS_LH(i).freq;
                    stru{i, 3} = data_lfpS_LH(i).data;
                    stru{i, 4} = data_lfpS_RH(i).data;
                    stru{i, 5} = ['LfpSnap: ', data_lfpS_LH(i).medicalLabel];
                end
                stru_lfpS{1, i_files} = stru;  % Store processed data
            end
            
            % Process data for left hemisphere only
            if isfield(data_lfpS, 'LeftHemisphere') && ~isfield(data_lfpS, 'RightHemisphere')
                data_lfpS_LH = data_lfpS.LeftHemisphere;
                ev_LH = numel(data_lfpS_LH);
                stru = cell(ev_LH, 5);
                
                for i = 1:ev_LH
                    stru{i, 1} = data_lfpS_LH(i).time;
                    stru{i, 2} = data_lfpS_LH(i).freq;
                    stru{i, 3} = data_lfpS_LH(i).data;
                    stru{i, 4} = [];
                    stru{i, 5} = ['LfpSnap: ', data_lfpS_LH(i).medicalLabel];
                end
                stru_lfpS{1, i_files} = stru;
            end
            
            % Process data for right hemisphere only
            if ~isfield(data_lfpS, 'LeftHemisphere') && isfield(data_lfpS, 'RightHemisphere')
                data_lfpS_RH = data_lfpS.RightHemisphere;
                ev_RH = numel(data_lfpS_RH);
                stru = cell(ev_RH, 5);
                
                for i = 1:ev_RH
                    stru{i, 1} = data_lfpS_RH(i).time;
                    stru{i, 2} = data_lfpS_RH(i).freq;
                    stru{i, 3} = [];
                    stru{i, 4} = data_lfpS_RH(i).data;
                    stru{i, 5} = ['LfpSnap: ', data_lfpS_RH(i).medicalLabel];
                end
                stru_lfpS{1, i_files} = stru;
            end
        end
    end
end

%% Step 4: Combine Data from LFP Mismatch (lfpM) and Snapshot (LfpSnap)
stru_f = [];
if numel(files_lfpS) > 0 && numel(files_lfpM) > 0
    for i = 1:N_lfpS
        stru_f = [stru_f; stru_lfpM; stru_lfpS{1, i}];
    end
end

if numel(files_lfpS) == 0 && numel(files_lfpM) > 0
    stru_f = [stru_lfpM];
end

if numel(files_l
