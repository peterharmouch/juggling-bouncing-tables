clc; close all; clear;
addpath(fullfile(pwd,'lookup tables'));
addpath(genpath(fullfile(pwd,'functions')));


%% 
% This code allows us to choose the required outputs and see a plot of 
% the table reproducing this output by means of running the inverse
% kinematics and plugging the results into the forward kinematics function
% that allows us to plot the table

v = 'v1';

% With "real" table (lookup_table_v1_dq2.mat)
z = 10;
theta_x = 10;
theta_y = 0;

% % With new design (lookup_table_v3_dq2.mat)
% z = 16;             % 16  -> 20
% theta_x = 15;       % 0   -> 30
% theta_y = 0;        % -10 -> 10

lookup_table = load(strcat('lookup_table_', v, '_dq2.mat'));
[qA, qB, qC] = inv_kin_linear_interpolation(z, theta_x, theta_y, lookup_table);
fwd_kin_general(qA, qB, qC, v, 1);