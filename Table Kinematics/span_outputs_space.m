clc; close all; clear;
addpath(fullfile(pwd,'functions'));


%% Setting the angles of each servo
% Geometry of the table
v = 'v3';
dq = 5; 

% Control inputs
qs = 0:dq:89; % range of input values
num_iterations = length(qs)^3;

% initializing matrix to store outputs
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


%% Plot figure with subplots on the principal plane
figure(1);
% Create a new figure with four subplots
subplot(2,2,1); % Isometric view
subplot(2,2,2); % xy plane
subplot(2,2,3); % xz plane
subplot(2,2,4); % yz plane

% Plot the data in the first subplot
subplot(2,2,1);
scatter3(outputs(:,2), outputs(:,3), outputs(:,1), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);
zlim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_x');
ylabel('theta_y');
zlabel('Z');

% Project the data onto the xy plane and plot it in the second subplot
subplot(2,2,2);
scatter(outputs(:,2), outputs(:,3), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);

xlabel('theta_x');
ylabel('theta_y');

% Project the data onto the xz plane and plot it in the third subplot
subplot(2,2,3);
scatter(outputs(:,2), outputs(:,1), '.');

xlim(range_theta_x + 0.1*(range_theta_x(2)-range_theta_x(1))*[-1, 1]);
ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_x');
ylabel('Z');

% Project the data onto the yz plane and plot it in the fourth subplot
subplot(2,2,4);
scatter(outputs(:,3), outputs(:,1), '.');

xlim(range_theta_y + 0.1*(range_theta_y(2)-range_theta_y(1))*[-1, 1]);
ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);

xlabel('theta_y');
ylabel('Z');


%% Plots to find feasible region
Z_low = 10.5;
Z_high = 12.5;
tx = 10;
ty = 30;
scale = 0.2;

Z_dif = Z_high-Z_low;
tx_low = 0;
tx_high = ty;
tx_dif = tx_high-tx_low;
ty_low = -tx;
ty_high = tx;
ty_dif = ty_high-ty_low;

% create logical indexing vectors for each column
M = outputs;
idx1 = (M(:, 1) >= Z_low) & (M(:, 1) <= Z_high);
idx2 = (M(:, 2) >= tx_low) & (M(:, 2) <= tx_high);
idx3 = (M(:, 3) >= ty_low) & (M(:, 3) <= ty_high);

% combine the indexing vectors into a single logical indexing vector
idx = idx1 & idx2 & idx3;

% use the logical indexing vector to select only the rows that satisfy the conditions
M = M(idx, :);

figure(2);
% create logical indexing vectors for each column
idx1 = (M(:, 1) >= Z_low - (scale*Z_dif)) & (M(:, 1) <= Z_low + (scale*Z_dif));
idx2 = (M(:, 1) >= Z_high - (scale*Z_dif)) & (M(:, 1) <= Z_high + (scale*Z_dif));
idx3 = (M(:, 2) >= tx_low - (scale*tx_dif)) & (M(:, 2) <= tx_low + (scale*tx_dif));
idx4 = (M(:, 2) >= tx_high - (scale*tx_dif)) & (M(:, 2) <= tx_high + (scale*tx_dif));
idx5 = (M(:, 3) >= ty_low - (scale*ty_dif)) & (M(:, 3) <= ty_low + (scale*ty_dif));
idx6 = (M(:, 3) >= ty_high - (scale*ty_dif)) & (M(:, 3) <= ty_high + (scale*ty_dif));

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

