%% Get average EEC UEO (and OFF) temperature in hets
for ii = 1:length(het_temps)
    thisTemp = het_temps{ii,:};
    EEC = het_marks{ii,:}(2);
    UEO = het_marks{ii,:}(3);
    OFF = het_marks{ii,:}(4);

    EEC_temps(ii) = thisTemp(EEC);
    UEO_temps(ii) = thisTemp(UEO);
    OFF_temps(ii) = thisTemp(OFF);


clear EEC UEO OFF thisTemp

end

avgEECtemp = mean(EEC_temps);
avgUEOtemp = mean(UEO_temps);
avgOFFtemp = mean(OFF_temps);

%% Get average seizure duration
for ii = 1:length(het_marks_ds)
    UEO = het_marks_ds{ii,:}(3);
    OFF = het_marks_ds{ii,:}(4);
    szDurs(ii,:) = OFF-UEO;
    clear UEO OFF
end

avgSzDur = mean(szDurs);
%% Update markings
% average temps for SNr opto mice that had seizures
avg_EEC_temp = 41.13;
avg_UEO_temp = 41.22;
%avg_OFF_temp = 41.36;
avgSzDur = 2457; % in samples (of photometry signal)
fs_photo = 1000;
for kk = 1:length(het_non_temps)
    thisTemp = het_non_temps{kk,:};
    thisTemp = smooth(thisTemp,100);
    %t_common = het_non_syncInfo{kk,:}.t_common;
    t_common = getTime(thisTemp,1000);
    thisZdff = het_non_zdff_BL{kk,:};
    tp = (0:length(thisZdff)-1)/fs_photo;
    [x,cutoff] = max(thisTemp);
    thisTemp = thisTemp(1:cutoff); % exclude second half of curve (only want values from the heating phase)
    EEC_match = abs(thisTemp - avg_EEC_temp);
    UEO_match = abs(thisTemp - avg_UEO_temp);

    EEC_dex = find(EEC_match == min(EEC_match),1,'first'); %take only first timepoint to reach temp
    UEO_dex = find(UEO_match == min(UEO_match),1,'first'); %take only first timepoint to reach temp


    %get time on downsampled timeline
    tEEC = t_common(EEC_dex);
    tUEO = t_common(UEO_dex);

    [~, EEC_down] = min(abs(tp - tEEC));
    [~, UEO_down] = min(abs(tp - tUEO));
    OFF_down = UEO_down + avgSzDur;
    OFF_dex  = UEO_dex  + avgSzDur*10;
    figure;
    plot(thisTemp);
    hold on;
    plot(EEC_dex,thisTemp(EEC_dex),'ro')
    plot(UEO_dex,thisTemp(UEO_dex),'go')
    plot(OFF_dex,thisTemp(OFF_dex),'ko')

  %  het_non_marks_ds{kk} = [het_non_marks_ds{kk,1}(1),EEC_down,UEO_down,OFF_down];
    het_non_marks{kk} = [het_non_marks{kk,1}(1),EEC_dex,UEO_dex,OFF_dex];


    clear EEC* UEO* OFF* t*


end