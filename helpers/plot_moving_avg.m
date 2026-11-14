function [h, ax, f] = plot_moving_avg(data_mean, data_sem, color, ylabel_str, ax)
% If no axis handle provided, create a new figure
if nargin < 5 || isempty(ax)
    f = figure;
    ax = axes(f);
else
    f = gcf;
    axes(ax); % Set as current axis
end

bins = 1:length(data_mean);

hold on;
h = shadedErrorBar(bins, fliplr(data_mean), fliplr(data_sem), 'lineprops', {'color', color}, 'transparent', false, 'patchSaturation', 0.1);

delete(h.edge(1));
delete(h.edge(2));

ylabel(ylabel_str);


%% --- Choose 4 evenly spaced tick positions: first, last, and 2 in between ---
tick_positions = round(linspace(1, bins(end), 4));

% --- Compute the time interval label for each tick ---
% Bin n starts at -(n-1)*10 seconds and spans a 60-second window
bin_start = @(n) -(n-1)*10;
bin_end   = @(n) bin_start(n) - 60;

tick_labels = cell(1, length(tick_positions));
for i = 1:length(tick_positions)
    n = tick_positions(i);
    tick_labels{i} = sprintf('[%d, %d]', bin_start(n), bin_end(n));
end

% xticks(tick_positions);
% xticklabels(fliplr(tick_labels));

%% Other Axes Parameters
ax.XAxis.FontSize = 14;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 14;
ax.YAxis.FontWeight = 'bold';
h.mainLine.LineWidth = 2;

% xticks(bins) % can only run for group with longest data
% xticklabels({}) % don't print labels (adjust later in illustrator)

end

