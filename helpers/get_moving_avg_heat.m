%% Moving Average of Transients Properties
clear; close all

params     = nostim_analysis_params();
load(params.detTransientsFname,'transients')
load(params.preprocFile,'events','zdff','info')

%% Get individual moving averages (frequency + amplitude)
for n = 1:size(transients,1)

    %% Pre-Seizure/ Heating
    % Get individual subject moving average from t0 to tEEC
    % Then flip each subjects data before ensemble average to align
    % pre-seizure time points

    % Input variables
    EEC      = events.zdff.EEC{n,1};
    BL       = events.zdff.BL{n,1};
    locs     = transients{n,2};
    P2Tamp   = transients{n,4};
    Fs       = zdff.fs;
    stepSize = params.stepSize*Fs;
    binWin   = params.binWin*Fs;

    startSteps = EEC:-stepSize:BL+stepSize;

    % Preallocate
    meanPreAmps   = zeros(size(startSteps));
    nPrePeaks     = zeros(size(startSteps));

    % Loop through windows (in reverse order)
    for i = 1:length(startSteps)
        tStart = startSteps(i);
        tEnd   = max(tStart - binWin,BL);

        % Find peaks in this window
        pks = locs <= tStart & locs > tEnd;

        % Compute metrics
        meanPreAmps(i)    = mean(P2Tamp(pks), 'omitnan');
        nPrePeaks(i)      = sum(pks);

        clear pks tStart tEnd
    end

    moving_amp{n,1}   = meanPreAmps;
    moving_freq{n,1}  = nPrePeaks./(stepSize/Fs); % convert to Hz

    clearvars -except n params moving_* events zdff transients info
end

filename = [params.mavgTransientsFname,'_heat.mat'];
save(filename,'moving_amp','moving_freq')






