%xlim([415 460])

% ax2=nexttile;
% plot(tEEG,eeg/1000,'Color','r'); box off;
% xline([tEEG(EEC) tEEG(EEC)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
% xline([tEEG(UEO) tEEG(UEO)],  'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
% ylabel('EEG (mV)')
% ax2.FontSize = 14;
% ax2.FontWeight = "bold";
% %xlim([415 460])
%
% linkaxes([ax1 ,ax2 ],'x')
% f1 = gcf;
%%
saveas(f1, [savepath,figname,'.fig']);  % Save as .fig file
saveas(f1, [savepath,figname,'.png']);  % Save as .png file
saveas(f1, [savepath,figname,'.svg']);  % Save as .svg file

%% Het Baseline Transients

figname = 'het_baseline_transients';

for subject = 1:length(het_zdff_BL)
    zdff = het_zdff_BL{subject};
    tPhoto = getTime(zdff,Fs);
    BL = het_marks{subject}(1);
    figure
    plot(tPhoto,zdff,'Color',[1,0,0],'LineWidth',3); box off;
    xlim([0 tPhoto(BL)+10])
    ylim([-5 10])
    figname = [figname, num2str(subject)];

    saveas(gcf, [savepath,figname,'.fig']);  % Save as .fig file
    saveas(gcf, [savepath,figname,'.png']);  % Save as .png file
end
%% WT Baseline Transients
%load('/nfs/turbo/umms-mattislab/Chandni/Data/SNr_PV_Hyperthermia/3777/2025-02-05_baseline/isosbestic_subtraction/preproc_data.mat')
%
% thisDFF =   dff;
% base_length = length(thisDFF);
% base_mean = mean(thisDFF);
% base_std  = std(thisDFF);
% zdff_BL = (thisDFF-base_mean)./base_std;
for subject = 1:length(WT_zdff_BL)
    figname = 'WT_baseline_transients';

    zdff = WT_zdff_BL{subject};
    tPhoto = getTime(zdff,Fs);
    BL = WT_marks{subject}(1);
    figure
    plot(tPhoto,zdff,'Color',[0,0,1],'LineWidth',3); box off;
    xlim([0 tPhoto(BL)+10])
    ylim([-5 10])
    figname = [figname, num2str(subject)];
    saveas(gcf, [savepath,figname,'.fig']);  % Save as .fig file
    saveas(gcf, [savepath,figname,'.png']);  % Save as .png file
    clear figname
end


%%

saveas(gcf, [savepath,figname,'.svg']);  % Save as .svg file



%% Dual Y axis plot
for subject = 1:length(WT_seizure_zdffs)
    zdff = WT_seizure_zdff_BL{subject};
    eeg = WT_seizure_eegs{subject};

    % Truncate signal lengths to whichever is shortest
    if length(eeg)>length(zdff)
        eeg = eeg(1:length(zdff));
    else
        zdff = zdff(1:length(eeg));
    end

    tyy = getTime(zdff,Fs);

    %% Create dual y-axis plot
    figure('Position',[433 211 826 543])
    yyaxis left
    plot(tyy, eeg/1000, 'Color',[0.5,0.5,0.5]);
    ylabel('EEG (mV)','FontSize',24,'Color',[0.5,0.5,0.5],'FontWeight','bold');
    ylim([-10 10])
    yyaxis right
    plot(tyy, zdff, 'b','LineWidth',2);
    ylabel('z-DF/F','FontSize',24,'Color','b','FontWeight','bold');
    ylim([-15 15])
    xlabel('Time (s)','FontSize',24,'Color','k','FontWeight','bold');
    xlim([1250 1750])
    xticks([1250:100:1750])
    xticklabels([0:100:500])
    box off


    % xline([tyy(EEC) tyy(EEC)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
    % xline([tyy(EEC2) tyy(EEC2)],  'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
    %axis off
end
%%

set(gca, 'FontName', 'Arial');
set(gcf, 'Color', 'none');
f2 = gcf;

savefilepath = [root,project,'/Paper_Figures/'];
% Save as fig and png
export_fig(f1, [savefilepath,figname,'_3331.fig']);  % Save as .fig file
export_fig(f1, [savefilepath,figname,'_3331.png']);  % Save as .png file


ax = gca;                      % Get current axes
inset = ax.TightInset;         % Margins: [left, bottom, right, top]

% Set axes position to remove extra space (especially bottom margin)
ax.Position = [inset(1), inset(2), ...
    1 - inset(1) - inset(3), ...
    1 - inset(2) - inset(4)];


%% %HT and PTZ

%center traces around UEO
zdff_trim = zdff(UEO-15*Fs:UEO+30*Fs);
tHT_trim = getTime(zdff_trim,Fs);

zdff_PTZ_trim = zdff_PTZ(UEO_PTZ-15*Fs:UEO_PTZ+30*Fs);
tPTZ_trim = getTime(zdff_PTZ_trim,Fs);



% Create dual y-axis plot
figure;
yyaxis left
plot(tHT_trim, zdff_trim, 'Color','r');
ylabel('Hyperthermia');

yyaxis right
plot(tPTZ_trim,zdff_PTZ_trim, 'Color',[0.49,0.18,0.56]);
ylabel('PTZ');

xlabel('Time (s)');
% xline([tyy(EEC) tyy(EEC)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
% xline([tyy(EEC2) tyy(EEC2)],  'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
axis off



set(gca, 'FontName', 'Arial');
set(gcf, 'Color', 'none');
f2 = gcf;

savefilepath = [root,project,'/Paper_Figures/'];
% Save as fig and png
export_fig(f1, [savefilepath,figname,'.fig']);  % Save as .fig file
export_fig(f1, [savefilepath,figname,'.png']);  % Save as .png file

