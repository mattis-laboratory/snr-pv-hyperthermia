function [p2tAmp] = get_p2t_amplitude(params,signal,fs,pks,locs)

% Initialize an array to store the peak-to-trough amplitudes
p2tAmp = zeros(1, length(locs));
% Loop through each detected peak to find the nearest trough
for i = 1:length(locs)
    % Set the window range to look for a trough around the peak
    window_start = max(1, locs(i) - (params.p2tWin*fs));  % Avoid out-of-bounds
    window_end   = min(length(signal), locs(i) + (params.p2tWin*fs));

    % Find the minimum (trough) value within the window
    [trough_value, ~] = min(signal(window_start:window_end));

    % Calculate peak-to-trough amplitude
    p2tAmp(i) = pks(i) - trough_value;
end

end
