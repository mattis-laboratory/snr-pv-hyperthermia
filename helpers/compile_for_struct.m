%% Compile Preprocessed Data from All Animals / Sessions
% Chandni Rana - University of Michigan (09/2024)
% Compile preprocessed photometry, EEG, temperature, etc. data from all
% animals into single matrix
% ----------------------------------------------------------------------------------
% To update with data from new mice, after preprocessing, simply update the
% subs_info file with the mouse number and its session dates and make sure
% preprocessed data files can be read in through the script
% ----------------------------------------------------------------------------------

%% Load Session Table
clear; close all
load('/nfs/turbo/umms-mattislab/Chandni/Data/SNr_all/sessionTable.mat');

root               = '/nfs/turbo/umms-mattislab/Chandni/Data/';
project            = 'SNr_all';

%% Filter data
tbl = sessionTable( ...
      sessionTable.heatSpeed == 'F'  & ...
      sessionTable.exclude   == false & ...
      sessionTable.stim      == false & ... 
      sessionTable.seizure   == true & ...
      sessionTable.genotype  == 'H',:);
%% ****** Check Before Running *******
overwrite = 0; 

%% Compile Data 

subjects = tbl.mouse;
sessions = tbl.date;
num_sessions = height(sessions);

for sub = 1:length(subjects)
    datapath = strcat(root,project,'/',num2str(subjects(sub)),'/',sessions(sub));
    try
        load(strcat(datapath, '/isosbestic_subtraction/preproc_data.mat'),'zdff','markings','eeg','temp','zdff_hpf','dff','dff_hpf')

    catch
        load(strcat(datapath, '/preproc_data.mat'),'zdff','markings','eeg','temp','zdff_hpf','dff','dff_hpf')
    end
   % het_zdffs{sub,1}     = zdff; check for baseline z-score first
    het_zdffs_hpf{sub,1} = zdff_hpf;
    het_eegs{sub,1}      = eeg;
    het_dffs{sub,1}      = dff;
    het_temps{sub,1}     = temp;
    het_marks{sub,1}     = markings;
    clear zdff* markings eeg dff temp datapath 
end

