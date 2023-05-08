clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));
addpath(pwd,'lookup tables');

%%
v = 'v1';
lookup_table1 = load(strcat('lookup_table_', v, '_dq1.mat'));
lookup_table2 = load(strcat('lookup_table_', v, '_dq2.mat'));

%%
tic;
qA = 30;
qB = 30;
qC = 30;
%[z, tx, ty] = fwd_kin_nearest(qA, qB, qC, lookup_table1);
%[z, tx, ty] = fwd_kin_linear_interpolation(qA, qB, qC, lookup_table2);
[z, tx, ty] = fwd_kin_general(qA, qB, qC, v, 1);
toc