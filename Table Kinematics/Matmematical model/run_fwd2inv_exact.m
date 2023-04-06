clc; close all; clear;
addpath(fullfile(pwd,'functions'));
addpath(fullfile(pwd,'lookup tables'));

%%
v = 'v1';
lookup_table = load(strcat('lookup_table_', v, '_dq1.mat'));

%%

tic;
z = 16.1;
theta_x = 0;
theta_y = 0;
[qA, qB, qC] = inv_kin(z, theta_x, theta_y, lookup_table);
toc

%%

fwd_kin_general(qA, qB, qC, v, 1);