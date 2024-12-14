function f = PD_Data(PatID, hospital, file, dir_matFiles, delay, hemisphere, ymax, N_subplot, seizures)
% PD_Data - A function to process and plot LFP signals in the power domain.
% Elodie Múrias Lopes (elodie.m.lopes@inesctec.pt)
% Doctoral Program of Biomedical Engineering (FEUP)
% Supervisor: João P. Cunha (INESC TEC, Porto, Portugal)
%
% Inputs:
%   - PatID: Patient ID (string).
%   - hospital: Hospital name (string).
%   - file: File number to process (integer).
%   - dir_matFiles: Directory path containing the .mat files (string).
%   - delay: Delay time before plotting the data (string in HH:MM:SS format).
%   - hemisphere: 'both', 'left', or 'right' hemisphere to display data from.
%   - ymax: Maximum value for the y-axis (for LFP power).
%   - N_subplot: Number of subplots for displaying the data.
%   - seizures: 1 if seizure events are to be plotted, 0 otherwise.
%
% Outputs:
%   - f: Figure handle for the created plot.

% Load the list of .mat files from the specified directory
listing = dir(dir_matFiles);
filenames = {listing.name};
filenames = filenames(find(contains(filenames, [PatID, '_', hospital, '.mat']) == 1));

cd(dir_matFiles)  % Change the working directory to the specified one

% Loop through the filenames and load the respective .mat file
for i = 1:numel(filenames)
    filename = filenames{1, i};
    load(filename)
end

% Load event file (eve_file.mat) containing seizure event data
load('eve_file.mat');

% Extract the data for the specific file number
f = ['file', num2str(file)];  % Construct file identifier
lfps_data = PD.(f);  % Extract LFP data corresponding to the selected file

% Parse the delay input into hours, minutes, and seconds
delay_h = hours(str2num(delay(1:2)));
delay_m = minutes(str2num(delay(4:5)));
delay_s = seconds(str2num(delay(end-1:end)));

%% Seizures Processing (if seizures flag is set to 1)
if seizures == 1
    seizures_info = eve_file.seizures;  % Get seizure information from event file
    n = numel(seizures_info);  % Number of seizure events
    time = [];  % Initialize array to store seizure times
    label = cell(1, n);  % Initialize cell array to store seizure labels
    
    % Loop through the seizure information to extract event times and labels
    for i = 1:n
        time = [time seizures_info(i).initial];  % Seizure event times
        la = seizures_info(i).label;  % Seizure event labels
        label{i} = la;
    end
    
    % Convert labels to a string matrix for plotting
    event_times = time;  % Store seizure event times
    n_event = n;  % Number of events
    
    for j = 1:n_event
        event_labels(j, :) = string(label{1, j});  % Convert labels to string format
    end
end

%% Process Data for Both Hemispheres (if hemisphere is 'both')
if strcmp(hemisphere, 'both') == 1
    BST = lfps_data.BST;  % Extract the BST data
    
    n = size((BST.LeftHemisphere), 2);  % Number of segments in the left hemisphere
    signal_L = [];  % Initialize variable for left hemisphere signal
    signal_R = [];  % Initialize variable for right hemisphere signal
    signal_amp_L = [];  % Initialize variable for left hemisphere stimulation amplitude
    signal_amp_R = [];  % Initialize variable for right hemisphere stimulation amplitude
    all_time = [];  % Initialize variable for storing all time values
    
    % Loop through the segments in the left and right hemispheres to extract data
    for i = 1:n
        data_L = BST.LeftHemisphere(i).data;  % Extract left hemisphere data
        data_R = BST.RightHemisphere(i).data;  % Extract right hemisphere data
        time = BST.LeftHemisphere(i).time;  % Extract time values
        Stim_Amp_L = BST.LeftHemisphere(i).StimAmp;  % Extract left hemisphere stimulation amplitude
        Stim_Amp_R = BST.RightHemisphere(i).StimAmp;  % Extract right hemisphere stimulation amplitude
        
        n2 = numel(data_L);  % Number of time segments
        
        % Loop through each segment to organize the data and stimulation amplitudes
        for j = 1:n2
            data_L2(:, j) = data_L{1, j}; 
            data_R2(:, j) = data_R{1, j};
            time2(:, j) = time{1, j};
            Stim_Amp_L2(:, j) = Stim_Amp_L{1, j};
            Stim_Amp_R2(:, j) = Stim_Amp_R{1, j};
        end
        
        % Smooth the data for both hemispheres
        data_R3 = smooth(data_R2);
        data_L3 = smooth(data_L2);
        
        % Append the smoothed data to the respective signals
        signal_L = [signal_L; data_L3];
        signal_R = [signal_R; data_R3];
        signal_amp_L = [signal_amp_L Stim_Amp_L2];
        signal_amp_R = [signal_amp_R Stim_Amp_R2];
        all_time = [all_time time2];
        
        % Clear temporary variables for the next iteration
        clear data_L data_R time Stim_Amp_L Stim_Amp_R n2 data_L2 data_R2 time2 Stim_Amp_L2 Stim_Amp_R2;
        clear data_R3 data_L3;
    end
    
    % Adjust time to account for delay
    all_time = all_time - delay_h - delay_m - delay_s;
    
    % Calculate the duration of the recording and segment it into N_subplot sections
    dt = duration(all_time(end) - all_time(1), 'Format', 's');
    dt_subplot = dt ./ N_subplot;
    N_total = numel(all_time);
    idx = floor(N_total / N_subplot);
    id_seg = cell(1, N_subplot);
    id_seg{1, 1} = [1:idx];
    for i = 2:N_subplot
        id_seg{1, i} = [(i-1) * idx : i * idx];
    end
    
    % Create a new figure for the plots
    f = figure;
    
    % Loop through each subplot to display the data
    for i = 1:N_subplot
        id_seg2 = id_seg{1, i};
        time_seg = all_time(id_seg2(1):id_seg2(end));
        BST_seg_R = signal_R(id_seg2(1):id_seg2(end));
        BST_seg_L = signal_L(id_seg2(1):id_seg2(end));
        amp_seg = signal_amp_L(id_seg2(1):id_seg2(end));
        
        if i == N_subplot
            id_seg2 = id_seg{1, i};
            time_seg = all_time(id_seg2(1):N_total);
            BST_seg_R = signal_R(id_seg2(1):N_total);
            BST_seg_L = signal_L(id_seg2(1):N_total);
            amp_seg = signal_amp_L(id_seg2(1):N_total);
        end
        
        A = [BST_seg_L; BST_seg_R];
        subplot(N_subplot, 1, i)
        
        % Plot Left and Right Hemisphere LFPs on the left y-axis
        yyaxis left
        hold on
        plot(time_seg, BST_seg_R, 'b*', 'LineWidth', 1.5, 'MarkerSize', 3)
        p1 = plot(time_seg, BST_seg_R, 'b', 'LineWidth', 1.5);
        plot(time_seg, BST_seg_L, 'r*', 'LineWidth', 1.5, 'MarkerSize', 3)
        p2 = plot(time_seg, BST_seg_L, 'r', 'LineWidth', 1.5);
        ylim([0 ymax])
        xlim([time_seg(1) time_seg(end)])
        ylabel('LFP Power')
        set(gca, 'FontSize', 16)
        
        % Plot Seizure Events if seizures flag is set
        if seizures == 1
            for i = 1:n_event
                hold on
                plot([event_times(i) event_times(i)], [0 ymax], 'k-', 'LineWidth', 3)
            end
        end
        
        % Plot Stimulation Amplitude on the right y-axis
        yyaxis right
        p3 = plot(time_seg, amp_seg, 'm', 'LineWidth', 1.5)
        ylim([0 6])
        ylabel('Stim (mA)')
        xlabel('Time')
        set(gca, 'FontSize', 16)
        
        clear time_seg; clear BST_seg_R; clear BST_seg_L; clear amp_seg;
    end
    
    % Add legend and title
    lg = legend([p1, p2, p3], 'RH', 'LH', 'Stim Amp');
    lg.Location = 'northeastoutside';
    
    sp = suptitle([PatID, ': BST Data - File ', file, '_Delay_', delay]);
    set(sp, 'Interpreter', 'none', 'FontSize', 18);
end

