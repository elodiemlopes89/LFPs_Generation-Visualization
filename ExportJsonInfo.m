function info=ExportJsonInfo(PatID, hospital, file, dir_matFiles)
    % ExportJsonInfo extracts and organizes relevant information from a .mat file containing LFP signal data,
    % specifically from json files with LFP signals. The function organizes session, stimulation, IS, BSS, 
    % Elodie M. Lopes (elodie.m.lopes@inesctec.pt)
    % Doctoral Program in Biomedical Engineering (FEUP)
    % Supervisor: João P. Cunha (INESC TEC, Porto, Portugal)
    %
    % Inputs:
    % - PatID: Patient ID as a string.
    % - hospital: Hospital name or ID as a string.
    % - file: File number or identifier (integer).
    % - dir_matFiles: Directory path to the .mat files as a string.
    %
    % Output:
    % - info: A structure containing all the relevant information extracted from the .mat file.
    
    % Load the .mat file corresponding to the patient and hospital
    load([dir_matFiles, '/', PatID, '_', hospital, '.mat']);
    
    % Access the specific file data
    f = ['file', num2str(file)];
    data = PD.(f);  % Extract data for the specified file
    
    %% Filename Information
    filename = data.filename;  % Extract the filename from the data structure
    info.filename = filename;  % Store in the info structure
    
    %% Session Information
    inS = data.beginSession;  % Initial session time
    finS = data.finalSession;  % Final session time
    
    % Handle NaT (Not a Time) values in session times
    if isnat(inS)
        inS = 'NR';  % 'NR' stands for Not Recorded
    else
        inS = datestr(inS);  % Convert the initial session time to a string format
    end
    
    if isnat(finS)
        finS = 'NR';  % Final session not recorded
    else
        finS = datestr(finS);  % Convert the final session time to a string format
    end
    
    info.BeginSession = inS;
    info.FinalSession = finS;
    
    %% Stimulation Information
    % Initial stimulation status
    inStim = data.InitialStim;
    finStim = data.FinalStim;
    
    % If initial stimulation is ON, extract stimulation parameters (amplitude)
    if strcmp(inStim, 'StimStatusDef.ON') == 1
        if isfield(data, 'SPi')  % Check if initial stimulation data exists
            if isfield(data.SPi, 'Amp_LH') && isfield(data.SPi, 'Amp_RH')
                % Both left and right hemisphere amplitude data
                Amp_i_LH = data.SPi.Amp_LH;
                Amp_i_RH = data.SPi.Amp_RH;
                Amp_i_LH_RH = [Amp_i_LH, Amp_i_RH];
                info.SPi_LH_RH = Amp_i_LH_RH;
            elseif isfield(data.SPi, 'Amp_LH')
                % Only left hemisphere amplitude data
                Amp_i_LH = data.SPi.Amp_LH;
                info.SPi_LH = Amp_i_LH;
            elseif isfield(data.SPi, 'Amp_RH')
                % Only right hemisphere amplitude data
                Amp_i_RH = data.SPi.Amp_RH;
                info.SPi_RH = Amp_i_RH;
            end
        end
    end
    
    % If final stimulation is ON, extract final stimulation parameters (amplitude)
    if strcmp(finStim, 'StimStatusDef.ON') == 1
        if isfield(data, 'SPf')  % Check if final stimulation data exists
            if isfield(data.SPf, 'Amp_LH') && isfield(data.SPf, 'Amp_RH')
                % Both left and right hemisphere amplitude data
                Amp_f_LH = data.SPf.Amp_LH;
                Amp_f_RH = data.SPf.Amp_RH;
                Amp_f_LH_RH = [Amp_f_LH, Amp_f_RH];
                info.SPf_LH_RH = Amp_f_LH_RH;
            elseif isfield(data.SPf, 'Amp_LH')
                % Only left hemisphere amplitude data
                Amp_f_LH = data.SPf.Amp_LH;
                info.SPf_LH = Amp_f_LH;
            elseif isfield(data.SPf, 'Amp_RH')
                % Only right hemisphere amplitude data
                Amp_f_RH = data.SPf.Amp_RH;
                info.SPf_RH = Amp_f_RH;
            end
        end
    end
    
    %% IS Data
    if isfield(data, 'IS')
        n_IS = data.IS.Nseg;  % Number of IS segments
        S_s = cell(1, n_IS);  % Initialize cell array to store segment information
        
        % Extract segment information for each IS segment
        for i = 1:n_IS
            ti = data.IS.tseg_i{1, i};
            ti_s = [num2str(day(ti)), '-', num2str(month(ti)), '-', num2str(year(ti)), ' ', num2str(hour(ti)), ':', num2str(minute(ti)), ':', num2str(floor(second(ti)))];
            tf = data.IS.tseg_f{1, i};
            tf_s = [num2str(day(tf)), '-', num2str(month(tf)), '-', num2str(year(tf)), ' ', num2str(hour(tf)), ':', num2str(minute(tf)), ':', num2str(floor(second(tf)))];
            delta_t = tf - ti;  % Time difference for the segment
            delta_t_s = num2str(floor(seconds(delta_t)));  % Time difference in seconds
            S_s{1, i} = ['Seg', num2str(i), ': ti_s=', ti_s, '; tf=', tf_s, '; delta t=', delta_t_s];
        end
        info.IS = S_s;
    end
    
    %% BSS Data
    if isfield(data, 'BSS')
        n_BSS = data.BSS.Nseg;  % Number of BSS segments
        S_s = cell(1, n_BSS);  % Initialize cell array to store segment information
        
        % Extract segment information for each BSS segment
        for i = 1:n_BSS
            ti = data.BSS.tseg_i{1, i};
            ti_s = [num2str(day(ti)), '-', num2str(month(ti)), '-', num2str(year(ti)), ' ', num2str(hour(ti)), ':', num2str(minute(ti)), ':', num2str(floor(second(ti)))];
            tf = data.BSS.tseg_f{1, i};
            tf_s = [num2str(day(tf)), '-', num2str(month(tf)), '-', num2str(year(tf)), ' ', num2str(hour(tf)), ':', num2str(minute(tf)), ':', num2str(floor(second(tf)))];
            delta_t = tf - ti;  % Time difference for the segment
            delta_t_s = num2str(floor(seconds(delta_t)));  % Time difference in seconds
            S_s{1, i} = ['Seg', num2str(i), ': ti_s=', ti_s, '; tf=', tf_s, '; delta t=', delta_t_s];
        end
        info.BSS = S_s;
    end
    
    %% lfpMTD Data
    if isfield(data, 'lfpMTD')
        n_lfpMTD = data.lfpMTD.Nseg;  % Number of lfpMTD segments
        S_s = cell(1, n_lfpMTD);  % Initialize cell array to store segment information
        
        % Extract segment information for each lfpMTD segment
        for i = 1:n_lfpMTD
            ti = data.lfpMTD.tseg_i{1, i};
            ti_s = [num2str(day(ti)), '-', num2str(month(ti)), '-', num2str(year(ti)), ' ', num2str(hour(ti)), ':', num2str(minute(ti)), ':', num2str(floor(second(ti)))];
            tf = data.lfpMTD.tseg_f{1, i};
            tf_s = [num2str(day(tf)), '-', num2str(month(tf)), '-', num2str(year(tf)), ' ', num2str(hour(tf)), ':', num2str(minute(tf)), ':', num2str(floor(second(tf)))];
            delta_t = tf - ti;  % Time difference for the segment
            delta_t_s = num2str(floor(seconds(delta_t)));  % Time difference in seconds
            S_s{1, i} = ['Seg', num2str(i), ': ti_s=', ti_s, '; tf=', tf_s, '; delta t=', delta_t_s];
        end
        info.lfpMTD = S_s;
    end
    
    %% BST Data
    if isfield(data, 'BST')
        BST = data.BST;
        if isfield(BST, 'LeftHemisphere')
            n_BST = size(BST.LeftHemisphere, 2);
        else
            n_BST = size(BST.RightHemisphere, 2);
        end
        
        % Extract segment information for each BST segment
        S_s = cell(1, n_BST);
        for i = 1:n_BST
            if isfield(BST, 'RightHemisphere')
                n = numel(BST.RightHemisphere(i).time);
                ti = BST.RightHemisphere(i).time{1, 1};
                tf = BST.RightHemisphere(i).time{1, n};
            else
                n = numel(BST.LeftHemisphere(i).time);
                ti = BST.LeftHemisphere(i).time{1, 1};
                tf = BST.LeftHemisphere(i).time{1, n};
            end
            
            ti_s = [num2str(day(ti)), '-', num2str(month(ti)), '-', num2str(year(ti)), ' ', num2str(hour(ti)), ':', num2str(minute(ti)), ':', num2str(floor(second(ti)))];
            tf_s = [num2str(day(tf)), '-', num2str(month(tf)), '-', num2str(year(tf)), ' ', num2str(hour(tf)), ':', num2str(minute(tf)), ':', num2str(floor(second(tf)))];
            delta_t = tf - ti;  % Time difference for the segment
            delta_t_s = num2str(floor(seconds(delta_t)));  % Time difference in seconds
            S_s{1, i} = ['Seg', num2str(i), ': ti_s=', ti_s, '; tf=', tf_s, '; delta t=', delta_t_s];
        end
        info.BST = S_s;
    end
    
    %% LfpSnap Data
    if isfield(data, 'LfpSnap')
        LfpSnap = data.LfpSnap;
        if isfield(LfpSnap, 'LeftHemisphere')
            n_LfpSnap = size(LfpSnap.LeftHemisphere, 2);
        else
            n_LfpSnap = size(LfpSnap.RightHemisphere, 2);
        end
        
        % Extract segment information for each LfpSnap event
        S_s = cell(1, n_LfpSnap);
        for i = 1:n_LfpSnap
            if isfield(LfpSnap, 'RightHemisphere')
                date = LfpSnap.RightHemisphere(i).time;
                label = LfpSnap.RightHemisphere(i).medicalLabel;
            else
                date = LfpSnap.LeftHemisphere(i).time;
                label = LfpSnap.LeftHemisphere(i).medicalLabel;
            end
            
            date_s = [num2str(day(date)), '-', num2str(month(date)), '-', num2str(year(date)), ' ', num2str(hour(date)), ':', num2str(minute(date)), ':', num2str(floor(second(date)))];
            S_s{1, i} = ['Event Time #', num2str(i), '=', date_s, ' ; Label: ', label];
        end
        info.LfpSnap = S_s;
    end
    
    %% Export the information to an Excel file
    filename_xlsx = [PatID, '_', hospital, '_JsonFile', num2str(file), '.xlsx'];
    writetable(struct2table(info), [filename_xlsx, '.xlsx']);
    
    % Clear data to free memory
    clear data;
end
