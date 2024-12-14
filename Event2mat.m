function [eve_file, sleep_file] = Events2mat(PatID, hospital, dir_timeline, filename)
    % Converts events and sleep cycle data from an Excel file into MAT files
    % Elodie M. Lopes (elodie.m.lopes@inesctec.pt)
    % Doctoral Program of Biomedical Engineering (FEUP)
    % Supervisor: João P. Cunha (INESC TEC, Porto, Porgual)
    % 2024
    %
    % Inputs:
    %   PatID        - Patient ID (string)
    %   hospital     - Hospital name (string)
    %   dir_timeline - Directory where the ClinicalTimeline.xlsx file is located (string)
    %   filename     - The name of the Excel file containing event and sleep cycle data (string)
    %
    % Outputs:
    %   eve_file     - A structure containing various event information (e.g., Clinical Protocols, Seizures)
    %   sleep_file   - A structure containing information about the sleep cycles (e.g., NREM, REM)

    % Change the working directory to the one specified in dir_timeline
    cd(dir_timeline);
    
    % Read the data from the ClinicalTimeline.xlsx file
    [numbers, strings, raw] = xlsread('ClinicalTimeline.xlsx'); 
    clear number; clear strigs; % Clean up unnecessary variables

    %% Dates, initial time, and final time of events
    
    % Extract the dates and time intervals of events from the raw Excel data
    dates = raw(3:end, 2); % Dates of events
    ti_events = raw(3:end, 4); % Start times of events
    tf_events = raw(3:end, 5); % End times of events

    % Initialize cell arrays for event start and end times and dates
    ti = cell(1, numel(ti_events));
    tf = cell(1, numel(ti_events));
    date = cell(1, numel(ti_events));

    % Loop through each event and parse the date and time fields
    for i = 1:numel(ti_events)
        % Parse the date of the event
        date1 = dates{i};
        date1_st = num2str(date1);

        % Handle 'NaN' or empty date entries
        if strcmp(date1_st, 'NaN') == 1
            date{1, i} = date{1, i - 1};
            dd = datestr(date{1, i});
        else
            d2 = datestr(date1 - datenum(0, 0, 1, 0, 0, 0)); % Adjust date
            dd = strrep(d2, d2(end-12:end-9), num2str(year(today))); % Update year to current year
            date{1, i} = datetime(dd, 'InputFormat', 'dd-MM-yy HH:mm:ss');
        end

        % Handle initial time of event
        timei = ti_events{i};
        timei_st = num2str(timei);

        if contains(timei_st, ':') == 1
            ti{1, i} = datetime([d4, ' ', timei], 'InputFormat', 'dd-MM-yy HH:mm:ss');
        elseif strcmp(timei_st, 'NaN') == 1
            ti{1, i} = date{1, i};
        else
            timei2 = datestr(timei - datenum(0, 0, 1, 0, 0, 0));
            timei3 = timei2(end-7:end);
            ti{1, i} = datetime([d4, ' ', timei3], 'InputFormat', 'dd-MM-yy HH:mm:ss');
        end

        % Handle final time of event
        timef = tf_events{i};
        timef_st = num2str(timef);

        if contains(timef_st, ':') == 1
            tf{1, i} = datetime([d4, ' ', timef], 'InputFormat', 'dd-MM-yy HH:mm:ss');
        elseif strcmp(timef_st, 'NaN') == 1
            tf{1, i} = date{1, i};
        else
            timef2 = datestr(timef - datenum(0, 0, 1, 0, 0, 0));
            timef3 = timef2(end-7:end);
            tf{1, i} = datetime([d4, ' ', timef3], 'InputFormat', 'dd-MM-yy HH:mm:ss');
        end

        clear date1 d2 d3 d4; % Clean up intermediate variables
    end

    %% Extract event labels from the Excel file
    eve_labels = cell(1, size(strings, 1));
    for i = 1:size(strings, 1)
        eve_labels{1, i} = strings{i, 6}; % Extract event labels from the 6th column
    end
    eve_labels = eve_labels(3:end); % Remove the header labels

    %% Identify clinical protocols, seizures, medication, stimulation, activity, and clinical tests

    % Extract clinical protocols and event information from specific columns in raw data
    CPm = raw(3:end, 7);
    SZm = raw(3:end, 8);
    Mm = raw(3:end, 9);
    Stimm = raw(3:end, 10);
    PAm = raw(3:end, 11);
    CTm = raw(3:end, 12);

    % Find the indexes of each type of event based on an 'x' mark
    id_CP = find(strcmp(CPm, 'x'));
    id_SZ = find(strcmp(SZm, 'x'));
    id_M = find(strcmp(Mm, 'x'));
    id_Stim = find(strcmp(Stimm, 'x'));
    id_PA = find(strcmp(PAm, 'x'));
    id_CT = find(strcmp(CTm, 'x'));

    %% Create structures for each event category
    
    % Clinical Protocols
    for i = 1:numel(id_CP)
        ClinProtocols(i).label = eve_labels{1, id_CP(i)};
        ClinProtocols(i).ti = ti{1, id_CP(i)};
        ClinProtocols(i).tf = tf{1, id_CP(i)};
    end
    eve_file.ClincalProtocols = ClinProtocols;

    % Seizures
    for i = 1:numel(id_SZ)
        Seiz(i).label = eve_labels{1, id_SZ(i)};
        Seiz(i).ti = ti{1, id_SZ(i)};
        Seiz(i).tf = tf{1, id_SZ(i)};
    end
    eve_file.Seizures = Seiz;

    % Medication
    MedTable = raw(id_M, 9:end); % Get the medication details
    MedTable2 = [med_list; MedTable];
    MedTable3 = [ti_m; MedTable2']';
    eve_file.Medication = MedTable3;

    % Stimulation (not implemented, could be similar to other sections)

    % Patient Activity
    for i = 1:numel(id_PA)
        PatAct(i).label = eve_labels{1, id_PA(i)};
        PatAct(i).ti = ti{1, id_PA(i)};
        PatAct(i).tf = tf{1, id_PA(i)};
    end
    eve_file.PatientActivity = PatAct;

    % Clinical Tests
    for i = 1:numel(id_CT)
        ClTe(i).label = eve_labels{1, id_CT(i)};
        Clte(i).ti = ti{1, id_CT(i)};
        ClTe(i).tf = tf{1, id_CT(i)};
    end
    eve_file.ClinicalTests = ClTe;

    %% Sleep Cycles - Manually defined for NREM and REM sleep cycles

    % NREM Sleep cycles (hardcoded for a specific patient)
    data_nrem = struct();
    data_nrem.seg1 = {'15-11-2021 13:45:32', '15-11-2021 13:53:29'};
    % More NREM data can be added similarly...

    % Convert NREM data to datetime format
    for i = 1:numel(fieldnames(data_nrem))
        s_str = ['seg', num2str(i)];
        data1 = data_nrem.(s_str);
        ti = datetime(data1{1}, 'InputFormat', 'dd-MM-yy HH:mm:ss');
        tf = datetime(data1{2}, 'InputFormat', 'dd-MM-yy HH:mm:ss');
        nrem{i, 1} = ti;
        nrem{i, 2} = tf;
    end

    % REM Sleep cycles (hardcoded for a specific patient)
    data_rem = struct();
    data_rem.seg1 = {'16-11-2021 02:45:12', '16-11-2021 03:00:08'};
    % More REM data can be added similarly...

    % Convert REM data to datetime format
    for i = 1:numel(fieldnames(data_rem))
        s_str = ['seg', num2str(i)];
        data1 = data_rem.(s_str);
        ti = datetime(data1{1}, 'InputFormat', 'dd-MM-yy HH:mm:ss');
        tf = datetime(data1{2}, 'InputFormat', 'dd-MM-yy HH:mm:ss');
        rem{i, 1} = ti;
        rem{i, 2} = tf;
    end

    % Store sleep cycle data in sleep_file structure
    sleep_file.nrem = nrem;
    sleep_file.rem = rem;

    %% Save the events and sleep files as MAT files
    save('eve_file.mat');
