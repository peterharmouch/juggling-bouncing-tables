clc; clear; close all; 


%% Selecting the filename and the region to crop
filename = fullfile(pwd, 'jump data', 'pt19_20');
t_start = 22.95;
t_end = 23.44;


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


%% Cropping the part of interest
t = time_new(time_new >= t_start & time_new < t_end);
Z = Z(time_new >= t_start & time_new < t_end);
qx = qx(time_new >= t_start & time_new < t_end);
qy = qy(time_new >= t_start & time_new < t_end);
qz = qz(time_new >= t_start & time_new < t_end);
qw = qw(time_new >= t_start & time_new < t_end);

% plot(t, Z)


%% Saving the cropped file to a csv file with the correct format
timei = [t; t; t; t; t];
valuesi = [Z; qx; qy; qz; qw];
topici  = [repmat({'Z'},length(t),1); repmat({'qx'},length(t),1); repmat({'qy'},length(t),1); repmat({'qz'},length(t),1); repmat({'qw'},length(t),1)];
mystructi.elapsedTime = timei;
mystructi.value = valuesi;
mystructi.topic = topici;
myTablei = struct2table(mystructi);
writetable(myTablei, fullfile('..', 'csv files', 'pt24.csv'));

