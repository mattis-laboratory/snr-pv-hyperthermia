%% Load Params and Detected Transients

clear; close all

params     = nostim_analysis_params();

load(params.detTransientsFname,'transients')
load(params.preprocFile,'events','zdff','info')

%% Plot Detected Transients

% set common yaxis limits for all sessions
ylimits = [floor(min(cellfun(@min, zdff.signal_hpf))) ...
    ceil(max(cellfun(@max, zdff.signal_hpf)))];

for n = 1:size(transients,1)
    % Extract signals and timestamps
    signal = zdff.signal_hpf{n,:};
    t      = zdff.t{n};
    locs   = transients{n,2};
    pks    = transients{n,1};
    EEC    = events.zdff.EEC{n,1};
    OFF    = events.zdff.OFF{n,1};

    % Setup figure and plot whole calcium trace
    fg = figure('Position',[186 414 1254 283],'Visible','off');
    plot(t, signal)
    hold on
    ax1 = gca;

    % add lines for BL, EEC, UEO, OFF
    toiOut = cellfun(@(f) events.zdff.(f){n}, fieldnames(events.zdff), ...
        'UniformOutput', false);
    toi    = cell2struct(toiOut, fieldnames(events.zdff), 1);
    addEventLines(ax1, t, toi, params.evtStyle);

    % Axes
    axis tight
    ylim(ylimits)
    ylabel('z-\DeltaF/F')
    xlabel('Time (s)', 'FontSize',14,'FontWeight','bold')
    ax1.XAxis.FontSize = 14;         % Set font size for the x-axis ticks
    ax1.XAxis.FontWeight = 'bold';   % Set font weight to bold for the x-axis ticks
    ax1.YAxis.FontSize = 14;         % Set font size for the y-axis ticks
    ax1.YAxis.FontWeight = 'bold';   % Set font weight to bold for the y-axis ticks
    
    xlim([t(EEC)-180, t(OFF)+180])
    grid on
    % Mark the detected peaks on the full trace with a red dot
    plot(t(locs), pks, 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
    box off
    hold off

    % Save the figure as a .png file
    figname = join([params.transientsPlots,info.fullID(n),'_sz_zoom.png'],"");
    saveas(fg,figname);
    delete(fg)

    clearvars -except params n zdff info events transients ylimits

end

