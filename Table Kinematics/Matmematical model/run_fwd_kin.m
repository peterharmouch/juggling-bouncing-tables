clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));


%%
% This code allows us to run the forward kinematics and see the table

qA = 48; % Angle in deg for the servo on the y axis on the point (0, d)
qB = 41.1; % Angle in deg for the servo on the point (sin(120)*d, cos(120)*d)
qC = 46.8; % Angle in deg for the servo on the point (-sin(120)*d, cos(120)*d)
v = 'v1';

fwd_kin_general(qA, qB, qC, v, 1);

% 30, 38.08, 38.08
% 37.85, 30, 30