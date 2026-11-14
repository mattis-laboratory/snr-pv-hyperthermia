function [cfg,tCommon,gcampAln,isoAln,eegCommon,emgCommon,sync,optoOut] = ...
    sync_signals(cfg,OEP,events,PPD)

%function [cfg,tCommon,gcampAln,isoAln,eegCommon,tempCommon,sync,optoOut] = ...
   % sync_signals(cfg,OEP,TEMP,events,PPD)
%% EXCEPTIONS LOG: 
%  In the event that the signal from the sync channel is corrupted (e.g., 
%  spurious noise, recording begins in the middle of ongoing barcode, etc.)
%  it is necessary to acutely adjust the sync code to avoid misalignment. 
%
%  Record here the mouse, session, experiment, description of issue, which 
%  TTL is corrupted (i.e., pyPhotometry or Open Ephys) and how the sync 
%  code needs to be adjusted for this specific session. Update this log 
%  in both the "get_OEP_TTL.m" and "sync_signals.m" scripts.
% ------------------------------------------------------------------------
% 
% 5636_2026-06-30 [PPN PTZ]
% First barcode in OEP sync was incompletely captured at the start of
% recording and not captured at all by pyPhotometry. 
% -----Solution-----
% Ignore the incomplete first OEP barcode. 
% Remove first 7 samples in event.sample_number. 
% ------------------------------------------------------------------------

%% Extract raw gcamp, isosbestic, and EEG signals and TTLs and opto 
gcampRaw                          = PPD.analog_1;
isoRaw                            = PPD.analog_2;
photoSync                         = PPD.digital_1;
photoSyncEdges                    = find(diff(photoSync) > 0) + 1;
photoSyncTimes                    = (photoSyncEdges - 1)/cfg.photoFs;

eegRaw                            = double(OEP.samples(cfg.eegChannel,:));
emgRaw                            = double(OEP.samples(cfg.emgChannel,:));
[eegSync, eegSyncTimes]           = get_OEP_TTL(OEP,events);
eegSync                           = +eegSync;

%% Save sync processing output
sync       = struct();

%% Correct starting time offset 
t_first_eeg         = eegSyncTimes(1);
t_first_photo       = photoSyncTimes(1);
start_diff          = abs(t_first_photo - t_first_eeg);

if t_first_eeg < t_first_photo
    % EEG started first 
    eegSyncTimes    = eegSyncTimes + (start_diff);
    sync.acqFirst   = 'eeg';
else
    % Photometry started first 
    photoSyncTimes  = photoSyncTimes + (start_diff);
    sync.acqFirst   = 'photometry';
end

sync.start_offset  = start_diff;

%%  Match TTL pulses
matched_photo = [];
matched_eeg   = [];

tol = 1.0; % seconds tolerance
for i = 1:numel(eegSyncTimes)
    [dt, j] = min(abs(photoSyncTimes - eegSyncTimes(i)));
    if dt <= tol
        matched_eeg(end+1)   = eegSyncTimes(i); %#ok<AGROW>
        matched_photo(end+1) = photoSyncTimes(j); %#ok<AGROW>
    end
end

if isempty(matched_eeg)
    error('No matched TTL pulses found. Check tolerance or TTL data.');
end

sync.matched_photo = matched_photo;
sync.matched_eeg   = matched_eeg;

%% Linear mapping to correct for clock drift
% Linear mapping: t_corr = scaling * t_photo + start_diff
p                   = polyfit(matched_photo,matched_eeg,1);
scaling             = p(1);
% offset              = p(2);
% sync.linear_offset  = offset;
sync.scaling        = scaling;
sync.fit            = p;
%% Warp photometry timeline 
t_photo             = (0:length(gcampRaw)-1)/cfg.photoFs; 
%t_photo_aligned     = (scaling * t_photo ) + offset; 
t_photo_aligned     = (scaling * t_photo ) + start_diff; 

%% Only get overlapping EEG times 
tEEG                = (0:length(eegRaw)-1)/cfg.eegFs;
t_min               = max(min(t_photo_aligned), min(tEEG));
t_max               = min(max(t_photo_aligned), max(tEEG));
mask                = tEEG >= t_min & tEEG <= t_max;
tEEG                = tEEG(mask);
eegCommon           = eegRaw(mask);
emgCommon           = emgRaw(mask);
eegSyncCommon       = eegSync(mask);

%% Upsample Photometry and Get Aligned Signals
gcampAln            = interp1(t_photo_aligned, gcampRaw, tEEG, 'pchip');
isoAln              = interp1(t_photo_aligned, isoRaw, tEEG, 'pchip');
photoSyncAln        = interp1(t_photo_aligned, +photoSync, tEEG, 'previous');

%%  Convert Temperature Signal to Degrees (C) and Align
% [temp]              = volt2temp(cfg,TEMP);
% tempCommon          = temp(1:length(eegCommon));

%% For opto experiments, convert, align, and detect opto stim times
optoOut             = struct();

if cfg.hasOpto    ==  true
optoVolts           = cfg.ADC_bitVolt * double(OEP.samples(cfg.optoADC,:));
optoCommon          = optoVolts(mask);

thresh              = 2.5;  % voltage threshold 
optoEdges           = diff(optoCommon > thresh);
stimON              = find(optoEdges == 1);  % stim ON times

optoOut.stimON      = stimON;
optoOut.optoAln     = optoCommon;
end

%% Output aligned signals and processing info
sync.tEEG              = tEEG;
sync.photoSyncAln      = photoSyncAln;
sync.eegSyncAln        = eegSyncCommon;
tCommon                = 0:1/cfg.eegFs:(length(gcampAln)-1)/cfg.eegFs;

end
