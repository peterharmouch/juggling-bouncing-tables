clc; close all; clear;
addpath(fullfile(pwd,'functions'));


%% Setting the angles of each servo
% Geometry of the table
v = 'v1';

% Control inputs
qs = 0:10:89; % range of input values
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
            center = get_center_coordinates(qA, qB, qC, v);

            % Printing progress
            percent_complete = iter / num_iterations * 100;
            if percent_complete > last_percent_complete + 1
                disp(['Loop progress: ' num2str(floor(percent_complete)) '%']);
                last_percent_complete = floor(percent_complete);
            end

            % Storing inputs and outputs in matrix
            inputs(iter, :) = [qA, qB, qC];
            outputs(iter, :) = center;
        end
    end
end

% Computing range of outputs along each dimension
range_x = [min(outputs(:, 1)), max(outputs(:, 1))];
range_y = [min(outputs(:, 2)), max(outputs(:, 2))];
range_z = [min(outputs(:, 3)), max(outputs(:, 3))];


%% Plot figure with subplots on the principal plane
figure;
% Create a new figure with four subplots
subplot(2,2,1); % Isometric view
subplot(2,2,2); % xy plane
subplot(2,2,3); % xz plane
subplot(2,2,4); % yz plane

% Plot the data in the first subplot
subplot(2,2,1);
scatter3(outputs(:,1), outputs(:,2), outputs(:,3), '.');

zlim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);
ylim(range_y + 0.1*(range_y(2)-range_y(1))*[-1, 1]);
xlim(range_x + 0.1*(range_x(2)-range_x(1))*[-1, 1]);

daspect([1 1 1]);
xlabel('X');
ylabel('Y');
zlabel('Z');

% Project the data onto the xy plane and plot it in the second subplot
subplot(2,2,2);
scatter(outputs(:,1), outputs(:,2), '.');

xlim(range_x + 0.1*(range_x(2)-range_x(1))*[-1, 1]);
ylim(range_y + 0.1*(range_y(2)-range_y(1))*[-1, 1]);

xlabel('X');
ylabel('Y');

% Project the data onto the xz plane and plot it in the third subplot
subplot(2,2,3);
scatter(outputs(:,1), outputs(:,3), '.');

ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);
xlim(range_x + 0.1*(range_x(2)-range_x(1))*[-1, 1]);

xlabel('X');
ylabel('Z');

% Project the data onto the yz plane and plot it in the fourth subplot
subplot(2,2,4);
scatter(outputs(:,2), outputs(:,3), '.');

ylim(range_z + 0.1*(range_z(2)-range_z(1))*[-1, 1]);
xlim(range_y + 0.1*(range_y(2)-range_y(1))*[-1, 1]);

xlabel('Y');
ylabel('Z');

