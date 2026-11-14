% Chandni Rana - University of Michigan - Mattis Lab
clear; close all

cfg = setup_preproc_config();

%%  Import Data (select session to run)
[PPD]                                  = load_ppd(cfg.datapath);
[OEP, TEMP, events, recording]         = load_oep(cfg.datapath,cfg.numOEPRecording);

% Append acquisition metadata to config file 
cfg                                   = cfg_append_acq(cfg,OEP,PPD,recording); 
%% Setup saving output
cfg.savepath                          = [cfg.datapath,cfg.datestamp,'/test/'];
if ~isfolder(cfg.savepath) && cfg.overwrite == true
    mkdir(cfg.savepath)
    disp('----------------Output Directory Created At: ----------------')
    disp(cfg.savepath)
end

%%  Synchronize All Signals
[cfg,tCommon,gcampAln,isoAln,eegAln,temp,sync,optoOut] = sync_signals ... 
(cfg,OEP,TEMP,events,PPD);

%%  Denoise EEG
[eegFilt]                     = denoise_eeg(cfg, eegAln);

%%  Reject EEG Artifacts (optional)
[cfg, eegClean]               = reject_artifact(cfg,eegFilt);

%%  Denoise Fluorescence
[gcampFilt,isoFilt]           = denoise_photo(cfg,gcampAln,isoAln);

%%  Normalize Fluorescence
[dff,zdff]                    = normalize_photo(cfg,gcampFilt,isoFilt);

%%  High-pass filter DF/F (remove drift)
[dff_hpf]                     = hpf_photo(cfg,dff);

%%  Mark Times of Interest (TOIs)
[toi]                         = mark_tois(cfg,zdff, eegClean);

%%  Plot preprocessed signals
fig = figure('Visible',cfg.showPlot);
fig.Position = [431 174 1048 605];

tl = tiledlayout(fig, 2, 1);

% --- Panel 1: Photometry ---
ax1 = nexttile(tl);
plotPanel(ax1, tPhoto, zdff, 'z-\DeltaF/F');
title(ax1, sprintf('%s-%s', num2str(cfg.subject), cfg.datestamp));
yl = ylim(ax1);
ax1.YLim = [yl(1)-1, yl(2)+1];
addEventLines(ax1, tPhoto, toi, cfg.evtStyle);

% --- Panel 2: EEG (in mV) ---
ax2 = nexttile(tl);
plotPanel(ax2, tEEG, eegClean/1000, 'EEG (mV)');
ax2.YLim = [-15 15];
addEventLines(ax2, tEEG, toi, cfg.evtStyle);
xlabel('Time (s)')

% --- Adjust axes ---
linkaxes([ax1 ax2], 'x');
%extend x-axis 15 second beyond last data point
xmax = max([tEEG(end), tPhoto(end)]) + 15;
xlim(ax1, [0 xmax]);

%% Save preprocessed data (optional)
if cfg.overwrite == true
    % Save preproc figure
    saveas(fig, [cfg.savepath,'preproc_traces.fig']);  % Save as .fig file
    saveas(fig, [cfg.savepath,'preproc_traces.png']);  % Save as .png file
    delete(fig)

    % Save preproc data
    eegAln  = eegClean; %rename for convenience

    filename = [cfg.savepath,'preproc_data.mat'];
    save(filename,'cfg','syncData','toi', ...
        'dff','dff_hpf','zdff','zdff_hpf','tPhoto',...
        'eegAln','tEEG','-mat')

    disp('----------------------Preprocessed Data Saved!------------------')
else
    disp('----------------------Data was NOT Saved------------------------')
end
