%% Post-ictal Recovery
% Moving average of mean fluorescence after final
% seizure (OFF) or equivalent time to end of recording

clear; close all

params     = nostim_analysis_params();
load(params.preprocFile,'events','zdff','info','rgb_m')

%% Get Binned Average

Fs         = zdff.fs;
binWin     = Fs*60*2; % 2-min. bin
figure; 
for n = 1:length(zdff.signal)

    thisZdff   = zdff.signal{n};

    %if  isempty(events.zdff.OFF{n,2})
        OFF = events.zdff.OFF{n,1};
    %else
    %    OFF = events.zdff.OFF{n,2};
    %end

    startSteps = OFF:binWin:length(thisZdff);

    % Loop through windows
    for i = 1:length(startSteps)
        tStart = startSteps(i);
        tEnd   = min(tStart + binWin, length(thisZdff));
        % Compute mean
        postictal_means(i)    = mean(thisZdff(tStart:tEnd), 'omitnan');
        clear tStart tEnd
    end

    all_means{n,:} = postictal_means;
   
    binNum = 1:length(postictal_means);
    scatter(binNum,postictal_means,50, rgb_m, 'filled', 'o'); hold on; 
    plot(binNum, postictal_means, '-', 'Color', rgb_m, 'LineWidth', 1.5);

    clear postictal_means thisZdff OFF startSteps binNum
end













