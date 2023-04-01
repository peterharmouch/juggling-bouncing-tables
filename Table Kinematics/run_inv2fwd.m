clc; close all; clear;
addpath(fullfile(pwd,'functions'));
addpath(fullfile(pwd,'lookup tables'));


%% 
% This code allows us to choose the required outputs and see a plot of 
% the table reproducing this output by means of running the inverse
% kinematics and plugging the results into the forward kinematics function
% that allows us to plot the table

v = 'v1';

% With "real" table (lookup_table_v1_dq2.mat)
z = 11;           % 10  -> 13  and  10 -> 13  and  10.5 -> 12.5
theta_x = 15;     % 0   -> 20  and  0  -> 24  and  0    -> 28
theta_y = 0;      % -12 -> 12  and  -7 -> 7   and  -7   -> 7

% % With new design (lookup_table_v3_dq2.mat)
% z = 16;             % 16  -> 20
% theta_x = 15;       % 0   -> 30
% theta_y = 0;        % -10 -> 10

lookup_table = load(strcat('lookup_table_', v, '_dq2.mat'));
[qA, qB, qC] = inv_kin_interpol(z, theta_x, theta_y, lookup_table);
fwd_kin_general(qA, qB, qC, v, 1);