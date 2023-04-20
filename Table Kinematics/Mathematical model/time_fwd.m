clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));
addpath(pwd,'lookup tables');

%%
v = 'v1';
lookup_table1 = load(strcat('lookup_table_', v, '_dq1.mat'));
lookup_table2 = load(strcat('lookup_table_', v, '_dq2.mat'));

%%
tic;
qA = 35;
qB = 36.5;
qC = 67.11;
%[z, tx, ty] = fwd_kin_nearest(qA, qB, qC, lookup_table1);
[z, tx, ty] = fwd_kin_linear_interpolation(qA, qB, qC, lookup_table2);
%[z, tx, ty] = fwd_kin_general(qA, qB, qC, v);
toc