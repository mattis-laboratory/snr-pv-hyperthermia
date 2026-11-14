function [tdegrees] = volt2temp(cfg,TEMP)
% % --------------------------------------
% Chandni Rana
% University of Michigan
% 06/2024 
%
% This function converts temperature data digitized on a NI-USB 6009 DAQ
% and acquired through Open Ephys into degrees Celsius
% --------------------------------------
% INPUT: 
% TEMP = MATLAB struct containing raw data from the NI-USB 6009
% datastream 
% --------------------------------------
% OUTPUT:
% temp_degrees = temperature converted into degrees Celsius
% --------------------------------------

%Fs = tempdata.metadata.sampleRate;
%ts = 1/Fs:1/Fs:length(tempdata.sampleNumbers)/Fs;
tdigital = double(TEMP.samples(cfg.tempADC,:));

% Bit2Volt conversion factor 
bit_volts = cfg.ADC_bitVolt; 

% Physitemp recommendation for smoothing analog signal
smooth_factor = 300; 
tsmooth = smooth(tdigital,smooth_factor);

% Convert to mV
tread = tsmooth'*bit_volts*1000;

% Calibrated coefficients 
a = 0.0981; 
b = 8.81; 

% Convert to degrees Celsius
tdegrees = (a*tread) + b; 

end