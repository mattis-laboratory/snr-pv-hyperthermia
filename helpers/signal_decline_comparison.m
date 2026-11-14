%% Seizure (EEC) vs. lamp-off signal decline comparison
clc; clear; close all

%% Load params + traces
params     = nostim_analysis_params();
load(params.trigAvgTraces,'all_LampOFF','all_EEC');
load(params.preprocFile, 'info')

%% Get binned mean signal at t1 & t2
% x = EEC or LampOFF
% t1: [x, x + 5s]
% t2: [x + 25s, x + 30s]

% --------- Alternative Windows (expand) ---------
% --------- A ---------
% y = EEC or LampOFF
% *mean seizure duration was calculated using UEO
% t1: [y, y + 5s]
% t2: [y + mean seizure dur*, y + mean seizure dur* - 5s]
% --------- B ---------
% y = EEC or LampOFF
% t1: [y, y + 5s]
% t2: [OFF, OFF - 5s]

Fs         = 1000;
binWin     = 5;
t1         = floor(size(all_EEC,2)/2);
x          = getTime(all_EEC(1,t1:end),Fs);

for subject = 1:size(all_EEC,1)

    EECm1                = mean(all_EEC(subject,t1: t1 + Fs*binWin));
    EECm2                = mean(all_EEC(subject,end-Fs*binWin:end));
    magEEC(subject,1)    = abs(EECm2 - EECm1);

    p1                   = polyfit(x', all_EEC(subject, t1:end), 1);
    slopeEEC(subject,1)  = p1(1);

    LampM1               = mean(all_LampOFF(subject,t1: t1 + Fs*binWin));
    LampM2               = mean(all_LampOFF(subject,end-Fs*binWin:end));
    magLamp(subject,1)   = abs(LampM2 - LampM1);

    p2                   = polyfit(x', all_LampOFF(subject, t1:end), 1);
    slopeLamp(subject,1) = p2(1);

    clear p1 p2 Lamp* EEC*
end

all_vars  = [magEEC, magLamp, slopeEEC, slopeLamp];
header    = {'EEC Magnitude', 'LampOFF Magnitude', 'EEC Slope', 'LampOFF Slope'};
table     = array2table(all_vars,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});

%% Save to excel
filename = [params.trigAvgOutput,'signal_drop_comparison.xlsx'];
writetable(table, filename, 'Sheet', params.group , 'WriteRowNames',true);





% ax = gca;
% xl = ax.XLim; yl = ax.YLim;
% yl = [-20 20];
% for h = findobj(ax, 'Type', 'line')'
%     out = h.XData < xl(1) | h.XData > xl(2) | h.YData < yl(1) | h.YData > yl(2);
%     h.XData(out) = NaN;
%     h.YData(out) = NaN;
% end