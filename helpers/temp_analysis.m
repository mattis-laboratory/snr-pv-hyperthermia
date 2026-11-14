
%% Fluorescence Mean Binned By Temperature
clear; close all

params     = nostim_analysis_params();
load(params.preprocFile,'info','temp','zdff','rgb_m','color') 

%% Exclude WT with non-monotonic heating curve from analysis (3330 on 10-22)
if strcmp(params.group,'WT_nsz') & strcmp(params.condition,'nostim')
   info             = info(2:end,:);
   temp             = temp(2:end);
   zdff.signal      = zdff.signal(2:end);
   zdff.signal_hpf  = zdff.signal_hpf(2:end);
   zdff.t           = zdff.t(2:end);
end

%% Parameters
edges_rising  = -9:1:0;   % Temperature bins relative to max temp
edges_falling = -9:1:0;   % Same for falling phase
dt = 1 / zdff.fs;
n_mice = numel(unique(info.mouse));
n_sess = height(info);

nBinsR = length(edges_rising)-1;
nBinsF = length(edges_falling)-1;

binCenters_rising  = edges_rising(1:end-1);
binCenters_falling = edges_falling(1:end-1);

%% Bin and plot each subject individually
for n = 1:n_sess
    thisZdff = zdff.signal{n};
    thisTemp = temp{n};

    % Match lengths
    minLength = min(length(thisZdff), length(thisTemp));
    thisZdff  = thisZdff(1:minLength);
    thisTemp  = thisTemp(1:minLength);

    % Peak temp index (inflection point)
    [~, peakIdx] = max(thisTemp);

    % Split phases
    temp_rising    = thisTemp(1:peakIdx);
    signal_rising  = thisZdff(1:peakIdx);
    temp_falling   = thisTemp(peakIdx+1:end);
    signal_falling = thisZdff(peakIdx+1:end);

    % Relative to max temp
    Tmax = max(thisTemp);
    temp_rising_rel  = temp_rising - Tmax;
    temp_falling_rel = temp_falling - Tmax;

    % Bin signals
    idx_rising  = discretize(temp_rising_rel, edges_rising, 'IncludedEdge','right');
    idx_falling = discretize(temp_falling_rel, edges_falling, 'IncludedEdge','right');

    % Preallocate
    rising_mean  = NaN(length(edges_rising)-1, 1);
    falling_mean = NaN(length(edges_falling)-1, 1);

    % Compute means
    for bnum = 1:length(rising_mean)
        rising_mean(bnum) = mean(signal_rising(idx_rising == bnum), 'omitnan');
        falling_mean(bnum) = mean(signal_falling(idx_falling == bnum), 'omitnan');
    end

    % Store
    rising_means{n}  = rising_mean;
    falling_means{n} = falling_mean;

    %  plot
    h=figure;
    scatter(binCenters_rising, rising_mean, 50, color, 'filled', 'o'); hold on;
    scatter(binCenters_falling, falling_mean, 50, color, 'o');
    xlabel('Temperature (°C rel. to max)');
    ylabel('Mean z-DF/F');
    title(sprintf('%s: Mean Signal by Temperature', info.fullID{n}), 'Interpreter','none');
    ylim([-20 15]);
    grid on;
end

%% Group Plot: Each mouse gets a line + markers
figure;
hold on;
%colors = lines(n_sess);  % One unique color per subject

for n = 1:n_sess
    rising_mean  = rising_means{n};
    falling_mean = falling_means{n};

    % Make sure cooling bins are reversed to follow temporal order
    x_all = [binCenters_rising, fliplr(binCenters_falling)];
    y_all = [rising_mean',      fliplr(falling_mean')];

    % Plot line connecting points in time order
    plot(x_all, y_all, '-', 'Color', rgb_m, 'LineWidth', 1.5);

    % Plot heating (filled circles)
    scatter(binCenters_rising, rising_mean, 60, ...
        'MarkerFaceColor', rgb_m, ...
        'MarkerEdgeColor', rgb_m, ...
        'DisplayName', sprintf('%s heating', info.fullID{n}));

    % Plot cooling (open circles)
    scatter(binCenters_falling, falling_mean, 60, ...
        'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', rgb_m, ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('%s cooling', info.fullID{n}));
end

xlabel('Temperature (°C rel. to max)');
ylabel('Mean z-DF/F');
grid on;
ylim([-20 15]); 

%% Average and SEM

% Define number of bins based on one mouse (assumes all are the same)
n_rising_bins = length(rising_means{1});
n_falling_bins = length(falling_means{1});

% Preallocate matrices for all sessions (Sessions x Bins)
n_sess = length(rising_means);
rising_mat = NaN(n_sess, n_rising_bins);
falling_mat = NaN(n_sess, n_falling_bins);

% Populate matrices
for s = 1:n_sess
    rising_mat(s, :) = rising_means{s};
    falling_mat(s, :) = falling_means{s};
end

% Flip cooling data for temporal order
falling_mat_flipped = fliplr(falling_mat);

% Combine rising and flipped cooling
data_all = [rising_mat, falling_mat_flipped]; 

% Combine X-axis (no flipping of bin centers!)
x_all = [binCenters_rising, fliplr(binCenters_falling)];

% Remove columns (bins) where all values are NaN
valid_cols = ~any(isnan(data_all), 1);
%data_all = data_all(:, valid_cols);
%x_all = x_all(valid_cols);

% Compute mean and SEM
mean_all = mean(data_all, 1, 'omitnan');

% Find number of valid rising bins (needed to plot open/closed markers)
valid_rising = sum(~all(isnan(rising_mat),1));


%%%%%%
% Compute the mean (include bins with at least one value)
mean_all = mean(data_all, 1, 'omitnan');

% Compute number of valid (non-NaN) values in each bin
n_valid_per_bin = sum(~isnan(data_all), 1);

% Only calculate SEM where *all* mice have data; else SEM = NaN
sem_all = NaN(1, size(data_all,2));
complete_bins = n_valid_per_bin == n_sess;
sem_all(complete_bins) = std(data_all(:, complete_bins), 0, 1) ./ sqrt(n_mice);

% SEM shading bounds
y_upper = mean_all + sem_all;
y_lower = mean_all - sem_all;

%% Plot Mean and SEM
figure; hold on;

 % Get valid SEM indices
valid_idx = find(~isnan(sem_all));

% Identify contiguous groups of valid indices
split_points = [0, find(diff(valid_idx) > 1), length(valid_idx)];
for k = 1:length(split_points)-1
    i1 = split_points(k)+1;
    i2 = split_points(k+1);
    seg_idx = valid_idx(i1:i2);

    % Pull segment
    x_seg = x_all(seg_idx);
    y_seg_upper = y_upper(seg_idx);
    y_seg_lower = y_lower(seg_idx);

    % Plot this segment
    fill([x_seg, fliplr(x_seg)], ...
         [y_seg_upper, fliplr(y_seg_lower)], ...
         [0.7 0.7 1], ...
         'EdgeColor', 'none', ...
         'FaceAlpha', 0.4);
end


% Mean line
plot(x_all, mean_all, color, 'LineWidth', 2);

% Filled circles = heating
scatter(x_all(1:valid_rising), mean_all(1:valid_rising), ...
    60, color, 'filled');

% Open circles = cooling
scatter(x_all(valid_rising+1:end), mean_all(valid_rising+1:end), ...
    60, 'MarkerEdgeColor', color, 'MarkerFaceColor', 'none', 'LineWidth', 1.5);

xlabel('Temperature (°C relative to max)');
ylabel('Mean z-DF/F');

grid on;
ylim([-15 10]); % Adjust as needed


%% Means and SEM
% Find shortest length
minLen = min(cellfun(@length, rising_means));

% Truncate and convert to matrix (each row = one vector)
het_rising = cell2mat(cellfun(@(v) v(1:minLen), rising_means, 'UniformOutput', false));
het_rising = reshape(het_rising, [], minLen);


% Find shortest length
minLen = min(cellfun(@length, falling_means));

% Truncate and convert to matrix (each row = one vector)
het_falling = cell2mat(cellfun(@(v) v(1:minLen), falling_means, 'UniformOutput', false));
het_falling = reshape(het_falling, [], minLen);


rising_mean = nanmean(het_rising,1);
rising_sem = nanstd(het_rising, 1)/sqrt(n_mice);


falling_mean = nanmean(het_falling,1);
falling_sem = nanstd(het_falling, 1)/sqrt(n_mice);

%% Stack rising and falling into matrices
n_sess = length(rising_means);
n_rising_bins  = length(rising_means{1});
n_cooling_bins = length(falling_means{1});

rising_mat  = NaN(n_sess, n_rising_bins);
falling_mat = NaN(n_sess, n_cooling_bins);

for s = 1:n_sess
    rising_mat(s,:)  = rising_means{s};
    falling_mat(s,:) = falling_means{s};
end

% Flip cooling bins so they follow heating in temporal order
falling_mat_flipped = fliplr(falling_mat);

% Combine data and bin centers
data_all = [rising_mat, falling_mat_flipped];  % [mice x bins]
x_all    = [binCenters_rising, fliplr(binCenters_falling)];  % [1 x bins]

% Label which bins are heating vs cooling
is_heating = [true(1, n_rising_bins), false(1, n_cooling_bins)];

% Compute the mean across mice, ignoring NaNs
mean_all = mean(data_all, 1, 'omitnan');

% Compute number of valid (non-NaN) values in each bin
n_valid_per_bin = sum(~isnan(data_all), 1);

% SEM only for bins where all mice have data
sem_all = NaN(1, length(x_all));
complete_bins = n_valid_per_bin == n_sess;
sem_all(complete_bins) = std(data_all(:, complete_bins), 0, 1) ./ sqrt(n_hets);

% SEM bounds
y_upper = mean_all + sem_all;
y_lower = mean_all - sem_all;

%% Plotting
figure; hold on;

% --- SEM shading only over complete bins ---
valid_idx = find(~isnan(sem_all));

% Identify contiguous stretches of valid SEM bins
split_points = [0, find(diff(valid_idx) > 1), length(valid_idx)];
for k = 1:length(split_points)-1
    i1 = split_points(k)+1;
    i2 = split_points(k+1);
    seg_idx = valid_idx(i1:i2);

    x_seg = x_all(seg_idx);
    y_seg_upper = y_upper(seg_idx);
    y_seg_lower = y_lower(seg_idx);

    % Shaded area for this continuous segment
    fill([x_seg, fliplr(x_seg)], ...
         [y_seg_upper, fliplr(y_seg_lower)], ...
         [1 0.7 0.7], ...
         'EdgeColor', 'none', ...
         'FaceAlpha', 0.4);
end

% --- Plot mean line over all bins ---
plot(x_all, mean_all, 'r-', 'LineWidth', 2);

% --- Markers: filled = heating, open = cooling ---
scatter(x_all(is_heating), mean_all(is_heating), ...
        60, 'r', 'filled');  % Heating

scatter(x_all(~is_heating), mean_all(~is_heating), ...
        60, 'MarkerEdgeColor', 'r', ...
             'MarkerFaceColor', 'none', ...
             'LineWidth', 1.5);  % Cooling

% --- Labels & formatting ---
xlabel('Temperature (°C relative to max)');
ylabel('Mean z-DF/F');
title('Group Mean Photometry Signal vs Temperature');
legend({'SEM (All Mice)', 'Mean', 'Heating', 'Cooling'}, ...
       'Location', 'best');
grid on;
ylim([-15 10]);  % Adjust as needed







