%% Get downsampled and adjusted opto stim times
clear; close all;
params = stim_analysis_params();
load(params.preprocFile,'events','zdff','sync')

%% Loop through all sessions

for n = 1:size(zdff.signal,1)
    
opto_volts            = sync{n,1}.opto_common; 
[stimON, opto_down]   = downsample_opto(opto_volts);

%% Rederive opto times on downsample opto timeline

topto      = (1:length(opto_down))/zdff.fs; % downsampled opto timeline
tphoto     = zdff.t{n};

tphoto     = sync{n,1}.scaling * tphoto;
topto      = topto - sync{n,1}.offset;
optoTimes  = topto(stimON);

%% Plot opto times overlaid on z-df/f
plot(tphoto,zdff.signal{n,1})
hold on

yL = ylim;
x  = [optoTimes; optoTimes; nan(size(optoTimes))];
y  = [repmat(yL(1), 1, numel(optoTimes));
     repmat(yL(2), 1, numel(optoTimes));
     nan(1, numel(optoTimes))];

plot(x(:), y(:), 'k-', 'LineWidth', 0.5)
hold off

%% Save new timestamps
events.stimTimes_ds{n,:} = optoTimes; 
events.topto{n,:} = topto;

clear opto* t* yL x y stimON

end