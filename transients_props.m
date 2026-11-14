function [pks,locs,widths,P2Tamp,proms] = transients_props(params,signal,fs)

    
    % ------- FIND PEAKS ACROSS WHOLE SIGNAL ------%
    [pks, locs, ~, proms]     = findpeaks(signal,"MinPeakProminence",params.minProm);
    
    % ------- GET PEAK WIDTHS ------%
    [widths]                  = get_peak_width(params,signal,pks,locs,proms);
    
    % ------- REMOVE PEAKS LONGER THAN X SEC (to avoid detecting seizure peaks) ------%
    above_thresh              = find(widths>params.maxWidth*fs);
    pks(above_thresh)         = [];
    locs(above_thresh)        = [];
    widths(above_thresh)      = [];
    proms(above_thresh)       = [];

    % ------- GET PEAK-TO-TROUGH AMPLITUDE  ------%
    [P2Tamp]                  = get_p2t_amplitude(params,signal,fs,pks,locs);



end