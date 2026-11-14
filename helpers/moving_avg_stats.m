%% 2-way ANOVA on moving average of transient properties 


for subject = 1:length(moving_amp)

amp_bin_start(subject,:)  = moving_amp{subject,:}(end);
amp_bin_end(subject,:)    = moving_amp{subject,:}(1);

freq_bin_start(subject,:) = moving_freq{subject,:}(end);
freq_bin_end(subject,:)   = moving_freq{subject,:}(1);

end

amp_all  = [mouseID, amp_bin_start, amp_bin_end];
freq_all = [mouseID, freq_bin_start, freq_bin_end];



writematrix(amp_all,'amps_heat_LME.xlsx','Sheet','WT_nsz')
writematrix(freq_all,'freqs_heat_LME.xlsx','Sheet','WT_nsz')