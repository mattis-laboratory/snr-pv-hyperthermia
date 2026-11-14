
function params = stim_analysis_params()

% User-defined parameters for running preprocessing script
% Always double-check before running 

params              = struct();
%% --- Main Directory ---

params.root         = '/nfs/turbo/umms-mattislab/Chandni/Data/';
params.project      = 'SNr_all';
params.group        = 'het_sz';
params.condition    = 'stim';
params.append       = [params.group,'_',params.condition];

%% --- Filenames ---

% Preprocessed Data
params.preprocFile  ...
    = [params.root,params.project,'/groups/', ...
    params.condition,'/', params.append,'.mat'];

%% --- Temperature reference data ---
params.EEC_temp           = 41.128;  % Average EEC temperature of hets that had seizures (WITH opto)
params.UEO_temp           = 41.216;  % Average UEO temperature of hets that had seizures (WITH opto)
params.OFF_temp           = 41.360;  % Average OFF temperature of hets that had seizures (WITH opto)
params.sz_dur             = 24.577;  % Average seizure duration  (in seconds)

%% --- Plotting options ---

% Colors/styles for event lines
params.evtStyle           = struct( ...
    'HEAT', struct('Color','b','LineStyle','--','LineWidth',2), ...
    'EEC',  struct('Color','r','LineStyle','--','LineWidth',2), ...
    'UEO',  struct('Color','g','LineStyle','--','LineWidth',2), ...
    'OFF',  struct('Color','k','LineStyle','--','LineWidth',2) );

params.showPlot           = 'on';       % Show final plots

%% --- Overwrite ---
%params.overwrite          = true;      % Overwrite existing save 
end

