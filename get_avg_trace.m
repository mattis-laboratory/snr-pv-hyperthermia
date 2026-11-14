function [metric_mean, metric_sem] = get_avg_trace(metric, n_mice)

% Truncate all moving averages to shortest signal
minLen           = min(cellfun(@length,  metric(:,1)));
truncAvg         = cell2mat(cellfun(@(v) v(1:minLen),  ...
    metric(:,1), 'UniformOutput', false));
% Get mean and SEM
metric_mean      = nanmean(truncAvg, 1);
metric_sem       = nanstd(truncAvg, 1)/sqrt(n_mice);

%metric_mean      = flip(metric_mean);
%metric_sem       = flip(metric_sem);

end
