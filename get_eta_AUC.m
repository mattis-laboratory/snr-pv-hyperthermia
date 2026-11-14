%% Get Triggered Averages
% Chandni Rana - University of Michigan (09/2024)
clc; clear; close all;

params = PPN_PTZ_params();
load(params.preprocFile,'events','zdff','info')

%% Extract Centered Traces

Fs        = zdff.fs;
pre_time  = params.eventPreTime*zdff.fs;
post_time = params.eventPostTime*zdff.fs;

win = pre_time + post_time + 1;
eta = @(sig, tp)eta_slice(sig, tp, pre_time, post_time, win);

for n = 1:size(zdff.signal,1)
    sig     = zdff.signal{n};
    EEC     = events.zdff.EEC{n,1};
    UEO     = events.zdff.UEO{n,1};
    OFF     = events.zdff.OFF{n,1};
    % LampON  = events.cam.LampON(n,1);
    % LampOFF = events.cam.LampOFF(n,1);
    % IceON   = events.cam.IceON(n,1);
    % IceOFF  = events.cam.IceOFF(n,1);

    all_UEO(n,:)     = eta(sig, UEO);
    all_EEC(n,:)     = eta(sig, EEC);
    all_OFF(n,:)     = eta(sig, OFF);
    % all_LampON(n,:)  = eta(sig, LampON);
    % all_LampOFF(n,:) = eta(sig, LampOFF);
    % all_IceON(n,:)   = eta(sig, IceON);
    % all_IceOFF(n,:)  = eta(sig, IceOFF);

    % if strcmp(params.group,'het_sz')
    %     CamSz            = events.cam.Seizure(n,1);
    %     all_CamSz(n,:)   = eta(sig, CamSz);
    % else
    %     CamSz                    = EEC + ceil(params.camSzRelOnset*Fs);
    %     events.cam.Seizure(n,1)  = CamSz;
    %     all_CamSz(n,:)           = eta(sig,CamSz);
    % end
end


%% Get AUCs

AUC_EEC     = trapz(all_EEC,2)/Fs;
AUC_UEO     = trapz(all_UEO,2)/Fs;
AUC_OFF     = trapz(all_OFF,2)/Fs;

% AUC_LampON  = trapz(all_LampON,2)/Fs;
% AUC_CamSz   = trapz(all_CamSz,2)/Fs;
% AUC_LampOFF = trapz(all_LampOFF,2)/Fs;
% AUC_IceON   = trapz(all_IceON,2)/Fs;
% AUC_IceOFF  = trapz(all_IceOFF,2)/Fs;


all_AUC = [AUC_EEC, AUC_UEO, AUC_OFF];

header = {'EEC','UEO','OFF'};
AUC_table = array2table(all_AUC,"VariableNames",header,"RowNames",info.fullID,'DimensionNames',{'Mouse_Session','Variables'});


%% Save Extracted Traces and AUCs

filename = [params.trigAvgTraces,'.mat'];
save(filename,'all_*','params')
writetable(AUC_table, [params.trigAvgAUC,'.xlsx'], 'Sheet', params.group , 'WriteRowNames',true);

%% Helpers
function out = eta_slice(sig, tp, pre_time, post_time, win)
if isnan(tp)
    out = nan(1, win);
else
    pre_mean = mean(sig(tp-pre_time:tp));
    out = sig(tp-pre_time : tp+post_time) - pre_mean;
end
end

