clc; clear; close all;
addpath(pwd, "functions");


%% Choose file number
file_Ts = 75;


%% Reading inputs
filename = fullfile(pwd, 'csv files', 'PRBS_input.csv');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
in_data = readtable(filename); 

input = table2array(in_data(:, strcat('exact_', num2str(file_Ts))));
input = input(~isnan(input));


%% Extracting output data
filename = fullfile(pwd, 'csv files', strcat('exact_',  num2str(file_Ts), '_all.csv'));
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
out_data = readtable(filename);  

time = table2array(out_data(:, 'elapsedTime'));
values = table2array(out_data(:, 'value'));
topics = table2array(out_data(:, 'topic'));
topic = string(topics);

time_new = time(topic == "Z");
height = values(topic == "Z");
qx = values(topic == "qx");
qy = values(topic == "qy");
qz = values(topic == "qz");
qw = values(topic == "qw");


%% Check graph to identify first_jump time
plot(time_new, height);


%% Choosing the input to use
in = input';
first_jump = 13.116; % determined by checking graph % 13.116
delay = 0.034; % determined experimentally
n_zeros = count_first_zeros(in) + 1;
Ts = 20/length(in);
t_start = first_jump - (n_zeros*Ts) - delay;
t_end = t_start + 20 - Ts;


%% Setting the values of the low and high input values
qA_in = length(in);
qA_in(in == 0) = 35.785;
qA_in(in == 1) = 47.395;

qB_in = length(in);
qB_in(in == 0) = 43.427;
qB_in(in == 1) = 52.017;

qC_in = length(in);
qC_in(in == 0) = 34.073;
qC_in(in == 1) = 46.501;


%% Obtaining outputs and corresponding input angles within the time of interest
t = t_start:Ts:t_end;
height = interp1(time_new, height, t);
qx = interp1(time_new, qx, t);
qy = interp1(time_new, qy, t);
qz = interp1(time_new, qz, t);
qw = interp1(time_new, qw, t);

% Computing outputs from measurments
[Z, theta_x, theta_y] = measurment2out(height, qz, qy, qz, qw);

% Inverse kinematics
v = 'v1';
lookup_table = load(strcat('lookup_table_', v, '_dq2.mat'));
[qA_out, qB_out, qC_out] = inv_kin_linear_interpolation(Z, theta_x, theta_y, lookup_table);


%% The bode plots
% Importing data into an iddata object
dataA = iddata(qA_out', qA_in', Ts);
dataA = detrend(dataA);

dataB = iddata(qB_out', qB_in', Ts);
dataB = detrend(dataB);

dataC = iddata(qC_out', qC_in', Ts);
dataC = detrend(dataC);

% qA tf
% Identifying the system and plotting the non-parametric Bode plot
figure(2);
subplot(3,3,1);
sys_npA = spa(dataA);
bode(sys_npA);
grid on;
xlim([1e-1, 1e3]);
title('Non-parametric Bode plot for qA');

% Identifying the system and plotting the parametric Bode plot
subplot(3,3,2);
sys_pA = tfest(dataA, 2);
bode(sys_pA);
grid on;
xlim([1e-1, 1e3]);
title('Parametric Bode plot for qA');

% Identifying the discrete system
subplot(3,3,3);
sys_pdA = tfest(dataA, 3, 2, 0, 'Ts', Ts);
bode(sys_pdA);
grid on;
xlim([1e-1, 1e3]);
title('Discrete Parametric Bode plot for qA');

% qB tf
subplot(3,3,4);
sys_npB = spa(dataB);
bode(sys_npB);
grid on;
xlim([1e-1, 1e3]);
title('Non-parametric Bode plot for qB');

subplot(3,3,5);
sys_pB = tfest(dataB, 2);
bode(sys_pB);
grid on;
xlim([1e-1, 1e3]);
title('Parametric Bode plot for qB');

subplot(3,3,6);
sys_pdB = tfest(dataB, 3, 2, 0, 'Ts', Ts);
bode(sys_pdB);
grid on;
xlim([1e-1, 1e3]);
title('Discrete Parametric Bode plot for qB');

% qC tf
subplot(3,3,7);
sys_npC = spa(dataC);
bode(sys_npC);
grid on;
xlim([1e-1, 1e3]);
title('Non-parametric Bode plot for qC');

subplot(3,3,8);
sys_pC = tfest(dataC, 2);
bode(sys_pC);
grid on;
xlim([1e-1, 1e3]);
title('Parametric Bode plot for qC');

subplot(3,3,9);
sys_pdC = tfest(dataC, 3, 2, 0, 'Ts', Ts);
bode(sys_pdC);
grid on;
xlim([1e-1, 1e3]);
title('Discrete Parametric Bode plot for qC');

% Adjusting figure properties
sgtitle('Bode Plots for qA, qB and qC');

