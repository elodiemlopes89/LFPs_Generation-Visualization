# LFPs_Generation-Visualization
Functions created under the framework of the PhD thesis "Novel Contributions to Personalized Brain Stimulation Biomarkers for Better Management of Neurological Disorders" - Doctoral Program in Biomedical Engineering (Faculty of Engineering of University of Porto), supervised by João P. Cunha (INESC TEC, Porto, Portugal).

## Scope
The new generation of the Medtronic Neurostimulator, Percept PC, employs BrainSense technology, which measures Local Field Potentials (LFPs), representing the total electrical activity of the group of neurons surrounding the recording contact. 

The Percept PC can sense brain data in four different modes: (1) BrainSense Survey, which provides a broad spatial overview of LFP signals during stimulation off, from which clin- icians select a frequency band of interest for each patient for chronic recordings; (2) BrainSense Timeline, recording power domain signals in the selected frequency band over time; (3) Brain- Sense Events, recorded when the patient activates an event on a "companion" tablet pre-configured by the clinician; (4) BrainSense Streaming, offering real-time LFP recordings in the selected frequency band. 

During the mentioned PhD, LFPs and video-electroecnephalogram (vEEG) signals were simultaneously collected from 4 epilepsy patients, implanted with the Percept PC in the Anterior Nucleus of the Thalamus, at Centro Hospitalar S. João, Porto, Portugal.

## Clinical Protocols for vEEG-LFPs Acquisition:

### Clocks synchronization protocol
It was utilized to align the Percept and vEEG clocks. To achieve this synchronization, time-domain LFPs should be continuously recorded using the BrainSense Survey mode (Indefinite Streaming signals) while clinicians execute tapping maneuvers. These maneuvers entail gently tapping the entry points of the EEG cables on the patient’s head. A minimum of 5 tapping maneuvers is advisable to ensure clock synchronization, as artifacts produced by the tapping may not always be immediately visible in LFPs. Given that clock delays might fluctuate over time, it is recommended to execute this protocol daily during the patient’s stay in the EMU at the same time of day. Maintaining this consistency aids in eliminating variables associated with the patient’s circadian cycle. It is essential to note that the patient should remain at rest and focus solely on performing the maneuvers to avoid introducing additional artifacts into the signal.

### ANT-target localization protocol
It was designed to ascertain the lead contact that is more centrally positioned within the ANT. To achieve this, a minimum of 8 LfpMontageTimeDomain signals using the BrainSense Survey should be recorded while the patient is at rest.

### Seizure protocol
t was devised to capture seizures during LFP recordings. To accomplish this, time-domain data (indefinite streaming with stimulation turned off or BSS signals with stimulation active) should be recorded for extended periods when the patient is more likely to experience seizures. For example, if the patient usually experiences seizures while falling asleep, this protocol should be initiated each time the patient begins to fall asleep. Moreover, LFPSnap should be recorded when the patient experiences an aura during this protocol.

### Resting-state protocol
It was used to record LFPs with the patient at rest without any distractions, such as watching television, using a cellphone, or eating. To execute this, a minimum of 10 minutes of LFPs should be recorded using the BrainSense Survey mode (Indefinite Streaming signals). 

### Stimulation protocol
It involves LFP recordings using the BrainSense Streaming mode. To execute this, 1 to 2 minutes of data should be recorded for each set of stimulation parame- ters, and 8 to 10 minutes for the final selected stimulation parameter set. The patient must remain at rest during this protocol. The primary objective of this protocol is to assess po- tential changes in LFPs at various stimulation parameters. Additionally, this protocol serves to synchronize the clocks of the Percept PC and vEEG when tapping maneuvers are not discernible in the LFP signals.

### Movements protocol
It was designed to assess the ANT’s involvement during focal automatisms. To conduct this evaluation, time-domain data (in- definite streaming with stimulation turned off or BSS signals with stimulation on) should be recorded while the patient performs a series of predefined movements.



## Clinical Information:
In addition to LFPs and vEEG recordings, relevant clinical information was also documented, including:
* Seizure details (clinical and electrographic onset and offset, along with semiology);
* Timestamps indicating sleep stages (awake, non-rapid eye movement (NREM), rapid eye movement (REM));
* Medication specifics (time and dosage);
* Conducted clinical tests (e.g., tapping maneuvers, movement protocols, neurological motor examination, postictal tests);
* Stimulation information (activation time and stimulation amplitude);
* Patient movements (e.g., walking, bathroom visits, etc.).

To streamline the extraction of these patient-recorded events, an Excel template named "ClinicalTimeline.xlsx" was developed. This template is populated by ex- porting the clinical tracings filled in the clinical software. The first column in the Excel sheet corresponds to the vEEG time code utilized by clinicians. Each event is then enumerated and categorized based on the clinician-defined event label: clinical tests, seizures, sleep cycles, stimulation, medication, and patient movements.

## Data and Code Organization:
For each patient undergoing simultaneous vEEG and LFPs acquisition in the Epilepsy Monitoring Unit (EMU), a directory labeled "PDX" was created, where X represents the patient’s ID (e.g., PD01). This directory is situated within a hospital-specific main directory where the data acquisition occurred. Within the patient’s folder, five subfolders were generated:

1. Clinical Information: Contains all patient-related information.
2. Clinical Timeline: Includes the Excel file filled out by clinicians.
3. Docs: Houses all notes and results.
4. JsonFiles: Contains all LFPs recorded, saved in JSON file format.
5. matFiles: Intended for storing data converted into MATLAB arrays.

After LFP recordings, the data were stored in JSON file format within the Reports section of the Medtronic Clinician Programmer. Subsequently, these files were copied to the "JsonFiles" directory and renamed following the format:

>> fileY_yyyymmdd_HH_MM_Report Medtronic number.json

In this context, Y represents the number assigned to each JSON file, yyyy corresponds to the year, mm to the month, dd to the day, HH to the hour, and MM to the minute of the JSON file’s creation. "Report Medtronic number" is the designation used to identify the JSON file in the Clinician Programmer. This naming convention was adopted to simplify the identification of JSON files concerning observed clinical events.

Once the proposed data organization was established, several MATLAB custom-made func- tions were developed, using MATLAB version R2016b.

### Jason2mat.m
The "Jason2mat.m" function was designed to extract data and information from LFPs’ JSON files and assemble them into a MATLAB structure array file labeled as PDX_hospital.mat, where X represents the patient ID, and hospital denotes the hospital where the LFPs were recorded.

It is worth noting that during the development of this function, various Medtronic organization structures were identified in the files (lfpMTD signals: 2 structures; lfpM signals: 3 structures; lfpSnap signals: 3 structures; BSS signals: 2 structures; stimulation parameters information: 4 structures). Consequently, this function needs to be regularly updated whenever there is a new patient or any updates from Medtronic.


### Event2mat.m
The "Events2mat.m" function converts information from the "ClinicalTimeline.xlsx" file, initially saved in the patient’s "ClinicalTimeline" folder into two separate mat files:
* eve_file_PDX_hospital.mat, containing dates and times of clinical events;
* sleep_file_PDX_hospital.mat, containing dates and times of sleep stages (awake, NREM,and REM).

These files are saved on the patient’s "matFiles" folder and are then used as inputs for data visualization.

### PlotGenerator.m
The "PlotGenerator.m" function was designed for plotting LFP signals in conjunction with clinical events. Its inputs comprise the following parameters:
* Patient ID (e.g., PD_01_HSJ).
* File: the file number containing the desired data for plotting.
* Delay: the time delay between the Percept PC and vEEG clocks.
* Event type: clinical events categorized into seizures, tapping maneuvers, movements, stim- ulation, or sleep stages.
* Data type: the type of LFP signals to be plotted (IS, BSS, LfpMTD, LfpM, BST, LfpSnap).
* Plot interval: the specified time range for plotting the data.

Plot can also be generated only for time-domain LFPs (TD_Data.m), frequency-domain LFPs (FD_Data) and power-domain LFPs (PD_Data).

### ExportJsonInfo.m
The "ExportJsonInfo.m" function can be used to quickly export the information contained in the PD_X_hospital.mat files.


