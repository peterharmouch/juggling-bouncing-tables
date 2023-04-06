clc; clear; close all; 


%%
% Sometimes when I can change the parameters quickly between one recording
% and the other, I can just use the pause function in the optitrack and
% record the data one after the other in the same file. This code allows me
% to split the collected data and put each recording in one file with the
% same format and the other files saved individually
%%


%% Choosing file and determining number of jump and first file index
filename = fullfile(pwd, 'jump data', 'pt01_02_03');
nb_jumps = 3;
start_idx = 1;


%% Extracting data
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
data = readtable(filename);  

time = table2array(data(:, 'elapsedTime'));
values = table2array(data(:, 'value'));
topics = table2array(data(:, 'topic'));
topic = string(topics);

time_new = time(topic == "Z");
Z = values(topic == "Z");
qx = values(topic == "qx");
qy = values(topic == "qy");
qz = values(topic == "qz");
qw = values(topic == "qw");


%% Saving each part in a new csv file in the correct format
timet = time_new';
jump_indices = find(diff(timet) > 10);
jump_indices = [0 jump_indices length(timet)];
len = zeros(nb_jumps, 1);
idx_cum = 0;
idx = zeros(nb_jumps, 1);
for i = 1:nb_jumps
    len(i) = jump_indices(i+1) - jump_indices(i); 
    idx_cum = idx_cum + len(i);
    idx(i) = idx_cum;
    idxi = ((idx(i)-len(i))+1):idx(i);
    timei_new = time_new(idxi) - time_new((idx(i)-len(i))+1);
    timei = [timei_new; timei_new; timei_new; timei_new; timei_new];
    valuesi = [Z(idxi); qx(idxi); qy(idxi); qz(idxi); qw(idxi)];
    topici = [repmat({'Z'},len(i),1); repmat({'qx'},len(i),1); repmat({'qy'},len(i),1); repmat({'qz'},len(i),1); repmat({'qw'},len(i),1)];
    mystructi.elapsedTime = timei;
    mystructi.value = valuesi;
    mystructi.topic = topici;
    myTablei = struct2table(mystructi);
    if i+start_idx-1 < 10
        writetable(myTablei, fullfile('..', 'csv files', strcat('pt0', num2str(i+start_idx-1), '.csv')));
    else
        writetable(myTablei, fullfile('..', 'csv files', strcat('pt', num2str(i+start_idx-1), '.csv')));
    end
end

