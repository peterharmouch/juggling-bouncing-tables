clc; close all; clear;
addpath(fullfile(pwd,'functions'));


%% Run this code to fill in a lookup table
% Lookup tables are used to perform inverse kinematics

% Defining the inputs
v = 'v3'; % Geometry of the table
dq = 20;  % Discretization

% Defining the joint angle ranges
q_min = 0;
q_max = 85;

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

% Name the table based on the geometry version and the discretization
name = strcat('lookup_table_', v, '_dq', num2str(dq), '.mat');

% Saving the data to the file
filename = fullfile('lookup tables', name);
save(filename, 'qA', 'qB', 'qC', 'Z', 'theta_x', 'theta_y');

