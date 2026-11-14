clc; clear; close all

root = '/nfs/turbo/umms-mattislab/Chandni/Data/SNr_all/';
%load([root,'sessionTable.mat'])
dataDir = ([root,'groups/']);
cd(dataDir)

files = dir('*.mat');
filenames = {files.name}';

for numFile = 1 :numel(filenames)

grp = load(filenames{numFile});

temps = grp.temp;
BLs   = grp.events.eeg.BL;
UEOs  = grp.events.eeg.UEO;
EECs  = grp.events.eeg.EEC;
OFFs  = grp.events.eeg.OFF;

grp.UEO_temps = cellfun(@(t, idx) mean(t(idx)), temps, UEOs(:,1));
grp.EEC_temps = cellfun(@(t, idx) mean(t(idx)), temps, EECs(:,1));
grp.OFF_temps = cellfun(@(t, idx) mean(t(idx)), temps, OFFs(:,1));

% Seizure durations (time from UEO to OFF)
grp.sz_dur    = cellfun(@(i1, i2) i2-i1 ,UEOs(:,1),OFFs(:,1));

% Heating durations (time from BL to UEO)
grp.heat_dur  = cellfun(@(i1, i2) i2-i1 ,BLs(:,1),UEOs(:,1));

save(filenames{numFile},'-struct','grp','-v7.3')

clearvars -except root dataDir files numFile filenames

end






















