clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));
addpath(pwd,'lookup tables');

%%
v = 'v1';
lookup_table = load(strcat('lookup_table_', v, '_dq1.mat'));

%%
tic;
z = 14;
theta_x = 5;
theta_y = 3;
[qA, qB, qC] = inv_kin_nearest(z, theta_x, theta_y, lookup_table);
toc

%%
fwd_kin_general(qA, qB, qC, v, 1);