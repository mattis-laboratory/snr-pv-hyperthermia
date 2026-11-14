
%% Plot event-triggered averages of camera aligned events
clear; close all
%% Load Params and Traces
params     = nostim_analysis_params();
load(params.trigAvgTraces,'all_*')
load(params.preprocFile,'rgb_m','info')

%% Get Means and SEMs for non-camera events
n_mice      = numel(unique(info.mouse));

IceON_mean      = nanmean(all_IceON);
IceON_sem       = nanstd(all_IceON, 1)/sqrt(n_mice);

IceOFF_mean     = nanmean(all_IceOFF);
IceOFF_sem      = nanstd(all_IceOFF, 1)/sqrt(n_mice);

LampON_mean     = nanmean(all_LampON);
LampON_sem      = nanstd(all_LampON, 1)/sqrt(n_mice);

LampOFF_mean    = nanmean(all_LampOFF);
LampOFF_sem     = nanstd(all_LampOFF, 1)/sqrt(n_mice);

CamSz_mean      = nanmean(all_CamSz);
CamSz_sem       = nanstd(all_CamSz, 1)/sqrt(n_mice);

p1 = 'IceON';
p2 = 'IceOFF';
p3 = 'LampON';
p4 = 'LampOFF';
p5 = 'CamSz';

%% plot group 1
[h1, ax1, f1] = plot_group_avg(IceON_mean, IceON_sem, rgb_m, p1);
ylim([-15 10])
[h2, ax2, f2] = plot_group_avg(IceOFF_mean, IceOFF_sem, rgb_m, p2);
ylim([-15 10])
[h3, ax3, f3] = plot_group_avg(LampON_mean, LampON_sem, rgb_m, p3);
ylim([-15 10])
[h4, ax4, f4] = plot_group_avg(LampOFF_mean, LampOFF_sem, rgb_m, p4);
ylim([-15 10])
[h5, ax5, f5] = plot_group_avg(CamSz_mean, CamSz_sem, rgb_m, p5);
ylim([-15 10])

%% plot group 2
[h6, ~, ~]    = plot_group_avg(IceON_mean, IceON_sem, rgb_m, p1, ax1);
ylim([-15 10])
[h7, ~, ~]    = plot_group_avg(IceOFF_mean, IceOFF_sem, rgb_m, p2, ax2);
ylim([-15 10])
[h8, ~, ~]    = plot_group_avg(LampON_mean, LampON_sem, rgb_m, p3, ax3);
ylim([-15 10])
[h9, ~, ~]    = plot_group_avg(LampOFF_mean, LampOFF_sem, rgb_m, p4,ax4);
ylim([-15 10])
[h10, ~, ~]   = plot_group_avg(CamSz_mean, CamSz_sem, rgb_m, p5,ax5);
ylim([-15 10])

%% plot group 3
[h11, ~, ~]   = plot_group_avg(IceON_mean, IceON_sem, rgb_m, p1, ax1);
ylim([-15 10])
[h12, ~, ~]   = plot_group_avg(IceOFF_mean, IceOFF_sem, rgb_m, p2, ax2);
ylim([-15 10])
[h13, ~, ~]   = plot_group_avg(LampON_mean, LampON_sem, rgb_m, p3, ax3);
ylim([-15 10])
[h14, ~, ~]   = plot_group_avg(LampOFF_mean, LampOFF_sem, rgb_m, p4,ax4);
ylim([-15 10])
[h15, ~, ~]   = plot_group_avg(CamSz_mean, CamSz_sem, rgb_m, p5,ax5);
ylim([-15 10])

