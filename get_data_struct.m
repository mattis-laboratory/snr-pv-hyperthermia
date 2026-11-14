%% Load Session Table
clear; close all
load('/nfs/turbo/umms-mattislab/Chandni/Data/SNr_all/sessionTable.mat');

% %% Filter data
% tbl = sessionTable( ...
%       sessionTable.heatSpeed == 'F'  & ...
%       sessionTable.exclude   == false & ...
%       sessionTable.stim      == false & ... 
%       sessionTable.seizure   == true & ...
%       sessionTable.genotype  == 'H',:);

%% Create photometry, eeg, and events struct

% Photometry
zdff                      = struct();
zdff.fs                   = 1000;
zdff.signal               = zdffs;
%zdff.signal_hpf           = ;
zdff.t                    = ts;

dff                       = struct();
dff.fs                    = 1000;
dff.signal                = dffs;
dff.t                     = ts;

% EEG
eeg                       = struct();
eeg.fs                    = 1000;
eeg.signal                = eegs;
eeg.t                     = ts;

% Events
events                    = struct();
events.eeg.BL             = BLs;             
events.eeg.EEC            = EECs;             
events.eeg.UEO            = UEOs;             
events.eeg.OFF            = OFFs;    

events.zdff.BL            = BLs;              
events.zdff.EEC           = EECs;             
events.zdff.UEO           = UEOs;             
events.zdff.OFF           = OFFs;  

events.stimTimes          = []; 
events.injTimes           = inj_times;

% Stimulation Parameters (if applicable)
% stim                      = struct();
% if tbl.stim(1,:) == true
% stim.freq                 = 1;   % Hz
% stim.pulse_width          = 0.01; % s
% stim.laserPower           = tbl.laserPower;
% end

%% Nest into group structure

grp                       = struct();
grp.name                  = 'WT_PTZ';
grp.comments              = '';

grp.zdff                  = zdff;
grp.eeg                   = eeg;
grp.events                = events;
%grp.stimParams            = stim;
grp.sync                  = [];
%grp.temp                  = WT_temps;

grp.color                 = 'blue';
grp.rgb_m                 = [0, 0, 1];
%grp.rgb_s                 = [0.6 0.8 1];
grp.fsEEG                 = 1000;
grp.fsPhoto               = 100;
grp.region                = 'PPN';

grp.fatal                 = tbl.fatal;
grp.genotype              = tbl.genotype;
grp.seizure               = tbl.seizure;
grp.seizureType           = tbl.type;
%grp.stim                  = tbl.stim;
%grp.heatSpeed             = tbl.heatSpeed;
grp.info                  = tbl;
grp.mouseID               = tbl.mouse;
grp.sessionDate           = tbl.date;
%grp.fullID                = tbl.fullID;
grp.strain                = tbl.strain;
grp.sex                   = tbl.sex;
%grp.optoStart             = tbl.optoStart;
%grp.heatStart             = tbl.heatStart;
grp.exclude               = tbl.exclude;
grp.reason                = tbl.reason;

%% Save struct

save('WT_PTZ.mat',"-struct",'grp','-v7.3')
%save('WT_nsz_nostim.mat','dff','-append')
