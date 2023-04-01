clc; close all; clear;
addpath(fullfile(pwd,'functions'));

% Geometry of the table
v = 'v3';

% Defining the joint angle ranges and discretization step
q_min = 0;
q_max = 85;
dq = 10;

% Creating a grid of all possible joint angle combinations
[qA, qB, qC] = meshgrid(q_min:dq:q_max);

% Initializing arrays
Z = zeros(size(qA));
theta_x = zeros(size(qA));
theta_y = zeros(size(qA));

% Computing the end-effector positions for each joint angle combination
iter = 0;
last_percent_complete = 0;
for i = 1:numel(qA)
    [Z(i), theta_x(i), theta_y(i)] = fwd_kin_general(qA(i), qB(i), qC(i), v);
    
    % Printing progress
    iter = iter + 1;
    percent_complete = (iter / length(qA)^3) * 100;
    if percent_complete > last_percent_complete + 0.1
        disp(['Loop progress: ' num2str(floor(percent_complete*10)/10) '%']);
        last_percent_complete = floor(percent_complete*10)/10;
    end
end

% Saving the data to the file
filename = fullfile('lookup tables', strcat('lookup_table_', v, '_dq', num2str(dq), '.mat'));
save(filename, 'qA', 'qB', 'qC', 'Z', 'theta_x', 'theta_y');

