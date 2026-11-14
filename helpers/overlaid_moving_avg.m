%% Plot moving averages from all groups (overlaid)
clear; close all
%% Load data
params     = nostim_analysis_params();
load(params.preprocFile,'rgb_m','info')
load([params.mavgTransientsFname,'_heat.mat'])

%% Get Means and SEMs
n_mice                  = numel(unique(info.mouse));

% Frequency
[freq_mean, freq_sem]   = get_avg_trace(moving_freq,n_mice);

% Amplitude
[amp_mean, amp_sem]     = get_avg_trace(moving_amp,n_mice);

%% Plot with Shaded Error Bar (run this manually in sections)
p1 = 'Frequency';
p2 = 'Amplitude';
%% plot 1
[h1, ax1, f1] = plot_moving_avg(freq_mean, freq_sem, rgb_m, p1);
[h2, ax2, f2] = plot_moving_avg(amp_mean, amp_sem, rgb_m, p2);
hold on
%% plot 2
[h3, ~, ~] = plot_moving_avg(freq_mean, freq_sem, rgb_m, p1,ax1);
[h4, ~, ~] = plot_moving_avg(amp_mean, amp_sem, rgb_m, p2,ax2);
%% plot 3
[h5, ~, ~] = plot_moving_avg(freq_mean, freq_sem, rgb_m, p1,ax1);
[h6, ~, ~] = plot_moving_avg(amp_mean, amp_sem, rgb_m, p2,ax2);

%% Save

% Save as fig and png
% saveas(f1, [params.maFile,'_',p1,'_heating'],'fig');   % Save as .fig file
% saveas(f1, [params.maFile,'_',p1,'_heating'],'png');   % Save as .png file
% delete(f1)
%
% saveas(f2, [params.maFile,'_',p2,'_heating'],'fig');   % Save as .fig file
% saveas(f2, [params.maFile,'_',p2,'_heating'],'png');   % Save as .png file
% delete(f2)

%% Spearman correlation of time vs. moving average amp and freq
%[rho, pVal] = corr([1:length(metric_pre_mean)]',metric_pre_mean',"type","Spearman","tail","both");

