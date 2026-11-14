
clear; close all; 
%set(groot, 'DefaultFigureRenderer', 'opengl')

%% Load Params and Traces
params     = nostim_analysis_params();
load(params.trigAvgTraces,'all_*')
load(params.preprocFile,'rgb_m','info')

%% Get Means and SEMs for non-camera events
n_mice      = numel(unique(info.mouse));

EEC_mean    = nanmean(all_EEC);
EEC_sem     = nanstd(all_EEC, 1)/sqrt(n_mice);

UEO_mean    = nanmean(all_UEO);
UEO_sem     = nanstd(all_UEO, 1)/sqrt(n_mice);

OFF_mean    = nanmean(all_OFF);
OFF_sem     = nanstd(all_OFF, 1)/sqrt(n_mice);

p1 = 'EEC';
p2 = 'UEO';
p3 = 'OFF';

%% plot group 1
[h1, ax1, f1] = plot_group_avg(EEC_mean, EEC_sem, rgb_m, p1);
ylim([-15 10])

[h2, ax2, f2] = plot_group_avg(UEO_mean, UEO_sem, rgb_m, p2);
ylim([-15 10])

[h3, ax3, f3] = plot_group_avg(OFF_mean, OFF_sem, rgb_m, p3);
ylim([-15 10])
hold on
%% plot group 2
[h4, ~, ~] = plot_group_avg(EEC_mean, EEC_sem, rgb_m, p1,ax1);
ylim([-15 10])

[h5, ~, ~] = plot_group_avg(UEO_mean, UEO_sem, rgb_m, p2,ax2);
ylim([-15 10])

[h6, ~, ~] = plot_group_avg(OFF_mean, OFF_sem, rgb_m, p3,ax3);
ylim([-15 10])

%% plot group 3
[h7, ~, ~] = plot_group_avg(EEC_mean, EEC_sem, rgb_m, p1,ax1);
ylim([-15 10])

[h8, ~, ~] = plot_group_avg(UEO_mean, UEO_sem, rgb_m, p2,ax2);
ylim([-15 10])

[h9, ~, ~] = plot_group_avg(OFF_mean, OFF_sem, rgb_m, p3,ax3);
ylim([-15 10])

 %% Plot triggered averages of non-camera events
% for numPlots = 1:3
%     % Get timestamps
%     t = getTime(UEO_mean_WT,zdff.fs);
% 
%     if numPlots == 1
%         het_mean = UEO_mean;
%         het_sem  = UEO_sem;
%         WT_mean = UEO_mean_WT;
%         WT_sem  = UEO_sem_WT;
%         figname = 'UEO';
%     elseif numPlots == 2
%         het_mean = EEC_mean;
%         het_sem  = EEC_sem;
%         WT_mean = EEC_mean_WT;
%         WT_sem  = EEC_sem_WT;
%         figname = 'EEC';
%     elseif numPlots == 3
%         het_mean = OFF_mean;
%         het_sem  = OFF_sem;
%         WT_mean = OFF_mean_WT;
%         WT_sem  = OFF_sem_WT;
%         figname = 'OFF';
%     end
% 
%     %% Get SEMs differently for camera events due to dropouts 
% 
%     % exclude any mice that have NaNs
%     anyNans = any(isnan(all_IceOFF), 2);
%     nanRows = find(anyNans);
%     n_mice                  = numel(unique(info.mouse));
% 
% 
%     %% Plot Het
%     figure;
%     h1 = shadedErrorBar(t, het_mean, het_sem, 'lineprops', '-r','transparent',false,'patchSaturation',0.2);
% 
%     delete(h1.edge(1));
%     delete(h1.edge(2));
%     h1.mainLine.LineWidth = 3;
%     % h1.patch.FaceColor = [0.49,0.18,0.56];
%     % h1.patch.FaceAlpha = 0.1;
%     % h1.mainLine.Color = [0.49,0.18,0.56];
% 
% 
%     % Customize Plot
%     ax1 = gca;                       % Get current axis handle
%     ax1.XAxis.FontSize = 14;         % Set font size for the x-axis ticks
%     ax1.XAxis.FontWeight = 'bold';   % Set font weight to bold for the x-axis ticks
%     ax1.YAxis.FontSize = 14;         % Set font size for the y-axis ticks
%     ax1.YAxis.FontWeight = 'bold';   % Set font weight to bold for the y-axis ticks
%     ax1.XTick = [0,30,60];
%     ax1.XTickLabel = [-30,0,30];
%     ax1.YLim = [-2,12];
%     % ax1.YTick = [-1,0,1,2,3];
%     % ax1.YTickLabel = [-1,0,1,2,3];
% 
% 
%     set(gca, 'FontName', 'Arial');
%     set(gcf, 'Color', 'none');
%     axis off
% 
%     f1 = gcf;
% 
%     %% Saving
%     savefilepath = [root,project,'/Paper_Figures/averages/'];
%     % Save as fig and png
%     export_fig(f1, [savefilepath,figname,'_het.fig']);  % Save as .fig file
%     export_fig(f1, [savefilepath,figname,'_het.png'],'-png','-transparent','-r600');  % Save as .png file
%     %
%     export_fig(f2, [savefilepath,figname,'_WT.fig']);  % Save as .fig file
%     export_fig(f2, [savefilepath,figname,'_WT.png'],'-png','-transparent','-r600');  % Save as .png file
% 
%     delete(f1)
%     delete(f2)
%     close all
% end
