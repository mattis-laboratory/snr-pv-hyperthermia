%% Transient Properties Binned By Temperature
clear; close all
params = nostim_analysis_params();
load(params.preprocFile, 'info', 'rgb_m', 'rgb_s','color')
load([params.tempTransientsFname,'_props.mat' ],'props')

%% Exclude WT with non-monotonic heating curve from analysis (3330 on 10-22)
if strcmp(params.group,'WT_nsz') && strcmp(params.condition,'nostim')
    info                = info(2:end,:);
    props.rising.rate   = props.rising.rate(2:end,:);
    props.rising.amp    = props.rising.amp(2:end,:);
    props.falling.rate  = props.falling.rate(2:end,:);
    props.falling.amp   = props.falling.amp(2:end,:);
end

%% Parameters
edges      = -9:1:0;           % Shared for rising and falling
nBins      = length(edges) - 1;
binCenters = (edges(1:end-1) + edges(2:end)) / 2;
n_mice     = numel(unique(info.mouse));
n_sess     = height(info);

%% Run for amplitude and frequency
rising_mat  = props.rising.amp;
falling_mat = props.falling.amp; 


%% Combine rising + falling (falling flipped to follow temporal order)
falling_mat_flipped = fliplr(falling_mat);
data_all   = [rising_mat, falling_mat_flipped];
x_all      = [binCenters, fliplr(binCenters)];
is_heating = [true(1,nBins), false(1,nBins)];

%% Compute group mean and SEM
mean_all        = mean(data_all, 1, 'omitnan');
n_valid_per_bin = sum(~isnan(data_all), 1);
sem_all         = NaN(1, size(data_all,2));
complete_bins   = n_valid_per_bin == n_sess;
sem_all(complete_bins) = std(data_all(:,complete_bins), 0, 1) ./ sqrt(n_mice);
y_upper = mean_all + sem_all;
y_lower = mean_all - sem_all;

%% Group plot: individual session lines
% figure; hold on;
% for n = 1:n_sess
%     x_line = [binCenters, fliplr(binCenters)];
%     y_line = [rising_mat(n,:), fliplr(falling_mat(n,:))];
%     plot(x_line, y_line, '-', 'Color', rgb_m, 'LineWidth', 1.5);
%     scatter(binCenters, rising_mat(n,:),  60, ...
%         'MarkerFaceColor', rgb_m, 'MarkerEdgeColor', rgb_m, ...
%         'DisplayName', sprintf('%s heating', info.fullID{n}));
%     scatter(binCenters, falling_mat(n,:), 60, ...
%         'MarkerFaceColor', 'none', 'MarkerEdgeColor', rgb_m, ...
%         'LineWidth', 1.5, 'DisplayName', sprintf('%s cooling', info.fullID{n}));
% end
% xlabel('Temperature (°C rel. to max)'); ylabel('Mean z-DF/F');
% ylim([-20 15]); grid on;
%
% saveas(gcf, [params.meanTempFname,'all_individual_overlay.png']);
% close(gcf);

%% Group plot: mean ± SEM

figure; hold on;

% SEM shading over contiguous complete bins
valid_idx    = find(~isnan(sem_all));
split_points = [0, find(diff(valid_idx) > 1), length(valid_idx)];
for k = 1:length(split_points)-1
    seg = valid_idx(split_points(k)+1 : split_points(k+1));
    fill([x_all(seg), fliplr(x_all(seg))], ...
        [y_upper(seg), fliplr(y_lower(seg))], ...
        rgb_m, 'EdgeColor','none', 'FaceAlpha',0.15);
end

% Mean line and markers
plot(x_all, mean_all,'Color', rgb_m, 'LineWidth', 2);
scatter(x_all(is_heating),  mean_all(is_heating),  60, rgb_m, 'filled');
scatter(x_all(~is_heating), mean_all(~is_heating), 60, ...
    'MarkerEdgeColor', rgb_m, 'MarkerFaceColor', 'none', 'LineWidth', 1.5);

xlabel('Temperature (°C relative to max)'); ylabel('Mean z-DF/F');
%title('Group Mean Photometry Signal vs Temperature');
%legend({'SEM','Mean','Heating','Cooling'}, 'Location','best');
ylim([0 1]); grid on;

% saveas(gcf, [params.meanTempFname,'mean_sem.png']);
% close(gcf);


