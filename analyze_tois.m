
%% Load Parameters and Data
clear; close all

params     = nostim_analysis_params();
load(params.detTransientsFname,'transients')
load(params.preprocFile,'events','zdff','info')

%% Analyze TOIs
for n = 1:size(transients,1)
    %% Define Time Period Variables From 'events'
    % Baseline Interval (0 > HEAT START)
    BL         = 1: events.zdff.BL{n};
    BL_dur     = BL(end);

    % HEATING Interval (END OF BASELINE > UEO) first seizure only
    % DIVIDED INTO HALVES (Early vs. Late Heating)
    HEAT_total = [BL(end)+1, events.zdff.UEO{n}(1)];
    HEAT_dur   = HEAT_total(end) - HEAT_total(1);
    HEAT1      = [HEAT_total(1), HEAT_total(1) + floor(HEAT_dur/2)];
    HEAT1_dur  = HEAT1(end) - HEAT1(1);
    HEAT2      = [HEAT1(end)+1, HEAT_total(end)];
    HEAT2_dur  = HEAT2(end) - HEAT2(1);

    % Seizure Interval (UEO > OFF) first seizure only
    SZ         = [events.zdff.UEO{n}(1)+1,events.zdff.OFF{n}(1)];
    SZ_dur     = SZ(end) - SZ(1);

    %% Quantify Means
    % Get zdff signal
    thisZdff   = zdff.signal{n};

    %Baseline mean
    BL_mean    = nanmean(thisZdff(1:BL(end)));

    %Heating
    HEAT1_mean = nanmean(thisZdff(HEAT1(1):HEAT1(end)));
    HEAT2_mean = nanmean(thisZdff(HEAT2(1):HEAT2(end)));
    
    %**Pre-seizure mean (5s before EEC) - special for Figure 3
    pre_time    = zdff.fs*5; 
    EEC         = events.zdff.EEC{n};
    PRE_SZ_mean = nanmean(thisZdff(EEC-pre_time:EEC));
        
    %Seizure
    SZ_mean    = nanmean(thisZdff(SZ(1):SZ(end)));

    all_mean(n,:)  = [BL_mean, HEAT1_mean, HEAT2_mean, PRE_SZ_mean, SZ_mean];

    %% Total Number of Detected Transients
    % Get indices of all detected transients
    locs = transients{n,2};

    % Baseline
    BL_pks           = find(locs<=BL(end));
    BL_total         = length(BL_pks);

    % HEATING
    HEAT1_pks        = find(locs>HEAT1(1) & locs < HEAT1(end));
    HEAT2_pks        = find(locs>HEAT2(1) & locs < HEAT2(end));
    HEAT1_total      = length(HEAT1_pks);
    HEAT2_total      = length(HEAT2_pks);

    % Seizure
    SZ_pks           = find(locs>SZ(1) & locs<SZ(end));
    SZ_total         = length(SZ_pks);

    all_total(n,:)  = [BL_total, HEAT1_total, HEAT2_total, SZ_total];

    %% Frequency
    % Frequncy = Total number of transients in TOI/ duration of TOI
    Fs = zdff.fs;

    % Baseline
    BL_rate             = length(BL_pks)/(BL_dur/Fs);
    % HEATING
    HEAT1_rate          = length(HEAT1_pks)/(HEAT1_dur/Fs);
    HEAT2_rate          = length(HEAT2_pks)/(HEAT2_dur/Fs);
    % Seizure
    SZ_rate             = length(SZ_pks)/(SZ_dur/Fs);

    all_freq(n,:)       = [BL_rate, HEAT1_rate, HEAT2_rate, SZ_rate];

    %% P2T Amplitude
    P2Tamp = transients{n,4};
    
    % Baseline
    BL_P2Tamp           = nanmean(P2Tamp(BL_pks));
    % Heating
    HEAT1_P2Tamp        = nanmean(P2Tamp(HEAT1_pks));
    HEAT2_P2Tamp        = nanmean(P2Tamp(HEAT2_pks));
    % Seizure
    SZ_P2Tamp           = nanmean(P2Tamp(SZ_pks));

    all_P2Tamp(n,:)     = [BL_P2Tamp, HEAT1_P2Tamp, HEAT2_P2Tamp, SZ_P2Tamp];

    %% P2T Amplitude (DF/F)
    P2Tamp_dff = transients{n,7};
    
    % Baseline
    BL_P2Tamp_dff       = nanmean(P2Tamp_dff(BL_pks));
    % Heating
    HEAT1_P2Tamp_dff    = nanmean(P2Tamp_dff(HEAT1_pks));
    HEAT2_P2Tamp_dff    = nanmean(P2Tamp_dff(HEAT2_pks));
    % Seizure
    SZ_P2Tamp_dff       = nanmean(P2Tamp_dff(SZ_pks));

    all_P2Tamp_dff(n,:) = [BL_P2Tamp_dff, HEAT1_P2Tamp_dff, HEAT2_P2Tamp_dff, SZ_P2Tamp_dff];

    %% Peak Width
    width = transients{n,3};
    
    %Baseline
    BL_width            = nanmean(width(BL_pks)/Fs);
    %Heating
    HEAT1_width         = nanmean(width(HEAT1_pks)/Fs);
    HEAT2_width         = nanmean(width(HEAT2_pks)/Fs);
    %Seizure
    SZ_width            = nanmean(width(SZ_pks)/Fs);

    all_width(n,:)      = [BL_width, HEAT1_width, HEAT2_width,SZ_width];

    %% ISI
    % Time between one transient and next 
    % Baseline
    BL_ISI              = nanmean(diff(locs(BL_pks)))/Fs;
    %Heating
    HEAT1_ISI           = nanmean(diff(locs(HEAT1_pks)))/Fs;
    HEAT2_ISI           = nanmean(diff(locs(HEAT2_pks)))/Fs;
    %Seizure
    SZ_ISI              = nanmean(diff(locs(SZ_pks)))/Fs;

    all_ISI(n,:) = [BL_ISI, HEAT1_ISI, HEAT2_ISI,SZ_ISI];

    clearvars -except n params transients events zdff all_* info
end

%% Save to Excel File
% Append header and convert to table
header_means = {'Baseline','Early Heating','Late Heating','Pre-seizure','Seizure'};
header = {'Baseline','Early Heating','Late Heating','Seizure'};

means       = array2table(all_mean,"VariableNames",header_means,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
totals      = array2table(all_total,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
freqs       = array2table(all_freq,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
P2Tamps     = array2table(all_P2Tamp,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
P2Tamp_dffs = array2table(all_P2Tamp_dff,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
widths      = array2table(all_width,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});
ISIs        = array2table(all_ISI,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});

writetable(means, params.toiTransientsFname, 'Sheet', 'Mean' , 'WriteRowNames',true);
writetable(totals, params.toiTransientsFname, 'Sheet', 'Total','WriteRowNames',true);
writetable(freqs, params.toiTransientsFname, 'Sheet', 'Frequency','WriteRowNames',true);
writetable(P2Tamps, params.toiTransientsFname, 'Sheet', 'P2T_amp','WriteRowNames',true);
writetable(P2Tamp_dffs, params.toiTransientsFname, 'Sheet', 'P2T_amp_dff','WriteRowNames',true);
writetable(widths, params.toiTransientsFname, 'Sheet', 'Width','WriteRowNames',true);
writetable(ISIs, params.toiTransientsFname, 'Sheet', 'ISI','WriteRowNames',true);


