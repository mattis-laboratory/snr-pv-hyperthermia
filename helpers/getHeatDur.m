%% Get heating durations and max temperature
clc; clear; close all;

params = nostim_analysis_params();
load(params.preprocFile, 'events','temp','heatStart','fullID','fsEEG','heat_dur')

%% For WTs with missing LAMP OFF data, get index of temp reaching 42.5
% 
% temp_end  = 42.5;
% 
% for sub = 1:length(temp)
% 
%     thisTemp = temp{sub};
%     temp_match = abs(thisTemp - temp_end);
%     end_dex(sub,:) = find(temp_match == min(temp_match),1,'first'); %take only first timepoint to reach temp
% 
% end
% 
% heatEnd       = events.cam.LampOFF;
% heatEnd(7:10) = end_dex(7:10);

%% Calculate Heating Duration 
% heatEnd   = events.cam.LampOFF;
% heatStart = heatStart*fsEEG;
% heat_dur  = (heatEnd-heatStart)/(fsEEG*60); 

%% Get Max Temperature 
max_temps = cellfun(@max,temp,'UniformOutput',true);

new_data = [max_temps, heat_dur];

writematrix(new_data,'Temperature_Summary_NoStim.xlsx','Sheet',strcat([params.group],'_new'))



