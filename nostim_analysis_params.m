
function params     = nostim_analysis_params()

params              = struct();

%% --- Main Directory ---
params.root         = '/nfs/turbo/umms-mattislab/Chandni/Data/';
params.project      = 'SNr_all';
params.group        = 'WT_nsz';
params.condition    = 'nostim';
params.append       = [params.group,'_',params.condition];

%% --- Filenames ---

% Preprocessed Data
params.preprocFile  ...
    = [params.root,params.project,'/groups/', ...
    params.condition,'/', params.append,'.mat'];

% Means Binned By Temperature
params.meanTempFname ...
   = [params.root,params.project,'/groups/', ...
    params.condition,'/results/temp_binned_means/',params.group,'/'];

% Triggered Average Directory
params.trigAvgOutput   ...
    = [params.root,params.project,'/groups/', ...
    params.condition,'/results/trig_avg/'];

% Triggered Average AUC
params.trigAvgAUC ...
    = [params.trigAvgOutput,params.group,'_AUC'];

% Triggered Average Traces
params.trigAvgTraces ...
    = [params.trigAvgOutput,params.group,'_traces'];

% Transients Directory
params.transientsOutput   ...
    = [params.root,params.project,'/groups/', ...
    params.condition,'/results/transients/'];

% Transients Plots
params.transientsPlots ...
    = [params.transientsOutput,'/', ...
    params.group,'_plots/'];

% Detected Transients Output
params.detTransientsFname  ...
    = [params.transientsOutput,params.group,...
    '_transients'];

% Transients TOIs
params.toiTransientsFname ...
    = [params.transientsOutput,'TOI/', ...
    params.group,'_metrics.xlsx'];

% Transients Moving Averages
params.mavgTransientsFname ...
    = [params.transientsOutput,'moving_avg/',...
    params.group];

% Transients Temp Binned
params.tempTransientsFname ...
    = [params.transientsOutput,'temp_binned/',...
    params.group];

%% --- Cohort Reference Points ---
params.EEC_temp           = 41.728;  % Mean EEC temperature of hets that had seizures (without opto)
params.UEO_temp           = 41.860;  % Mean UEO temperature of hets that had seizures (without opto)
params.OFF_temp           = 42.062;  % Mean OFF temperature of hets that had seizures (without opto)
params.sz_dur             = 16.236;  % Mean seizure duration  (in seconds)

%% --- Triggered Average Parameters ---
params.eventPreTime  = 30;    % Duration before event to average activity (in seconds)
params.eventPostTime = 30;    % Duration after event to average activity (in seconds)
params.camSzRelOnset = 8.06;  % Average amount of time between EEC and behavioral seizure onset of hets (in seconds)
                              % EEC + camSzRelOnset = camSz-equivalent time
%% --- Variables ---
params.transientsInVars = {'zdff','dff'};
% params.outVars        = {'pks','locs','widths','p2tAmps',...
%                        'proms','pks_dff','p2tAmps_dff'};

%% --- Transients Detection Parameters ---
params.minProm      = 1;      % Minimum peak prominence
params.maxWidth     = 8;      % Maximum peak width (in seconds)
params.promFraction = 0.5;    % Percentage of prominence at which to calculate width
params.p2tWin       = 2.5;    % Time window (in seconds) to look for trough when calculating peak-to-trough amplitude

%% --- Transients Analysis Parameters ---

% Moving Average
params.binWin       = 60;     % Window size for moving average (in seconds)
params.stepSize     = 10;     % Amount of overlap between windows (in seconds)

%% --- Plotting Options ---

params.evtStyle     = struct( ...
    'BL',   struct('Color','b','LineStyle','--','LineWidth',2), ...
    'EEC',  struct('Color','r','LineStyle','--','LineWidth',2), ...
    'UEO',  struct('Color','g','LineStyle','--','LineWidth',2), ...
    'OFF',  struct('Color','k','LineStyle','--','LineWidth',2));

end
