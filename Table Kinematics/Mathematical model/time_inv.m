clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));
addpath(pwd,'lookup tables');

%%
v = 'v1';
lookup_table1 = load(strcat('lookup_table_', v, '_dq1.mat'));
lookup_table2 = load(strcat('lookup_table_', v, '_dq2.mat'));

%%
tic;
z = 13;
theta_x = 30;
theta_y = 0;
%[qA, qB, qC] = inv_kin_nearest(z, theta_x, theta_y, lookup_table1);
%[qA, qB, qC] = inv_kin_linear_interpolation(z, theta_x, theta_y, lookup_table2);
[qA, qB, qC] = inv_kin_general(z, theta_x, theta_y, v);
toc

%%
fwd_kin_general(qA, qB, qC, v, 1);