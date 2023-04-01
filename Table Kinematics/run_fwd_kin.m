clc; close all; clear;
addpath(fullfile(pwd,'functions'));

qA = 10; % Angle in deg for the servo on the y axis on the point (0, d)
qB = 10; % Angle in deg for the servo on the point (sin(120)*d, cos(120)*d)
qC = 10; % Angle in deg for the servo on the point (-sin(120)*d, cos(120)*d)
v = 'v1';

fwd_kin_general(qA, qB, qC, v, 1);