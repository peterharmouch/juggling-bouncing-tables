clc; close all; clear;
addpath(genpath(fullfile(pwd,'functions')));


%%
% Computing the outputs for all different input combinations in order to
% have an idea about the outputs that can be reached with that table design
%%

%% Generating a matrix containing the feasible space
% The code iterates over all possible values of qA, qB, and qC in the range 
% of 0 to 89 degrees. For each set of input angles, it uses the forward
% kinematics equations to compute the corresponding output values of Z, 
% theta_x, and theta_y and stores them in a matrix.

% Geometry of the table
v = 'v1';
dq = 2; 

% Control inputs
qs = 0:dq:89; % range of input values
num_iterations = length(qs)^3;

% Initializing matrix to store outputs
inputs = zeros(num_iterations, 3);
outputs = zeros(num_iterations, 3);

% Iterating over the inputs to span the space of the outputs
iter = 0;
last_percent_complete = 0;
for i = 1:length(qs)
    for j = 1:length(qs)
        for k = 1:length(qs)
            iter = iter+1;
            qA = qs(i); % Angle for the servo on the y axis on the point (0, d)
            qB = qs(j); % Angle for the servo on the point (sin(120)*d, cos(120)*d)
            qC = qs(k); % Angle for the servo on the point (-sin(120)*d, cos(120)*d)
            
            % Computing forward kinematics
            [z, theta_x, theta_y] = fwd_kin_general(qA, qB, qC, v);

            % Printing progress
            percent_complete = iter / num_iterations * 100;
            if percent_complete > last_percent_complete + 0.1
                disp(['Loop progress: ' num2str(floor(percent_complete*10)/10) '%']);
                last_percent_complete = floor(percent_complete*10)/10;
            end

            % Storing inputs and outputs in matrix
            inputs(iter, :) = [qA, qB, qC];
            outputs(iter, :) = [z, theta_x, theta_y];
        end
    end
end

% Computing range of outputs along each dimension
range_z = [min(outputs(:, 1)), max(outputs(:, 1))];
range_theta_x = [min(outputs(:, 2)), max(outputs(:, 2))];
range_theta_y = [min(outputs(:, 3)), max(outputs(:, 3))];


%% Plotting figure with subplots on the principal plane
% A plot with four subplots displays the computed output values in 
% different projections. The first subplot (Isometric view) shows a 3D 
% scatter plot of the output values in the (theta_x, theta_y, Z) space, 
% while the other three subplots show the projection of the output values
% onto the (theta_x, theta_y), (theta_x, Z), and (theta_y, Z) planes.

figure(1);
sgtitle('Outputs space spanned');
% Creating a new figure with four subplots
subplot(2,2,1); % Isometric view
subplot(2,2,2); % xy plane
subplot(2,2,3); % xz plane
subplot(2,2,4); % yz plane

% Plotting the data in the first subplot
subplot(2,2,1);
scatter3(outputs(:,2), outputs(:,3), outputs(:,1), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);
zlim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_x');
ylabel('theta_y');
zlabel('Z');

% Projecting the data onto the xy plane and plotting it in the second subplot
subplot(2,2,2);
scatter(outputs(:,2), outputs(:,3), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);

xlabel('theta_x');
ylabel('theta_y');

% Projecting the data onto the xz plane and plotting it in the third subplot
subplot(2,2,3);
scatter(outputs(:,2), outputs(:,1), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_x');
ylabel('Z');

% Projecting the data onto the yz plane and plotting it in the fourth subplot
subplot(2,2,4);
scatter(outputs(:,3), outputs(:,1), '.');

xlim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);
ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_y');
ylabel('Z');

%% Plots to see the required feasible region
% We want to find a parallelepipedic region in the output space and 
% identify upper and lower limits of Z and theta_x. The aim of this is to 
% have a range of points where can choose values freely with the certainty
% that there exist inputs that can achieve the outputs in this region.

% To check whether the limits chosen for the parallelepiped describe such 
% a feasible region, the plot displays the output values of all input 
% combinations that lie within the limits in three subplots similar to the
% ones described earlier. If the subplots are completely filled with points 
% and don't have empty regions, it suggests that the limits correctly 
% describe the feasible region of the output space.

% Ideally, we want to maximize the range of heights it can reach.
% Theta_y should range from a negative value to the same positive value, 
% allowing for slight corrections from both sides. 
% Theta_x, on the other hand, should range from 0 to a maximum value, as we 
% only need the table's inclination to be in one direction along that axis.
% This is because the goal is for the table to send a ball forward so we
% will never need a negative inclination with respect to the y-axis.

% Translation: We want to maximize :
%  * (Z_high - Z_low)
%  * theta_y_abs
%  * theta_x_max
% This plot will allow us to see which limits work and which don't

% Warning: if dq is larger than 2, we may not see much on these plots.

% Setting the output points of interest
Z_low = 11;
Z_high = 14;
theta_x_max = 30;
theta_y_abs = 10;

% Change the scale to see more points on the planes (but the planes are
% less accurate)
scale = 0.2;

% Reorganizing the points of interest to facilitate plotting
Z_dif = Z_high-Z_low;
tx_low = 0;             % the theta_x location never needs to be lower than 0
tx_high = theta_x_max;
tx_dif = tx_high-tx_low;
ty_low = -theta_y_abs;
ty_high = theta_y_abs;
ty_dif = ty_high-ty_low;

% Renaming outputs vector
M = outputs;

figure(2);
% Creating logical indexing vectors for each column
idx1 = (M(:, 1) >= Z_low - (scale*Z_dif)) & (M(:, 1) <= Z_low + (scale*Z_dif));
idx2 = (M(:, 1) >= Z_high - (scale*Z_dif)) & (M(:, 1) <= Z_high + (scale*Z_dif));
idx3 = (M(:, 2) >= tx_low - (scale*tx_dif)) & (M(:, 2) <= tx_low + (scale*tx_dif));
idx4 = (M(:, 2) >= tx_high - (scale*tx_dif)) & (M(:, 2) <= tx_high + (scale*tx_dif));
idx5 = (M(:, 3) >= ty_low - (scale*ty_dif)) & (M(:, 3) <= ty_low + (scale*ty_dif));
idx6 = (M(:, 3) >= ty_high - (scale*ty_dif)) & (M(:, 3) <= ty_high + (scale*ty_dif));

% Plotting the planes of interest in subplots

c11 = M(idx1, :);
subplot(3,2,1);
scatter3(c11(:, 2), c11(:, 3), c11(:,1 ), '.');
xlabel('theta_x');
ylabel('theta_y');
xlim([tx_low tx_high])
ylim([ty_low ty_high])
title(['Z = ' num2str(Z_low)]);
view(0,90)

c12 = M(idx2, :);
subplot(3,2,2);
scatter3(c12(:, 2), c12(:, 3), c12(:, 1), '.');
xlabel('theta_x');
ylabel('theta_y');
xlim([tx_low tx_high])
ylim([ty_low ty_high])
title(['Z = ' num2str(Z_high)]);
view(0,90)

c21 = M(idx3, :);
subplot(3,2,3);
scatter3(c21(:, 3), c21(:, 1), c21(:, 2), '.');
xlim([ty_low ty_high])
ylim([Z_low Z_high])
xlabel('theta_y');
ylabel('Z');
title(['theta_x = ' num2str(tx_low)]);
view(0,90)

c22 = M(idx4, :);
subplot(3,2,4);
scatter3(c22(:, 3), c22(:, 1), c22(:, 2), '.');
xlim([ty_low ty_high])
ylim([Z_low Z_high])
xlabel('theta_y');
ylabel('Z');
title(['theta_x = ' num2str(tx_high)]);
view(0,90)

c31 = M(idx5, :);
subplot(3,2,5);
scatter3(c31(:, 2), c31(:, 1), c31(:, 3), '.');
xlim([tx_low tx_high])
ylim([Z_low Z_high])
xlabel('theta_x');
ylabel('Z');
title(['theta_y = ' num2str(ty_low)]);
view(0,90)

c32 = M(idx6, :);
subplot(3,2,6);
scatter3(c32(:, 2), c32(:, 1), c32(:, 3), '.');
xlim([tx_low tx_high])
ylim([Z_low Z_high])
xlabel('theta_x');
ylabel('Z');
title(['theta_y = ' num2str(ty_high)]);
view(0,90)

