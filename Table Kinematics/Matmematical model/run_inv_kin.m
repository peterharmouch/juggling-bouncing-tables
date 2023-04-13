clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));
addpath(fullfile(pwd,'lookup tables'));


%%
% This code allows us to define output trajectories and run the inverse
% kinematics of the table

% Geometry of the table
v = 'v1';

% Loading the lookup table from file
lookup_table = load(strcat('lookup_table_', v, '_dq2.mat'));

% Choosing which trajectory to visualize
trajectory_type = 'constant angles';
%trajectory_type = 'constant z';
%trajectory_type = 'angle back and forth';
%trajectory_type = 'combined';

% Defining the desired end-effector trajectory based on the chosen type
num_points = 100;
time_steps = 0:num_points-1;
switch trajectory_type
    case 'constant angles'
        z_positions = linspace(10, 13, num_points);
        x_rotations = 12 * ones(1, num_points);
        y_rotations = 0 * ones(1, num_points);
    case 'constant z'
        z_positions = 10 * ones(1, num_points);
        x_rotations = linspace(10, -10, num_points);
        y_rotations = linspace(-10, 10, num_points);
    case 'angle back and forth'
        z_positions = 10 * ones(1, num_points);
        x_rotations = [linspace(10, -10, num_points/2) linspace(-10, 10, num_points/2)];
        y_rotations = zeros(1, num_points);
    case 'combined'
        z_positions = linspace(8, 12, num_points);
        x_rotations = 7 * sind(linspace(-90, 90, num_points));
        y_rotations = [linspace(10, -10, num_points/2) linspace(-10, 10, num_points/2)];
end

% Computing the joint angles
[joint_angle_A, joint_angle_B, joint_angle_C] = inv_kin_linear_interpolation(z_positions, x_rotations, y_rotations, lookup_table);

% Plotting the joint angles
figure(1)
plot(time_steps, joint_angle_A)
hold on
plot(time_steps, joint_angle_B)
plot(time_steps, joint_angle_C)
legend('qA', 'qB', 'qC')

% Initializing arrays
z_positions_ee = zeros(1, num_points);
x_rotations_ee = zeros(1, num_points);
y_rotations_ee = zeros(1, num_points);

% Using the forward kinematics function to verify the performance of the
% inverse kinematics function
for i = 1:num_points
    q1 = joint_angle_A(i);
    q2 = joint_angle_B(i);
    q3 = joint_angle_C(i);
    [z_ee, x_rot_ee, y_rot_ee] = fwd_kin_general(q1, q2, q3, v);
    z_positions_ee(i) = z_ee;
    x_rotations_ee(i) = x_rot_ee;
    y_rotations_ee(i) = y_rot_ee;
end

% Plotting the end-effector trajectory
figure(2)
plot(time_steps, z_positions_ee)
hold on
plot(time_steps, x_rotations_ee)
plot(time_steps, y_rotations_ee)
legend('Z Position', 'X Rotation', 'Y Rotation')

