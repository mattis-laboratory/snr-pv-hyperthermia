%% EEC > UEO Time

clc; clear; close all;

params       = nostim_analysis_params();
params.group = 'het_sz';
load(params.preprocFile, 'events','info','fsEEG')
n_mice       = numel(unique(info.mouse));

%% Calculate UEO - EEC 

diffs = cell2mat(events.eeg.UEO(:,1)) - cell2mat(events.eeg.EEC); 
diffs = diffs/fsEEG;


mean_diff = mean(diffs);
sem_diff  = std(diffs)./sqrt(n_mice);
