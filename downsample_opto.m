function [stimON_adj, opto_down] = downsample_opto(opto_volts)

%% Downsample Opto Signal 
fs_high = 1000;              % original sampling rate (Hz)
fs_low  = 100;               % target sampling rate (Hz)

t_high = (0:length(opto_volts)-1) / fs_high;

% ---------------------------
% 1. Filter to prevent aliasing
% ---------------------------
cutoff = fs_low / 2.5;  % conservative cutoff to reduce ringing
[b, a] = butter(4, cutoff / (fs_high/2)); 
opto_filt = filtfilt(b, a, double(opto_volts));

% ---------------------------
% 2. Downsample to target fs
% ---------------------------
[opto_down, ~] = resample(opto_filt, t_high, fs_low);

% ---------------------------
% 3. Re-binarize (convert back to logical TTL)
% ---------------------------
% Determine a threshold halfway between low and high states
thr         = (min(opto_down) + max(opto_down)) / 2;
opto_binary = opto_down > thr;

opto_edges = diff(opto_down > 0.5);
stimON     = find(opto_edges == 1);  % rising edges

%% Ensure all opto times are 100 samples apart

d = diff(stimON);
s = floor(mean(d));
start = stimON(1);

stimON_adj = start:s:start+((length(stimON)-1)*100);
%new_d = diff(stimON_adj);
%figure; plot(d); hold on; plot(new_d)


end