function f=TD_Data(PatID, hospital, dir_matFiles, file, data_type, delay, hemisphere)
    % TD_Data - Plot and save local field potentials (LFP) signals in the time-domain.
    % This function loads the LFP data from a specified file, applies a delay
    % to the signal timestamps, and generates time-domain plots for different
    % types of data (IS, BSS, lfpMTD). It also saves the signals as EDF files.
    %
    % Input:
    %   PatID      - Patient ID (string).
    %   hospital   - Hospital name or ID (string).
    %   dir_matFiles - Directory where the .mat files are located (string).
    %   file       - File number or ID to be processed (integer).
    %   data_type  - Type of data to plot ('IS', 'BSS', or 'lfpMTD').
    %   delay      - Delay to apply to timestamps in the format 'hh:mm:ss' (string).
    %   hemisphere - Hemisphere data ('left', 'right', or 'both') to plot.

    % Elodie M. Lopes (elodie.m.lopes@inesctec.pt)
    % Doctoral Program in Biomedical Engineering (FEUP)
    % Supervisor: João P. Cunha (INESC TEC, Porto, Portugal)
    % 2024
    %
    % Search for the correct file in the provided directory
    listing = dir(dir_matFiles);
    filenames = {listing.name};  % Get all filenames in the directory
    filenames = filenames(find(contains(filenames, [PatID, '_', hospital, '.mat']) == 1));  % Match filenames by PatID and hospital

    cd(dir_matFiles);  % Change the current working directory to the folder containing the files

    % Load the required file data
    for i = 1:numel(filenames)
        filename = filenames{1, i};
        load(filename);  % Load the data from the .mat file
    end

    f = ['file', num2str(file)];  % Use the given file number
    lfps_data = PD.(f);  % Get the LFP data from the loaded file

    % Parse the delay into hours, minutes, and seconds
    delay_h = hours(str2num(delay(1:2)));
    delay_m = minutes(str2num(delay(4:5)));
    delay_s = seconds(str2num(delay(end-1:end)));

    %% Process IS Data
    if strcmp(data_type, 'IS')
        % Extract data for IS type
        data = lfps_data.(data_type);
        Nseg = data.Nseg;  % Number of segments in the data
        labels = data.labels;  % Channel labels
        sf = data.sf;  % Sampling frequency

        % Loop through each segment and plot the data
        for i = 1:Nseg
            IS_seg = data.data{1, i};  % Get the segment data
            ti = data.tseg_i{1, i};  % Start time of segment
            tf = data.tseg_f{1, i};  % End time of segment
            time = linspace(ti, tf, size(IS_seg, 1));  % Time vector for the segment
            time_RT = time + delay_h + delay_m + delay_s;  % Apply delay to time vector

            % Plot the time-domain signal
            figure;
            eeg_visual(time_RT, IS_seg', labels');
            title([PatID, ': IS Data_File_', num2str(file), '_seg_', num2str(i), '_delay_', delay], 'interpreter', 'none');
            xlabel('Time');
            ylabel('LFP Magnitude (uV)');
            set(gca, 'FontSize', 16);

            % Save the data as an EDF file
            filename_edf = [PatID, '_file', num2str(file), '_data_', data_type, '_delay_', delay, '_seg_', num2str(i)];
            header.samplingrate = sf;
            header.numchannels = numel(labels);
            header.channels = labels;
            header.year = year(ti);
            header.month = month(ti);
            header.day = day(ti);
            header.hour = hour(ti);
            header.minute = minute(ti);
            header.second = second(ti);
            lab_write_edf(filename_edf, IS_seg', header);
        end
    end

    %% Process BSS Data
    if strcmp(data_type, 'BSS') == 1
        % Extract data for BSS type
        data = lfps_data.(data_type);
        N = data.Nseg;  % Number of segments
        sf = 250;  % Sampling frequency for BSS data

        % Process data for both hemispheres
        if strcmp(hemisphere, 'both') == 1
            % Combine labels for both hemispheres (Left and Right)
            labels = {data.labels{1, 1}, data.labels{1, 2}};
            labels = regexprep(labels, {'ZERO', 'ONE', 'TWO', 'THREE', 'LEFT', 'RIGHT', '_'}, {'0', '1', '2', '3', 'L', 'R', '-'});

            % Loop through the segments for both hemispheres
            for j = 1:N/2
                seg1 = data.data{1, 2*j-1};  % First segment
                seg2 = data.data{1, 2*j};  % Second segment
                seg = [seg1, seg2];  % Combine the two segments

                n = size(seg1, 1);  % Number of data points
                ti = data.tseg_i{1, 2*j-1};  % Start time of segment
                tf = data.tseg_f{1, 2*j-1};  % End time of segment
                T = linspace(ti, tf, n);  % Time vector for the segment
                time_RT = T + delay_h + delay_m + delay_s;  % Apply delay to time vector

                % Plot the time-domain signal
                figure;
                eeg_visual(time_RT, seg, labels');
                title([PatID, ': BSS Data_File_', num2str(file), '_seg_', num2str(i), '_delay_', delay, '_seg_', num2str(j)], 'interpreter', 'none');
                xlabel('Time');
                ylabel('LFP Magnitude (uV)');
                set(gca, 'FontSize', 16);

                % Save the data as an EDF file
                filename_edf = [PatID, '_file', num2str(file), '_seg_', num2str(j), '_data_', data_type, '_delay_', delay];
                header.samplingrate = sf;
                header.numchannels = numel(labels);
                header.channels = labels;
                header.year = year(ti);
                header.month = month(ti);
                header.day = day(ti);
                header.hour = hour(ti);
                header.minute = minute(ti);
                header.second = second(ti);
                lab_write_edf(filename_edf, seg', header);
            end
        end

        % Process data for a single hemisphere (left or right)
        if strcmp(hemisphere, 'right') == 1 || strcmp(hemisphere, 'left') == 1
            labels = {data.labels{1, 1}};
            labels = regexprep(labels, {'ZERO', 'ONE', 'TWO', 'THREE', 'LEFT', 'RIGHT', '_'}, {'0', '1', '2', '3', 'L', 'R', '-'});

            for i = 1:N
                seg = data.data{1, i};  % Extract the segment data
                n = size(seg, 1);  % Number of data points
                ti = data.tseg_i{1, i};  % Start time
                tf = data.tseg_f{1, i};  % End time
                T = linspace(ti, tf, n);  % Time vector for the segment
                time_RT = T + delay_h + delay_m + delay_s;  % Apply delay

                % Plot the time-domain signal
                figure;
                eeg_visual(time_RT, seg, labels');
                title([PatID, ': BSS Data_File_', num2str(file), '_seg_', num2str(i), '_delay_', delay, '_seg_', num2str(i)], 'interpreter', 'none');
                xlabel('Time');
                ylabel('LFP Magnitude (uV)');
                set(gca, 'FontSize', 16);

                % Save the data as an EDF file
                filename_edf = [PatID, '_file', num2str(file), '_seg_', num2str(i), '_data_', data_type, '_delay_', delay];
                header.samplingrate = sf;
                header.numchannels = numel(labels);
                header.channels = labels;
                header.year = year(ti);
                header.month = month(ti);
                header.day = day(ti);
                header.hour = hour(ti);
                header.minute = minute(ti);
                header.second = second(ti);
                lab_write_edf(filename_edf, seg', header);
            end
        end
    end

    %% Process lfpMTD Data
    if strcmp(data_type, 'lfpMTD') == 1
        data = lfps_data.(data_type);
        N = data.Nseg;  % Number of segments
        sf = 250;  % Sampling frequency for lfpMTD data

        for i = 1:N
            signal_pass1 = [];
            signal_pass2 = [];
            all_time_pass1 = [];
            all_time_pass2 = [];

            % Process pass 1
            if mod(i, 2) == 1
                labels_pass1 = {'0-3 L', '1-3 L', '0-2 L', '0-3 R', '1-3 R', '0-2 R'};
                lfpMTD_seg = data.data{1, i};

                % Concatenate data for all channels
                for j = 1:6
                    lfpMTD_seg2(:, j) = lfpMTD_seg{1, j};
                end

                n = size(lfpMTD_seg2, 1);
                ti = data.tseg_i{1, i};
                tf = data.tseg_f{1, i};
                T = linspace(ti, tf, n);
                all_time_pass1 = [all_time_pass1, T];
                signal_pass1 = [signal_pass1; lfpMTD_seg2];

                % Plot the data for pass 1
                all_time_pass1_RT = all_time_pass1 + delay_h + delay_m + delay_s;
                figure;
                eeg_visual(all_time_pass1_RT, signal_pass1, labels_pass1);
                title([PatID, ': lfpMTD (Pass1)_File_', num2str(file), '_seg_', num2str(i), '_delay_', delay], 'interpreter', 'none');
                xlabel('Time');
                ylabel('LFP Magnitude (uV)');
                set(gca, 'FontSize', 16);

                % Save the pass 1 data as EDF
                filename_edf_pass1 = [PatID, '_file', num2str(file), '_data_', data_type, '(Pass1)_delay_', delay, '_seg_', num2str(i)];
                header_pass1.samplingrate = sf;
                header_pass1.numchannels = numel(labels_pass1);
                header_pass1.channels = labels_pass1;
                header_pass1.year = year(all_time_pass1_RT(1));
                header_pass1.month = month(all_time_pass1_RT(1));
                header_pass1.day = day(all_time_pass1_RT(1));
                header_pass1.hour = hour(all_time_pass1_RT(1));
                header_pass1.minute = minute(all_time_pass1_RT(1));
                header_pass1.second = second(all_time_pass1_RT(1));
                lab_write_edf(filename_edf_pass1, signal_pass1', header_pass1);

                % Clear variables for the next iteration
                clear filename_edf_pass1 header_pass1 all_time_pass1_RT signal_pass1 labels_pass1;
            end

            % Process pass 2
            if mod(i, 2) == 0
                labels_pass2 = {'0-1 L', '1-2 L', '2-3 L', '0-1 R', '1-2 R', '2-3 R'};
                lfpMTD_seg = data.data{1, i};

                % Concatenate data for all channels
                for j = 1:6
                    lfpMTD_seg2(:, j) = lfpMTD_seg{1, j};
                end

                n = size(lfpMTD_seg2, 1);
                ti = data.tseg_i{1, i};
                tf = data.tseg_f{1, i};
                T = linspace(ti, tf, n);
                all_time_pass2 = [all_time_pass2, T];
                signal_pass2 = [signal_pass2; lfpMTD_seg2];

                % Plot the data for pass 2
                all_time_pass2_RT = all_time_pass2 + delay_h + delay_m + delay_s;
                figure;
                eeg_visual(all_time_pass2_RT, signal_pass2, labels_pass2);
                title([PatID, ': lfpMTD (Pass2)_File_', num2str(file), '_seg_', num2str(i), '_delay_', delay], 'interpreter', 'none');
                xlabel('Time');
                ylabel('LFP Magnitude (uV)');
                set(gca, 'FontSize', 16);

                % Save the pass 2 data as EDF
                filename_edf_pass2 = [PatID, '_file', num2str(file), '_data_', data_type, '(Pass2)_delay_', delay, '_seg_', num2str(i)];
                header_pass2.samplingrate = sf;
                header_pass2.numchannels = numel(labels_pass2);
                header_pass2.channels = labels_pass2;
                header_pass2.year = year(all_time_pass2_RT(1));
                header_pass2.month = month(all_time_pass2_RT(1));
                header_pass2.day = day(all_time_pass2_RT(1));
                header_pass2.hour = hour(all_time_pass2_RT(1));
                header_pass2.minute = minute(all_time_pass2_RT(1));
                header_pass2.second = second(all_time_pass2_RT(1));
                lab_write_edf(filename_edf_pass2, signal_pass2', header_pass2);

                % Clear variables for the next iteration
                clear filename_edf_pass2 header_pass2 all_time_pass2_RT signal_pass2;
            end
        end
    end
end
