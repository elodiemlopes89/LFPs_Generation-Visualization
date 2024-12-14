function f=PlotGenerator(PatID,hospital,dir_matFiles,file,data_type,delay,event_type,plot_interval,ymax)
%
% Plot of the Local Field Potentials data saved in the PD(PatID).mat file,
% the clinical events stored in the eve_file_(PD(PatID)).mat and the sleep
% phase stored in the sleep_file_(PD(PatID)).mat
% 
% @function PlotGenerator
%
% In this function we have to select one type of event and one type of data
% to plot. We can plot data in the entire data interval or select other
% specific interval.
%
% PlotGenerator(PatID,mat_files,file,data_type,delay,event_type,plot_interval,ymax)
%
%
% INPUTS:       
%           PatID: Patient identification (e.g. PD01)
%
%           mat_files: Strucutre array (1x3) containing the mat files 
%                      * mat_files.PD=PD;
%                      * mat_files.eve_file=eve_file;
%                      * mat_files.sleep_file=sleep_file;
%
%          file: json file number (e.g. '2')
%           
%          data_type: Percept PC data
%          ('lfpP','lfpMTD','IS','BSS','BST','LfpSnap')
%
%          delay: delay between Percept PC time and vEEG clocks
%          ('HH:MM:SS')
%
%          event_type: ype of events to be ploted together with LFP data ([] if none, 'seizures','tappings','movement','stimulation','Arousal','Aicroarausal')
%
%          plot_interval: [] for all data in the file or {'yyyy-mm-dd HH:MM:SS', 'yyyy-mm-dd HH:MM:SS'} to plot data into a specific interval
%
%          ymax: maximum value of the plot window to plot BST data
%
%
%
% Elodie M Lopes, Brain group, INESC-TEC Porto
% (elodie.m.lopes@inesctec.pt)
% Doctoral Program of Biomedical Engineering (FEUP)
% Supervisor: João P. Cunha
% 2024
%
%%
listing = dir(dir_matFiles);
filenames={listing.name};
filenames=filenames(find(contains(filenames,[PatID,'_',hospital,'.mat'])==1));

cd(dir_matFiles)
for i=1:numel(filenames)
    filename=filenames{1,i};
    %filename=filename{1,1};
    load(filename)
end



f=['file',num2str(file)]; %files
lfps_data=PD.(f); %data of each file
load('eve_file.mat')
load('sleep_file.mat')

%delay hour, munute and second
delay_h=hours(str2num(delay(1:2)));
delay_m=minutes(str2num(delay(4:5)));
delay_s=seconds(str2num(delay(end-1:end)));


%% Seizures Protocol (Sz_P)

%seizures
if strcmp(event_type,'Sz_P')
    
    
    
     event_times={eve_file.Seizures.ti};
     %event_times_f={eve_file.Seizures.tf};
     labels={eve_file.Seizures.label};
    
    n_event=numel(event_times); %number of events
    
    %convert labels to a string matrix
    for j=1:n_event
    event_labels(j,:)=string(labels{1,j});
    end
    
end

%%

%Tapping Protocol (Ta_P)
if strcmp(event_type,'tappings')
    
    tappings_info=eve_file.tapping;
    n=numel(tappings_info); 
    time=[];
    label=cell(1,n);
    
    for i=1:n
        
        time=[time tappings_info{1,i}.time_ta]; %time
        label{i}=tappings_info{1,i}.label; % labels
        
    end
    
     event_times=time;
    
    n_event=n; %number of events
    
    %convert labels to a string matrix
    for j=1:n_event
    event_labels(j,:)=string(label{1,j});
    end
    
end

%% Resting State Protocol (RS_P)







%% Movement Protocol

%arousals
if strcmp(event_type,'arousal')
    
    arousal_info=eve_file.arousal;
    n=numel(arousal_info);
    time=[];
    label=cell(1,n);
    
    for i=1:n
        
        time=[time arousal_info{1,i}.time]; %time
        label{i}=arousal_info{1,i}.label; % labels
        
    end
    
     event_times=time;
    
    n_event=n; %number of events
    
    %convert labels to a string matrix
    for j=1:n_event
    event_labels(j,:)=string(label{1,j});
    end
end

%% Stimulation Protocol (Stim_P)



%% Sleep Stages (Sleep)

if strcmp(event_type,'Sleep')
    
    load('sleep_file.mat')
    
    %nrem_plot
    nrem=sleep_file.nrem;
    rem=sleep_file.rem;
    
    
       
    
    
end





%%

%microarousals
if strcmp(event_type,'microarousal')
    
    marousal_info=eve_file.microarousal;
    n=numel(marousal_info);
    time=[];
    label=cell(1,n);
    
    for i=1:n
        
        time=[time marousal_info{1,i}.time]; %time
        label{i}=marousal_info{1,i}.label; % labels
        
    end
    
     event_times=time;
    
    n_event=n; %number of events
    
    %convert labels to a string matrix
    for j=1:n_event
    event_labels(j,:)=string(label{1,j});
    end
end

% medication
if strcmp(event_type,'medication')
    
    medication_info=eve_file.medication;
    n=numel(medication_info);
    time=[];
    label=cell(1,n);
    
    for i=1:n
        
        time=[time medication_info{1,i}.time];
        a=medication_info{1,i}.label;
        a2=a(find(strcmp(a,'0')==0));
        label{i}=strjoin(a2);
        
    end
    
     event_times=time;
    %event_labels=label;
    n_event=n;
    
    
    for j=1:n_event
        
        
        event_labels(j,:)=cellstr(label{1,j});
    end
    
    event_labels=event_labels(:,1);
    
end



%movement
if strcmp(event_type,'movement')
    
    movement=eve_file.movement;
    walk=movement.walk;
    wc=movement.wc;
    exercise=movement.exe;
    mov=movement.movement;
    
    time_walk=[];
    label_walk=cell(1,numel(walk));
    time_wc=[];
    label_wc=cell(1,numel(wc));
    time_exercise=[];
    label_exercise=cell(1,numel(exercise));
    time_mov=[];
    label_mov=cell(1,numel(mov));
    
    for i=1:numel(walk);
        time_walk=[time_walk walk{1,i}.time];
        label_walk{i}='Patient activity';
        
    end
    for i=1:numel(wc);
        time_wc=[time_wc wc{1,i}.time];
        label_wc{i}='Patient activity';
    end
    for i=1:numel(exercise)
        time_exercise=[time_exercise exercise{1,i}.time];
        label_exercise{i}='Clinical tests';
    end
    for i=1:numel(mov)
        time_mov=[time_mov mov{1,i}.time];
        label_mov{i}='Clinical tests';
    end
    
    

    
 for j=1:numel(walk)
       
        event_labels_walk(j,:)=cellstr(label_walk{1,j});
 end
    
  for j=1:numel(wc)
       
        event_labels_wc(j,:)=cellstr(label_wc{1,j});
  end
    
   for j=1:numel(exercise)
       
        event_labels_exercise(j,:)=cellstr(label_exercise{1,j});
   end
    
    for j=1:numel(mov)
       
        event_labels_mov(j,:)=cellstr(label_mov{1,j});
    end
    
    
   event_times=[time_walk time_wc time_exercise time_mov];
    %event_labels=label;
    n_event=numel(event_times)
    
    
    event_labels=[event_labels_walk ;event_labels_wc ;event_labels_exercise; event_labels_mov];
    
end


% stimulation
if strcmp(event_type,'stimulation')
    
    stim_info=eve_file.stimulation;
    n=numel(stim_info);
    time=[];
    label=cell(1,n);
    
    for i=1:n
        
        time=[time stim_info{1,i}.time];
        label{i}=stim_info{1,i}.label;
        
    end
    
     event_times=time;
    %event_labels=label;
    n_event=n;
    
    
    for j=1:n_event
    event_labels(j,:)=string(label{1,j});
    end
    
end



%% LfpMTD plot

if strcmp(data_type,'lfpMTD')
    
    
    if numel(fieldnames(lfps_data.lfpMTD))==2
        
        data_R=lfps_data.lfpMTD.Right;
        data_L=lfps_data.lfpMTD.Left;
        
        
        %left
        time_L=[];
        signal_L=[];
        if numel(data_L)>=1
            
            Nseg_L=numel(data_L);
            for i=1:Nseg_L
                
                data2=data_L{1,i};
                LFPs=data2.LFPs;
                
                channels=data2.channels;
                channels=strrep( channels, 'ZERO', '0' );
                channels=strrep( channels, 'ONE', '1' );
                channels=strrep( channels, 'TWO', '2' );
                channels=strrep( channels, 'THREE', '3' );
                channels=strrep( channels, 'RIGHT', 'R' );
                channels=strrep( channels, 'LEFT', 'L' );
                channels=strrep( channels, '_', '-' );
                channels=strrep( channels, '-AND-', '-' );
                channels_L=channels; clear channels;
                
                ti=data2.ti;
                ti_lfpM=ti;
                
                
                 for j=1:6
                signals(:,j)=LFPs{1,j};
                 end
                 
                 delta_t=size(signals,1)/250;
                 tf=ti+seconds(delta_t);
                 time=linspace(ti,tf,size(signals,1)); clear delta_t ti tf;
                 
                 time_L=[time_L time]; clear time;
                signal_L=[signal_L; signals]; clear signals LFPs data2;
            end
        end
            
        %left
        time_R=[];
        signal_R=[];
        if numel(data_R)>=1
            
            Nseg_R=numel(data_R);
            for i=1:Nseg_R
                
                data2=data_R{1,i};
                LFPs=data2.LFPs;
                
                channels=data2.channels;
                channels=strrep( channels, 'ZERO', '0' );
                channels=strrep( channels, 'ONE', '1' );
                channels=strrep( channels, 'TWO', '2' );
                channels=strrep( channels, 'THREE', '3' );
                channels=strrep( channels, 'RIGHT', 'R' );
                channels=strrep( channels, 'LEFT', 'L' );
                channels=strrep( channels, '_', '-' );
                channels=strrep( channels, '-AND-', '-' );
                channels_R=channels; clear channels;
                
                ti=data2.ti;
                ti_lfpM=ti;
                
                 for j=1:6
                signals(:,j)=LFPs{1,j};
                 end
                 
                 delta_t=size(signals,1)/250;
                 tf=ti+seconds(delta_t);
                 time=linspace(ti,tf,size(signals,1)); clear delta_t ti tf;
                 
                 time_R=[time_R time]; clear time;
                signal_R=[signal_R; signals]; clear signals LFPs data2;
            end
        end
        
        time_R_RT=time_R+delay_h+delay_m+delay_s;
        time_L_RT=time_L+delay_h+delay_m+delay_s;
            
        %PLOT
        if numel(event_type)==0
            
            figure
            eeg_visual(time_L_RT,signal_L,channels_L)
            title([PatID,': LfpMTD Data - Left Hemisphere; File ',file])
            xlabel('Time')
            ylabel('LFP Magnitude (uV)')
            set(gca,'FontSize',16)
            
            if numel(plot_interval)>0
                xi=plot_interval(1); xi=xi{1,1};
                xf=plot_interval(2); xf=xf{1,1};
                xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xlim([xi_date xf_date])
            end
            
            figure
            eeg_visual(time_R_RT,signal_R,channels_R)
            title([PatID,': LfpMTD Data - Right Hemisphere; File ',file])
            xlabel('Time')
            ylabel('LFP Magnitude (uV)')
            set(gca,'FontSize',16)
            
             if numel(plot_interval)>0
                xi=plot_interval(1); xi=xi{1,1};
                xf=plot_interval(2); xf=xf{1,1};
                xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xlim([xi_date xf_date])
            end
            
        else
             
        id_eve_L=find(event_times>=time_L_RT(1) & event_times <= time_L_RT(end));
        id_eve_R=find(event_times>=time_R_RT(1) & event_times <= time_R_RT(end));
         
            figure
           eeg_visual(time_L_RT,signal_L,channels_L,event_times(id_eve_L),event_labels(id_eve_L))
            title([PatID,': LfpMTD Data - Left Hemisphere; File ',file])
            xlabel('Time')
            ylabel('LFP Magnitude (uV)')
            set(gca,'FontSize',16)
            
             if numel(plot_interval)>0
                xi=plot_interval(1); xi=xi{1,1};
                xf=plot_interval(2); xf=xf{1,1};
                xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xlim([xi_date xf_date])
            end
            
            figure
            eeg_visual(time_R_RT,signal_R,channels_R,event_times(id_eve_R),event_labels(id_eve_R))
            title([PatID,': LfpMTD Data - Right Hemisphere; File ',file])
            xlabel('Time')
            ylabel('LFP Magnitude (uV)')
            set(gca,'FontSize',16)
            
             if numel(plot_interval)>0
                xi=plot_interval(1); xi=xi{1,1};
                xf=plot_interval(2); xf=xf{1,1};
                xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
                xlim([xi_date xf_date])
            end
            
        
        end
        
        
        
        
        
    end
    
    
    
    % ..............
    %Fisrt structure
    
    
    if numel(fieldnames(lfps_data.lfpMTD))>2

    data=lfps_data.(data_type);
    N=data.Nseg;
    signal_pass1=[];
    signal_pass2=[];
    all_time_pass1=[];
    all_time_pass2=[];
    sf=250;
    
    for i=1:N
    
        if mod(i,2)==1 %labels = pass 1
            labels_pass1={'0-3 L','1-3 L','0-2 L','0-3 R ','1-3 R','0-2 R'};
            lfpMTD_seg=data.data{1,i};
        
            for j=1:6
                lfpMTD_seg2(:,j)=lfpMTD_seg{1,j};
            end
            
            n=size(lfpMTD_seg2,1);
            ti=data.tseg_i{1,i};
            tf=data.tseg_f{1,i};
            T=linspace(ti,tf,n);
            all_time_pass1=[all_time_pass1 T];
            signal_pass1=[signal_pass1; lfpMTD_seg2];
        
            clear lfpMTD_seg; clear lfpMTD_seg2; clear n; clear ti; clear tf; clear T
        
        
        end
    
        if mod(i,2)==0 %labels = pass 2
            labels_pass2={'0-1 L','1-2 L', '2-3 L','0-1 R','1-2 R','2-3 R'};
            lfpMTD_seg=data.data{1,i};
            for j=1:6
                lfpMTD_seg2(:,j)=lfpMTD_seg{1,j};
            end
            
            n=size(lfpMTD_seg2,1);
            ti=data.tseg_i{1,i};
            tf=data.tseg_f{1,i};
            T=linspace(ti,tf,n);
            all_time_pass2=[all_time_pass2 T];
            signal_pass2=[signal_pass2; lfpMTD_seg2];
        
        clear lfpMTD_seg; clear lfpMTD_seg2; clear n; clear ti; clear tf; clear T
        
        end
    
    end

    all_time_pass1_RT=all_time_pass1+delay_h+delay_m+delay_s;
    all_time_pass2_RT=all_time_pass2+delay_h+delay_m+delay_s;
    
    f1=figure
    if numel(event_type)==0
        eeg_visual(all_time_pass1_RT,signal_pass1,labels_pass1)
    else
        id_eve=find(event_times>=all_time_pass1_RT(1) & event_times <= all_time_pass1_RT(end));
         eeg_visual(all_time_pass1_RT,signal_pass1,labels_pass1,event_times(id_eve),event_labels(id_eve))
    end
        
        
    title([PatID,': LfpMTD Data (Channels Pass1) - File ',file])
    xlabel('Time')
    ylabel('LFP Magnitude (uV)')
    set(gca,'FontSize',16)
    
%     if edf_conversion==1
%     
%      filename_edf_pass1=[PatID,'_file',file,'_data_',data_type,'Pass1_delay_',delay];
%      filename_edf_pass2=[PatID,'_file',file,'_data_',data_type,'Pass2_delay_',delay];
%       
%      header_pass1.samplingrate=sf;
%       header_pass1.numchannels=numel(labels_pass1);
%       header_pass1.channels=labels_pass1;
%       header_pass1.year=year(all_time_pass1_RT(1));
%       header_pass1.month=month(all_time_pass1_RT(1));
%       header_pass1.day=day(all_time_pass1_RT(1));
%       header_pass1.hour=hour(all_time_pass1_RT(1));
%       header_pass1.minute=minute(all_time_pass1_RT(1));
%       header_pass1.second=second(all_time_pass1_RT(1));
%   lab_write_edf(filename_edf_pass1, signal_pass1', header_pass1)
%     
%   header_pass2.samplingrate=sf;
%       header_pass2.numchannels=numel(labels_pass2);
%       header_pass2.channels=labels_pass2;
%       header_pass2.year=year(all_time_pass2_RT(1));
%       header_pass2.month=month(all_time_pass2_RT(1));
%       header_pass2.day=day(all_time_pass2_RT(1));
%       header_pass2.hour=hour(all_time_pass2_RT(1));
%       header_pass2.minute=minute(all_time_pass2_RT(1));
%       header_pass2.second=second(all_time_pass2_RT(1));
%   lab_write_edf(filename_edf_pass2, signal_pass2', header_pass2)
%     end
    
    if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
    end
    
    f2=figure
    
     if numel(event_type)==0
        eeg_visual(all_time_pass2_RT,signal_pass2,labels_pass2)
    else
        id_eve=find(event_times>=all_time_pass2_RT(1) & event_times <= all_time_pass2_RT(end));
         eeg_visual(all_time_pass2_RT,signal_pass2,labels_pass2,event_times(id_eve),event_labels(id_eve))
    end
   
    f=[f1 f2];
    title([PatID,': LfpMTD Data (Channels Pass2) - File ',file])
    xlabel('Time')
    ylabel('LFP Magnitude (uV)')
    set(gca,'FontSize',16)
    
     if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
     end
    
     
    end
    
     
end

%% LfpM

if strcmp(data_type,'lfpM')
    
    lfpM=lfps_data.lfpM;
    lfpMTD=lfps_data.lfpMTD;
    freq=lfpM.freq;
    
    channels_L=lfpM.channels_L;
   
                channels_L=strrep( channels_L, 'ZERO', '0' );
                channels_L=strrep( channels_L, 'ONE', '1' );
                channels_L=strrep( channels_L, 'TWO', '2' );
                channels_L=strrep( channels_L, 'THREE', '3' );
                channels_L=strrep( channels_L, 'RIGHT', 'R' );
                channels_L=strrep( channels_L, 'LEFT', 'L' );
                channels_L=strrep( channels_L, '_', '-' );
                channels_L=strrep( channels_L, '-AND-', '-' );
                channels_L=strrep(channels_L,'SensingElectrodeConfigDef.','');
                
                
    channels_R=lfpM.channels_R;
    
                channels_R=strrep( channels_R, 'ZERO', '0' );
                channels_R=strrep( channels_R, 'ONE', '1' );
                channels_R=strrep( channels_R, 'TWO', '2' );
                channels_R=strrep( channels_R, 'THREE', '3' );
                channels_R=strrep( channels_R, 'RIGHT', 'R' );
                channels_R=strrep( channels_R, 'LEFT', 'L' );
                channels_R=strrep( channels_R, '_', '-' );
                channels_R=strrep( channels_R, '-AND-', '-' );
                channels_R=strrep(channels_R,'SensingElectrodeConfigDef.','');
   
    N=numel(channels_L);
 time=max([lfpMTD.Left{1,end}.ti lfpMTD.Right{1,end}.ti]);
time_RT=time+delay_h+delay_m+delay_s;
    
    dataL=lfpM.mag_L;
    dataR=lfpM.mag_R;
    
    
    %Two subplots: left and right
    subplot(2,1,1)
    p1=plot(dataL,'LineWidth',2)
    xlabel('Frequency (Hz)')
    ylabel('Lfp Magnitude (uV)')
    title('Left Hemisphere')
    legend(p1,channels_L)
    set(gca,'FontSize',14)
    subplot(2,1,2)
    plot(dataR,'LineWidth',2)
    xlabel('Frequency (Hz)')
    ylabel('Lfp Magnitude (uV)')
    title('Right Hemisphere')
    legend(channels_R)
    set(gca,'FontSize',14)
    suptitle([PatID,': lfpM Data - File ',file,' ; time: ',datestr(time_RT)])
    set(gca,'FontSize',18)



    
    
%     %One plot (Left and Right) for cantact
%     hold on
%     
%     for i=1:N
%         
%         channels_L2=channels_L(i);
%         channels_L2=channels_L2{1,1};
%         channels_R2=channels_R(i);
%         channels_R2=channels_R2{1,1};
%         
%         p(i)=figure
%         hold on
%         plot(freq,dataL(:,i),'r','LineWidth',2)
%         plot(freq,dataR(:,i),'b','LineWidth',2)
%         A=[dataL(:,i);dataR(:,i)];
%         legend('Left Hemisphere','Right Hemisphere')
%         %ylim([0 2.5])
%         xlabel('Frequency (Hz)')
%         ylabel('Lfp Magnitude (uV)')
%         ylim([0 max(A(:))+0.5])
%         title([PatID,': lfpM Data - File ',file,' ; Contacts: ',channels_L2(1:3),' ; time: ',datestr(time_RT)])
%         set(gca,'FontSize',14)
%     
%     
%     end
%     
%     

end




%% IS

if strcmp(data_type,'IS')
    
    data=lfps_data.(data_type);
    Nseg=data.Nseg;
    signal=[];
    all_time=[];
    labels=data.labels;
    sf=data.sf;
    
      for i=1:Nseg
        IS_seg=data.data{1,i}; 
        ti=data.tseg_i{1,i};
        tf=data.tseg_f{1,i};
        n=size(IS_seg,1);
        T=linspace(ti,tf,n);
        all_time=[all_time T];
        signal=[signal; IS_seg];
        clear IS_seg; clear n; clear T; clear ti; clear tf;    
      end
    
      all_time_RT=all_time+delay_h+delay_m+delay_s;
      
    
      f=figure
      if numel(event_type)==0
        eeg_visual(all_time_RT,signal,labels)
      else
          id_eve=find(event_times>=all_time_RT(1) & event_times <= all_time_RT(end));
          eeg_visual(all_time_RT,signal,labels,event_times(id_eve),event_labels(id_eve))
      end
      
      title([PatID,': IS Data - File ',file])
      xlabel('Time')
      ylabel('LFP Magnitude (uV)')
      set(gca,'FontSize',16)
      
%       %edf conversion
%       filename_edf=[PatID,'_file',file,'_data_',data_type,'_delay_',delay];
%       header.samplingrate=sf;
%       header.numchannels=numel(labels);
%       header.channels=labels;
%       header.year=year(all_time_RT(1));
%       header.month=month(all_time_RT(1));
%       header.day=day(all_time_RT(1));
%       header.hour=hour(all_time_RT(1));
%       header.minute=minute(all_time_RT(1));
%       header.second=second(all_time_RT(1));
%       lab_write_edf(filename_edf, signal', header)
%       
    
     if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
     end
    
    
end

%% BSS

if strcmp(data_type,'BSS')
    
    
    
   
    data=lfps_data.(data_type);
    
    %both hemispheres
    if numel(data.labels)>1
    N=data.Nseg;
    sf=250;

    Nseg=data.Nseg;
    N=Nseg/2;

    signal=[];
    all_time=[];
    
    n_labels=numel(data.labels);
    
    
    labels={data.labels{1,1} data.labels{1,2}};
    labels=regexprep(labels,{'ZERO','ONE','TWO','THREE','LEFT','RIGHT','_'},{'0','1','2','3','L','R','-'});
    
    
    

    for i=1:N
    
        seg1=data.data{1,2*i-1};
        seg2=data.data{1,2*i};

        seg=[seg1 seg2];
        signal=[signal; seg];
        n=size(seg1,1);
        ti=data.tseg_i{1,2*i-1};
        tf=data.tseg_f{1,2*i-1};
        T=linspace(ti,tf,n);
        all_time=[all_time T];

        clear seg1; clear seg2; clear seg; clear n; clear ti; clear tf; clear T;

    end
    
      all_time_RT=all_time+delay_h+delay_m+delay_s;
      
     
    
      f=figure
      if numel(event_type)==0
      eeg_visual(all_time_RT,signal,labels)
      else
          id_eve=find(event_times>=all_time_RT(1) & event_times <= all_time_RT(end));
          eeg_visual(all_time_RT,signal,labels,event_times(id_eve),event_labels(id_eve))
      end
          
      %title([PatID,': BSS Data - File ',file])
      title([PatID,': BSS Data - File ',file])
      xlabel('Time')
      ylabel('LFP Magnitude (uV)')
      set(gca,'FontSize',16)
      
      
%       %edf conversion
%       filename_edf=[PatID,'_file',file,'_data_',data_type,'_delay_',delay];
%       header.samplingrate=sf;
%       header.numchannels=numel(labels);
%       header.channels=labels;
%       header.year=year(all_time_RT(1));
%       header.month=month(all_time_RT(1));
%       header.day=day(all_time_RT(1));
%       header.hour=hour(all_time_RT(1));
%       header.minute=minute(all_time_RT(1));
%       header.second=second(all_time_RT(1));
%       lab_write_edf(filename_edf, signal', header)
    
      if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
      end
     
    end
    
    
    %one hemisphere
    if numel(data.labels)==1
        
        labels={data.labels{1,1}};
    labels=regexprep(labels,{'ZERO','ONE','TWO','THREE','LEFT','RIGHT','_'},{'0','1','2','3','L','R','-'});
        
        N=data.Nseg;
        
        all_time=[];
        signal=[];
        
        for i=1:N
            
            seg=data.data{1,i};
       
        signal=[signal; seg];
        n=size(seg,1);
        ti=data.tseg_i{1,i};
        tf=data.tseg_f{1,i};
        T=linspace(ti,tf,n);
        all_time=[all_time T];

        clear seg; clear n; clear ti; clear tf; clear T;
            
        end
        
        all_time_RT=all_time+delay_h+delay_m+delay_s;
        
        f=figure
      if numel(event_type)==0
      eeg_visual(all_time_RT,signal,labels)
      else
          id_eve=find(event_times>=all_time_RT(1) & event_times <= all_time_RT(end));
          eeg_visual(all_time_RT,signal,labels,event_times(id_eve),event_labels(id_eve))
      end
          
      %title([PatID,': BSS Data - File ',file])
      title([PatID,': BSS Data - File ',file])
      xlabel('Time')
      ylabel('LFP Magnitude (uV)')
      set(gca,'FontSize',16)
    
      if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
      end
      
     
    end
    
    
        
end
    
    
    
     
        

    
    



%% BST

if strcmp(data_type,'BST')
    
 
    
    BST=lfps_data.(data_type);
    
    %BOTH HEMISPHERES
    if numel(fieldnames(BST))==2
        
    n=size((BST.LeftHemisphere),2);
    signal_L=[];
    signal_R=[];
    signal_amp_L=[];
    signal_amp_R=[];
    all_time=[];
    
    for i=1:n
    data_L=BST.LeftHemisphere(i).data;
    data_R=BST.RightHemisphere(i).data;
    time=BST.LeftHemisphere(i).time;
    
    Stim_Amp_L=BST.LeftHemisphere(i).StimAmp;
    Stim_Amp_R=BST.RightHemisphere(i).StimAmp;
    
    n2=numel(data_L);
    
    for j=1:n2
        data_L2(:,j)=data_L{1,j}; 
        data_R2(:,j)=data_R{1,j};
        time2(:,j)=time{1,j};
        Stim_Amp_L2(:,j)=Stim_Amp_L{1,j};
        Stim_Amp_R2(:,j)=Stim_Amp_R{1,j};
    end
    
    data_R3=smooth(data_R2);
    data_L3=smooth(data_L2);
    
    signal_L=[signal_L; data_L3];
    signal_R=[signal_R ;data_R3];
    signal_amp_L=[signal_amp_L Stim_Amp_L2];
    signal_amp_R=[signal_amp_R Stim_Amp_R2];
    all_time=[all_time time2];
    
    clear data_L data_R time Stim_Amp_L Stim_Amp_R n2 data_L2 data_R2 time2 Stim_Amp_L2 Stim_Amp_R2;
    clear data_R3 data_L3;
    
    end
    
    all_time=all_time+delay_h+delay_m+delay_s;
    
    %LFPs plot
    p=figure
    hold on
    yyaxis left
    p1=plot(all_time,signal_R,'b.','LineWidth',1.5,'MarkerSize',15)
    plot(all_time,signal_R,'b','LineWidth',1.5)
    p2=plot(all_time,signal_L,'r.','LineWidth',1.5,'MarkerSize',15)
    plot(all_time,signal_L,'r','LineWidth',1.5)
    ylim([0 ymax])
    ylabel('LFP Power')
    
    
    %event plot
    %n=numel(event_times);
    if (numel(event_type)>0 & strcmp(event_type,'Sleep')==0)
    for i=1:n_event
        
        hold on
        plot([event_times{1,i} event_times{1,i}],[0 ymax],'k-','LineWidth',3)
        
        
       
    end
    
    end
    
    if (numel(event_type)>0 & strcmp(event_type,'Sleep')==1)
        
          % nrem plot
    
    
    for i=1:size(nrem,1)
        
        ti=nrem{i,1};
        tf=nrem{i,2};
        seg=linspace(ti,tf,1000);
        area(seg,ymax.*ones(1,numel(seg)),'FaceColor','g','FaceAlpha',.1,'EdgeAlpha',.1)  %%%%%
    end
    
    clear seg ti tf
    
    %rem plot
    
    
    for i=1:size(rem,1)
        
        ti=rem{i,1};
        tf=rem{i,2};
        seg=linspace(ti,tf,1000);
        area(seg,ymax*ones(1,numel(seg)),'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',.3)  %%%%%
    end
    
        
        
    end
    
    
    
    

    
    clear seg ti tf
    
    
    
    yyaxis right
    p3=plot(all_time,signal_amp_L,'m','LineWidth',1.5)
    legend([p1, p2, p3],'Right Hemisphere (RH)','Left Hemisphere (LH)','Stimulation Amplitude (RH/LH)')
    ylim([0 6])
    ylabel('Stimulation Amplitude (mA)')
    xlabel('Time')
    
    title([PatID,': BST Data - File ',file])
    set(gca,'FontSize',14)
    
    if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
    end
     
    end
    
    
    
    
    %ONE HEMISPHERE
    if numel(fieldnames(BST))==1
        
        hemisphere=fieldnames(BST);
        h=hemisphere{1,1};
        
        BST2=BST.(h);
        
        n=size((BST2),2);
    signal=[];
   
    signal_amp=[];
    
    all_time=[];
    
    for i=1:n
    data=BST2(i).data;
   
    time=BST2(i).time;
    
    Stim_Amp=BST2(i).StimAmp;
   
    
    n2=numel(data);
    
    for j=1:n2
        data_2(j)=data{1,j}; 
       
        time2(j)=time{1,j};
        Stim_Amp_2(j)=Stim_Amp{1,j};
        
    end
    
    data_3=smooth(data_2);
  
    
    signal=[signal; data_3];
 
    signal_amp=[signal_amp Stim_Amp_2];
    
    all_time=[all_time time2];
    
    clear data time Stim_Amp  n2 data_2  time2 Stim_Amp_2
    clear data_3 data_3;
    
    end
    
    all_time=all_time+delay_h+delay_m+delay_s;
    
     
    
    %LFPs plot
    p=figure
    hold on
    yyaxis left
    p1=plot(all_time,signal,'k.','LineWidth',1.5,'MarkerSize',15)
    plot(all_time,signal,'k','LineWidth',1.5)
    ylim([0 ymax])
    ylabel('LFP Power')
    
    
    %event plot
    %n=numel(event_times);
    if numel(event_type)>0
    for i=1:n_event
        
        hold on
        plot([event_times(i) event_times(i)],[0 1000],'k-','LineWidth',3)
        
%         if (i==4|i==6)
%             text([event_times(i) event_times(i)], [720 720], event_labels{i},'FontSize',12)
%         else
%         text([event_times(i) event_times(i)], [700 700], event_labels{i},'FontSize',12)
%         end
       
    end
    
    end
    
    
    
    
    clear seg ti tf
    
    
    
    yyaxis right
    p3=plot(all_time,signal_amp,'m','LineWidth',1.5)
    
    if contains(h,'Right')
     legend([p1,p3],'Right Hemisphere (RH)','Stimulation Amplitude (RH/LH)') 
    end
    
     if contains(h,'Left')
     legend([p1,p3],'Left Hemisphere (LH)','Stimulation Amplitude (RH/LH)') 
    end
    
   
    
    ylim([0 5])
    ylabel('Stimulation Amplitude (mA)')
    xlabel('Time')
    
    title([PatID,': BST Data - File ',file])
    set(gca,'FontSize',14)
    
    if numel(plot_interval)>0
        xi=plot_interval(1);
        xi=xi{1,1};
        xf=plot_interval(2);
        xf=xf{1,1};
        
        xi_date=datetime([xi(1:10),'T',xi(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xf_date=datetime([xf(1:10),'T',xf(12:end),'Z'],'InputFormat', 'dd-MM-uuuu''T''HH:mm:ss''Z');
        xlim([xi_date xf_date])
    end
     
    
    end
    
end
%% LfpSnap

if strcmp(data_type,'LfpSnap')
    data=lfps_data.(data_type);
    %BOTH HEMISPHERES
    
    if numel(fieldnames(data))==2
    
    data_L=data.LeftHemisphere;
    data_R=data.RightHemisphere;
    
    n_ev=numel(data_L);
    for i=1:n_ev
        freq=data_L(i).freq;
        signal_L=data_L(i).data;
        signal_R=data_R(i).data;
        medLab=data_L(i).medicalLabel;
        if numel(signal_L)>0
            
        A=[signal_L;signal_R];
        time=data_L(i).time;
        time_RT=time+delay_h+delay_m+delay_s;
        
        figure
        hold on
        plot(freq,signal_L,'r','LineWidth',2)
        plot(freq,signal_R,'b','LineWidth',2)
        xlabel('Frequency (Hz)')
        ylabel('Lfp Magnitude (uV)')
        legend('Left Hemisphere','Right Hemisphere')
        ylim([0 max(A(:))+0.5])
        title(['LfpSnap - file: ',file,' ; event: ',num2str(i),' ; time: ',datestr(time_RT),' label: ',medLab])
        set(gca,'FontSize',16)
        end
        
    end
    
    end
    
    %ONE HEMISPHERE
    
    if numel(fieldnames(data))==1
    hemisphere=fieldnames(data);
    h=hemisphere{1,1};
    data=data.(h);
    
    
     n_ev=numel(data);
    for i=1:n_ev
        freq=data(i).freq;
        signal=data(i).data;
        
        medLab=data(i).medicalLabel;
        if numel(signal)>0
            
        
        time=data(i).time;
        time_RT=time+delay_h+delay_m+delay_s;
        
        figure
        hold on
        plot(freq,signal,'k','LineWidth',2)
        
        xlabel('Frequency (Hz)')
        ylabel('Lfp Magnitude (uV)')
        
        if contains(h,'Left')
        legend('Left Hemisphere')
        end
        
        if contains(h,'Right')
            legend('Right Hemisphere')
        end
        ylim([0 max(signal(:))+0.5])
        title(['LfpSnap - file: ',file,' ; event: ',num2str(i),' ; time: ',datestr(time_RT),' label: ',medLab])
        set(gca,'FontSize',16)
        end
        
    end
    
   
    
end


end

end