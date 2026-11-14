
function cfg = setup_preproc_config()

% User-defined parameters for running preprocessing script
% Always double-check before running 
cfg = struct();

%% --- Subjects ---
cfg.subject            = '4717';     % ID of which mouse to run

%% --- Paths ---
cfg.root               = '/nfs/turbo/umms-mattislab/Chandni/Data/';
cfg.project            = 'SNr_all';
cfg.datapath           = [cfg.root,cfg.project,'/',num2str(cfg.subject),'/']; 

%% --- Channels / signals ---
cfg.eegChannel         = 2;          % which EEG channel to load/process
cfg.emgChannel         = 3;          % which EMG channel to load/process
cfg.numOEPRecording    = 1;          % which recording (usually first one)
cfg.hasOpto            = true;       % Was this an opto experiment
cfg.optoADC            = 23;         % ADC 7 = 23 in OEP
cfg.tempADC            = 1;          % Temperature recorded on analog AO1 on NI-USB DAQ
cfg.OEPstream          = 1;          % OEP Stream Number
cfg.NIstream           = 2;          % NI-DAQ Stream Number

%% --- Processing options ---
cfg.rejectArtifact     = false;      % choose whether to interpolate eeg artifacts (optional)
cfg.denoiseEEG         = true;       % choose whether to filter EEG
cfg.denoisePhoto       = true;       % choose whether to filter photometry
cfg.gaussSigma         = 75;         % stdev of gaussian kernel for photometry denoising (in samples)
cfg.hpfCutoff          = 0.01;       % cutoff freq. for high-pass filtering (in Hz)
cfg.blDuration         = 60;         % duration of baseline/ when heating started (in seconds)
cfg.exceptionTTL       = false;      % if ttl signal had noise or was cutoff, note here

%% --- Plotting options ---

% Colors/styles for event lines
cfg.evtStyle           = struct( ...
    'HEAT', struct('Color','b','LineStyle','--','LineWidth',2), ...
    'EEC',  struct('Color','r','LineStyle','--','LineWidth',2), ...
    'UEO',  struct('Color','g','LineStyle','--','LineWidth',2), ...
    'OFF',  struct('Color','k','LineStyle','--','LineWidth',2) );

cfg.showPlot           = 'on';       % Show final plots

%% --- Overwrite ---
cfg.overwrite          = true;      % Overwrite existing save 
end
