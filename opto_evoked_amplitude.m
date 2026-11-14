

%% Filter Subs and Load
% data = subs_info(subs_info.Stim==true ...
%     & subs_info.Genotype=='H'...
%     & subs_info.Seizure==true...
%     & subs_info.Heat_Speed=='F',:);

load([root,project,'/het_HT.mat'])
fileOut = [root,project,'/Figures/Evoked_Amplitudes/Hyperthermia/het/'];
mouseIDs = extractBefore(filt_data.Mouse_Session,'_');
sesIDs   = extractAfter(filt_data.Mouse_Session,'_');

%% Get evoked response amplitudes
for sub = 1:length(het_zdffs)

    BL_duration = het_marks_ds{sub,:}(1);
    EEC = het_marks_ds{sub,:}(2);
    UEO = het_marks_ds{sub,:}(3);
    OFF = het_marks_ds{sub,:}(4);

    if length(het_marks_ds{sub,:})>4
        UEO2 = het_marks_ds{sub,:}(5);
        OFF2 = het_marks_ds{sub,:}(6);
    end

    stimON = het_stimTimes{sub,:};
    offset = het_syncInfo{sub,1}.offset;
    stimON_shift = floor(stimON - offset*100);

    thisZdff = het_zdffs{sub,:};
    %calculate amplitude within 100 ms of opto time start
    for n = 1:length(stimON_shift)
        zON = thisZdff(stimON_shift(n));
        zMax = max(thisZdff(stimON_shift(n):stimON_shift(n)+10));
        opto_peaks(n,:) = abs(zMax - zON);
        clear zMax zON
    end


    %% Find indices of time periods

    fs_photo = 100;
    pre_heat = BL_duration:BL_duration+(5*fs_photo*60);
    heat_idx = pre_heat(end):EEC ;
    heat_dur = length(heat_idx)/2; %half-duration
    early_heat = pre_heat(end):pre_heat(end)+heat_dur;
    late_heat  = early_heat(end):EEC ;

    %post-ictal just use remaining stims available (unless multiple seizures)

    %find time of max temp
    %4616 > 1461136 index in t_common
    % t_tempMax = t_common(1461136);
    % [~, tds_tmax] = min(abs(tp - t_tempMax));

    %% Separate evoked responses into time periods
    pre_heat_stim_idx = find(stimON_shift<=pre_heat(end));
    early_heat_stim_idx = find(stimON_shift>pre_heat(end) & stimON_shift<early_heat(end));
    late_heat_stim_idx = find(stimON_shift>early_heat(end) & stimON_shift<late_heat(end));
    EEC_stim_idx = find(stimON_shift>=EEC  & stimON_shift<UEO );
    UEO_stim_idx = find(stimON_shift>=UEO  & stimON_shift<OFF );
    post_ictal_stim_idx = find(stimON_shift>OFF );

    pre_heat_pks   = opto_peaks(pre_heat_stim_idx);
    early_heat_pks = opto_peaks(early_heat_stim_idx);
    late_heat_pks  = opto_peaks(late_heat_stim_idx);
    EEC_pks        = opto_peaks(EEC_stim_idx);
    UEO_pks        = opto_peaks(UEO_stim_idx);
    post_ictal_pks = opto_peaks(post_ictal_stim_idx);


    if length(het_marks_ds{sub,:})>4
        post_ictal_stim_idx = find(stimON_shift>OFF & stimON_shift<UEO2 );
        UEO2_stim_idx = find(stimON_shift>=UEO2  & stimON_shift<OFF2 );
        post_ictal_stim_idx2 = (stimON_shift>=OFF2 );

        post_ictal_pks  = opto_peaks(post_ictal_stim_idx);
        UEO2_pks        = opto_peaks(UEO2_stim_idx);
        post_ictal_pks2 = opto_peaks(post_ictal_stim_idx2);
    end

    %% Average every X responses (within a time period)
    bin_size = 5;
    pre_heat_bin = arrayfun(@(k) mean(pre_heat_pks((k-1)*bin_size+1 : min(k*bin_size, numel(pre_heat_pks)))), ...
        1:ceil(numel(pre_heat_pks)/bin_size));

    early_heat_bin = arrayfun(@(k) mean(early_heat_pks((k-1)*bin_size+1 : min(k*bin_size, numel(early_heat_pks)))), ...
        1:ceil(numel(early_heat_pks)/bin_size));

    late_heat_bin = arrayfun(@(k) mean(late_heat_pks((k-1)*bin_size+1 : min(k*bin_size, numel(late_heat_pks)))), ...
        1:ceil(numel(late_heat_pks)/bin_size));

    EEC_bin = arrayfun(@(k) mean(EEC_pks((k-1)*bin_size+1 : min(k*bin_size, numel(EEC_pks)))), ...
        1:ceil(numel(EEC_pks)/bin_size));

    UEO_bin = arrayfun(@(k) mean(UEO_pks((k-1)*bin_size+1 : min(k*bin_size, numel(UEO_pks)))), ...
        1:ceil(numel(UEO_pks)/bin_size));

    post_ictal_bin = arrayfun(@(k) mean(post_ictal_pks((k-1)*bin_size+1 : min(k*bin_size, numel(post_ictal_pks)))), ...
        1:ceil(numel(post_ictal_pks)/bin_size));


    if length(het_marks_ds{sub,:})>4
        UEO2_bin = arrayfun(@(k) mean( UEO2_pks((k-1)*bin_size+1 : min(k*bin_size, numel( UEO2_pks)))), ...
            1:ceil(numel( UEO2_pks)/bin_size));

        post_ictal_bin2 = arrayfun(@(k) mean(post_ictal_pks2((k-1)*bin_size+1 : min(k*bin_size, numel(post_ictal_pks2)))), ...
            1:ceil(numel(post_ictal_pks2)/bin_size));
    end

    %% Normalize bins to pre-heat average

    pre_heat_mean  = mean(pre_heat_bin);

    pre_heat_bin   = pre_heat_bin./ pre_heat_mean;
    early_heat_bin = early_heat_bin./ pre_heat_mean;
    late_heat_bin  = late_heat_bin./ pre_heat_mean;
    EEC_bin        = EEC_bin./ pre_heat_mean;
    UEO_bin        = UEO_bin./ pre_heat_mean;
    post_ictal_bin = post_ictal_bin./ pre_heat_mean;

    if length(het_marks_ds{sub,:})>4
        UEO2_bin        = UEO2_bin./ pre_heat_mean;
        post_ictal_bin2 = post_ictal_bin2./ pre_heat_mean;
    end

    % Store mean of normalized binned amplitudes

    mean_pre_heat    = mean(pre_heat_bin);
    mean_early_heat  = mean(early_heat_bin);
    mean_late_heat   = mean(late_heat_bin);
    mean_EEC         = mean(EEC_bin);
    mean_UEO         = mean(UEO_bin);

    % take first 5 min of post-ictal period (if possible), otherwise till end

    numMinPostIctal = 5;

    if length(post_ictal_bin)>= 60*numMinPostIctal
        mean_post_ictal  = mean(post_ictal_bin(1:60*numMinPostIctal));
    else
        mean_post_ictal  = mean(post_ictal_bin);
    end

    all_means = [mean_pre_heat, mean_early_heat, mean_late_heat, mean_EEC, mean_UEO, mean_post_ictal];
    ssOut = [fileOut, 'het_evoked_amplitude_means.xlsx'];
    %writematrix(all_means, ssOut , 'WriteMode', 'append');


    %%  Plot binned peaks

    pre_heat_x           = 1:length(pre_heat_bin);
    early_heat_x         = pre_heat_x(end)+1:pre_heat_x(end)+length(early_heat_bin);
    late_heat_x          = early_heat_x(end)+1:early_heat_x(end)+length(late_heat_bin);
    EEC_x                = late_heat_x(end)+1:late_heat_x(end)+length(EEC_bin);
    UEO_x                = EEC_x(end)+1:EEC_x(end)+length(UEO_bin);
    post_ictal_x         = UEO_x(end)+1:UEO_x(end)+length(post_ictal_bin);

    figure('Position',[153 123 1067 348]);
    hold on;
    scatter(pre_heat_x, pre_heat_bin, 60, 'b','filled');
    scatter(early_heat_x, early_heat_bin, 60, "magenta",'filled');
    scatter(late_heat_x, late_heat_bin, 60, 'r','filled');
    scatter(EEC_x, EEC_bin, 60, 'yellow','filled');
    scatter(UEO_x, UEO_bin, 60, 'green','filled');
    scatter(post_ictal_x, post_ictal_bin, 60, 'k','filled');

    if length(het_marks_ds{sub,:})>4
        UEO2_x                = post_ictal_x(end)+1:post_ictal_x(end)+length(UEO2_bin);
        post_ictal_x2         = UEO2_x(end)+1:UEO2_x(end)+length(post_ictal_bin2);
        scatter(UEO2_x, UEO2_bin, 60, 'green','filled');
        scatter(post_ictal_x2, post_ictal_bin2, 60, 'k','filled');
    end

    legend({'Pre-heat'; 'Early Heat'; 'Late Heat'; 'Pre-ictal';'Ictal';'Post-ictal'})

    ylim([0 1.5])
    ylabel('Evoked Response Amplitude (z-DF/F)')
    xlabel('Averaged Stim Number')
    hold off

    figFolder = 'binned_5_normalized';

    % savefig(join([fileOut,figFolder,'/',mouseIDs(sub),'_',sesIDs(sub),'_binned_normalized.fig'],""))
    % exportgraphics(gcf,join([fileOut,figFolder,'/',mouseIDs(sub),'_',sesIDs(sub),'_binned_normalized.png'],""))

    %% Plot all evoked response ampltiudes
    figure('Position',[153 123 1067 348]);
    scatter(1:length(stimON),opto_peaks,"*")
    [~, EEC_line] = min(abs(stimON_shift - EEC ));
    [~, UEO_line] = min(abs(stimON_shift - UEO ));
    [~, OFF_line] = min(abs(stimON_shift - OFF ));
    %[~, temp_line] = min(abs(stimON_shift - tds_tmax));

    xlabel('Stim Number')
    ylabel('Evoked Response Peak')

    xline([EEC_line EEC_line], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
    xline([UEO_line UEO_line], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);
    xline([OFF_line OFF_line], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);

    figFolder = 'all_amps';

    % savefig(join([fileOut,figFolder,'/',mouseIDs(sub),'_',sesIDs(sub),'_all_amplitudes.fig'],""))
    % exportgraphics(gcf,join([fileOut,figFolder,'/',mouseIDs(sub),'_',sesIDs(sub),'_all_amplitudes.png'],""))
    
    %last_response_avg_amps(sub,:) = post_ictal_bin(end);
    clearvars -except root project sub WT* het* data mouseIDs sesIDs fileOut last*
end

%% Opto stims overlaid with z-DF/F

stimTimes = t_opto_binned;
stimTimes = opto_times;
stimON = het_stimTimes{sub,:};
offset = het_syncInfo{sub,1}.offset;
stimON_shift = floor(stimON - offset*100);

tp = (0:length(thisZdff)-1)/100;
stimTimes = tp(stimON_shift);

%%
figure;

n = 1 ; 

stimON = events.stimTimes{n,:};
offset = het_syncInfo{n,1}.offset;
stimON_shift = floor(stimON - offset*100);


plot(zdff.t{n},zdff.signal{n})
hold on

yL = ylim;
x = [stimTimes; stimTimes; nan(size(stimTimes))];
all_bins = [repmat(yL(1), 1, numel(stimTimes));
    repmat(yL(2), 1, numel(stimTimes));
    nan(1, numel(stimTimes))];
plot(x(:), all_bins(:), 'k-', 'LineWidth', 0.5)

%%
xline([tp(EEC ) tp(EEC )], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
xline([tp(UEO ) tp(UEO )], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);
xline([tp(OFF ) tp(OFF )], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
%xline([tp(tds_tmax) tp(tds_tmax)], 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2);

%savefig( [fileOut,num2str(sub),'_zdff_optoTimes_overlay.fig'])


pre_heat = BL_duration:BL_duration+(5*fs_photo*60);
heat_idx = pre_heat(end):EEC ;
heat_dur = length(heat_idx)/2; %half-duration
early_heat = pre_heat(end):pre_heat(end)+heat_dur;
late_heat  = early_heat(end):EEC ;

% case 'r', rgb = [1 0 0];
% case 'g', rgb = [0 1 0];
% case 'b', rgb = [0 0 1];
% case 'k', rgb = [0 0 0];
% case 'y', rgb = [1 1 0];
% case 'c', rgb = [0 1 1];
% case 'm', rgb = [1 0 1];
%

figure;
hold on
for i = 1:numel(d)-1
    plot(t(i:i+1), d(i:i+1), ...
        'Color', colorVec{i}, 'LineWidth', 2);
end
% 
% N = length(d);  
% 
% segments = {
%     1:pre_heat(1)-1,
%     pre_heat,
%     early_heat,
%     late_heat,
%     EEC:UEO,
%     UEO:OFF,
%     OFF:N
%     };
% 
% segmentColors = {'c', 'b', 'm','r','y','g','k'};   % one color per segment
% 
% colorVec = repmat({'k'}, N, 1);   
% 
% for s = 1:numel(segments)
%     idx = segments{s};
%     colorVec(idx) = segmentColors(s);
% end





%% Scratch
% %
% % %% Update markings (if needed) with timestamps of consecutive seizures
% %
% % if exist('cursor_info',"var")
% %     updated_marks = sort([cursor_info.DataIndex]);
% %     UEO2 = updated_marks(1);
% %     OFF2 = updated_marks(2);
% %     markings = [markings,updated_marks];
% % end
% %
% % tUEO2 = t_common(UEO2);
% % tOFF2 = t_common(OFF2);
% %
% % [~, UEO_down] = min(abs(tp - tUEO2));
% % [~, OFF_down] = min(abs(tp - tOFF2));
% %
% % markings_ds = [markings_ds,UEO_down,OFF_down];
% %
% % %% Save new markings
% %
% % save(loadpath,'markings','markings_ds','-append');
% %% Scratch
%xline([temp_line temp_line], 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2);
% savefig( [fileOut,num2str(sub),'_all_amplitudes.fig'])

%
%
