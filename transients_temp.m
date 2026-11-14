%% Properties of Calcium Transients Binned By Temperature
clear; close all

params     = nostim_analysis_params();
load(params.detTransientsFname,'transients')
load(params.preprocFile,'fsEEG','info','temp') % loading in fsEEG instead of from zdff, due to large size of zdff

%% Exclude WT with non-monotonic heating curve from analysis (3330 on 10-22)
if strcmp(params.condition,'WT_nsz') & strcmp(params.group,'nostim')
   info       = info(2:end,:);
   transients = transients(2:end,:);
   temp       = temp(2:end);
end

%% Parameters
edges_rising  = -9:1:0;   % Temperature bins relative to max temp
edges_falling = -9:1:0;   % Same for falling phase
dt = 1 / fsEEG;
n_mice = numel(unique(info.mouse));
n_sess = height(info);

nBinsR = length(edges_rising)-1;
nBinsF = length(edges_falling)-1;

% Preallocate outputs
props.rising.rate  = zeros(n_sess,nBinsR);
props.rising.amp   = zeros(n_sess,nBinsR);

props.falling.rate  = zeros(n_sess,nBinsF);
props.falling.amp   = zeros(n_sess,nBinsF);

%% Get temp binned transients properties for each session
for n = 1:n_sess

    thisTemp = temp{n};
    nSamples = length(thisTemp);

    % --- Transient properties ---
    locs     = transients{n,2};
    amps     = transients{n,4};

    % Ensure peaks are within the temp vector
    valid = locs <= nSamples;
    locs  = locs(valid);
    amps     = amps(valid);

    % --- Max temperature index ---
    [~, peakTempIdx] = max(thisTemp);

    % --- Rising and falling time masks ---
    isRisingTime  = (1:nSamples) <= peakTempIdx;
    isFallingTime = (1:nSamples) >  peakTempIdx;

    % --- Relative temperature ---
    temp_rel = thisTemp - max(thisTemp);

    % --- Time bins: Rising ---
    idx_rising_time = discretize(temp_rel(isRisingTime), edges_rising);

    % Compute dwell time per bin
    time_rising = NaN(nBinsR,1);
    for b = 1:nBinsR
        time_rising(b) = sum(idx_rising_time == b) * dt;
    end

    % --- Time bins: Falling ---
    idx_falling_time = discretize(temp_rel(isFallingTime), edges_falling);
    time_falling = NaN(nBinsF,1);
    for b = 1:nBinsF
        time_falling(b) = sum(idx_falling_time == b) * dt;
    end

    % --- Assign peaks to rising/falling ---
    peakTempRel = temp_rel(locs);

    % Rising peaks
    rIdx = find(locs < peakTempIdx);
    peakBins_rising = discretize(peakTempRel(rIdx), edges_rising);

    % Falling peaks
    fIdx = find(locs >= peakTempIdx); % include peak at Tmax
    peakBins_falling = discretize(peakTempRel(fIdx), edges_falling);

    %% --- Compute per-bin metrics: Rising ---
    rateR  = NaN(nBinsR,1);
    ampR   = NaN(nBinsR,1);

    for b = 1:nBinsR
        inBin = (peakBins_rising == b);
        if any(inBin) && time_rising(b) > 0
            rateR(b)  = sum(inBin) / time_rising(b);
            ampR(b)   = mean(amps(rIdx(inBin)),   'omitnan');
        end
    end

    %% --- Compute per-bin metrics: Falling ---
    rateF  = NaN(nBinsF,1);
    ampF   = NaN(nBinsF,1);

    for b = 1:nBinsF
        inBin = (peakBins_falling == b);
        if any(inBin) && time_falling(b) > 0
            rateF(b)  = sum(inBin) / time_falling(b);
            ampF(b)   = mean(amps(fIdx(inBin)),   'omitnan');
        end
    end

    %% --- Store results ---
    props.rising.rate(n,:)  = rateR';
    props.rising.amp(n,:)   = ampR';

    props.falling.rate(n,:) = fliplr(rateF');
    props.falling.amp(n,:)  = fliplr(ampF');

end

%% Save Props 
save([params.tempTransientsFname,'_props.mat'],'props','params')

%% Write to Excel
% writematrix(props.rising.rate,[params.group,'_temp_binned_transients.xlsx'],'Sheet','freq_rising')
% writematrix(props.rising.amp,[params.group,'_temp_binned_transients.xlsx'],'Sheet','amp_rising')
% writematrix(props.falling.rate,[params.group,'_temp_binned_transients.xlsx'],'Sheet','freq_falling')
% writematrix(props.falling.amp,[params.group,'_temp_binned_transients.xlsx'],'Sheet','amp_falling')
% writematrix(info.fullID,[params.group,'_temp_binned_transients.xlsx'],'Sheet','IDs')

fname = [params.group,'_temp_binned_transients.xlsx'];

sheets     = {'freq_rising','amp_rising','freq_falling','amp_falling'};
dataFields = {props.rising.rate, props.rising.amp, props.falling.rate, props.falling.amp};

for s = 1:numel(sheets)
    data = [cellstr(info.fullID), num2cell(dataFields{s})];
    writecell(data, fname, 'Sheet', sheets{s});
end
