clc; clear; close all;
addpath(pwd, "lookup tables");
addpath(pwd, "functions");


%%
tic;
Ts = 0.05;
t_end = 5;
LT = load("lookup_table_v1_dq1.mat");

t = (0:Ts:t_end)';

Z_in.time = t;
tx_in.time = t;
ty_in.time = t;

qAinit.time = 0;
qBinit.time = 0;
qCinit.time = 0;

N = length(t);
t1 = 0:Ts:1;
t2 = (1+Ts):Ts:t_end;

% Z_values = [12.975 * ones(length(t1), 1); 14 * ones(length(t2), 1)];
% tx_values = [0 * ones(length(t1), 1); 5 * ones(length(t2), 1)];
% ty_values = [0* ones(length(t1), 1); 3 * ones(length(t2), 1)];

Z_values = [linspace(15, 12, floor(length(t)/2)), 12, linspace(12, 15, floor(length(t)/2))]';
tx_values = linspace(10, 10, length(t))';
ty_values = linspace(-5 ,5, length(t))';

[qA_init, qB_init, qC_init] = inv_kin_nearest(Z_values(1), tx_values(1), ty_values(1), LT);

qAinit.signals.values = qA_init;
qBinit.signals.values = qB_init; 
qCinit.signals.values = qC_init;

Z_in.signals.values = Z_values;
tx_in.signals.values = tx_values; 
ty_in.signals.values = ty_values;

simout = sim('control_JBT.slx', t);

Z_out = simout.Z_out.data;
tx_out = simout.tx_out.data;
ty_out = simout.ty_out.data;


%% 
figure(1);
stairs(t, Z_out);

figure(2);
stairs(t, tx_out);

figure(3);
stairs(t, ty_out);

toc