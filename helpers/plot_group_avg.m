function [h, ax, f] = plot_group_avg(data_mean, data_sem, color, ylabel_str, ax)
% If no axis handle provided, create a new figure
if nargin < 5 || isempty(ax)
    f = figure;
    ax = axes(f);
else
    f = gcf;
    axes(ax); % Set as current axis
end

%t = 1:length(data_mean);
t = getTime(data_mean, 1000);


% downsample before plotting
ds_step = 100;
t = t(1: ds_step:end);
data_mean = data_mean(1: ds_step:end);
data_sem = data_sem(1: ds_step:end);


hold on;
h = shadedErrorBar(t, data_mean, data_sem, 'lineprops', {'color', color}, 'transparent', false);

delete(h.edge(1));
delete(h.edge(2));

ylabel(ylabel_str);

% Label the plot
xlabel('Time (s)');
ylabel('z-DF/F')

ax.XTick = [0,30,60];
xline([30 30],'LineStyle','--','LineWidth',2);

ax.XTickLabel = [-30,0,30];
% ax.XAxis.FontSize = 14;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis.FontSize = 14;
% ax.YAxis.FontWeight = 'bold';
h.mainLine.LineWidth = 2;

% ylim([-12 10])
% xlim([0 60])

end
