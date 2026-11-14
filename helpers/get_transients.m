%% Calcium Transients Detection and Characterization (whole signal)
% Chandni Rana
% University of Michigan
% Mattis Lab
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% This script identifies calcium transients in fluorescence time-series
% signals (using find peaks) 
% Properties of identified transients are then calculated (see OUTPUT) 
% Detection parameters are set using "transients_detection_params()" 
% Expected input is Nx1 data (N = trials)
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% INPUT:
% params   (struct)       - user-specified detection parameters
% zdff     (Nx1 cell)     - z-DF/F fluorescence signals
% dff      (Nx1 cell)     - DF/F fluorescence signals
% zdff_hpf (Nx1 cell)     - z-DF/F and high-pass filtered fluorescence 
%                           signals
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% OUTPUT (Nx7 cell) containing:
% 1 - PEAKS               - z-DF/F signal value at detected timestamps 
%                           ("peak value")
% 2 - LOCS                - indices of detected peaks
% 3 - WIDTHS              - width of detected peaks
% 4 - P2TAmp              - peak-to-trough amplitude (nearest trough within
%                           user-specified window) 
% 5 - PROMS               - peak prominences
% 6 - DFF PEAKS           - same as (1) but on DF/F signal
% 7 - P2TAmp(DFF)         - same as (4) but on DF/F peaks
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

clear; close all

%% Load Detection Parameters and Data
params     = nostim_analysis_params();
load(params.preprocFile,params.transientsInVars{:})

% Preallocate output
transients = cell([numel(zdff.signal_hpf),7]);

%% Detect Peaks (across all subjects)
for n = 1:numel(zdff.signal_hpf)

    thisZdff = zdff.signal_hpf{n};
    thisDff  = dff.signal{n};

    % ------- GET ALL (z-DF/F) TRANSIENTS PROPERTIES ------%
    [pks,locs,widths,P2Tamp,proms] = transients_props(params,thisZdff,zdff.fs);

    % ------- GET (DF/F) PEAK-TO-TROUGH AMPLITUDE  ------%
    pks_dff                        = thisDff(locs);
    [P2Tamp_dff]                   = get_p2t_amplitude(params,thisDff,dff.fs,pks_dff,locs);

    % ------- STORE ALL RESULTS  ------%
    transients{n,1} = pks;  
    transients{n,2} = locs;
    transients{n,3} = widths;
    transients{n,4} = P2Tamp;
    transients{n,5} = proms;
    transients{n,6} = pks_dff;
    transients{n,7} = P2Tamp_dff;

    clearvars -except params n zdff dff fs transients

end

%% Save Output
save([params.detTransientsFname,'.mat'],'transients','params','-mat')

