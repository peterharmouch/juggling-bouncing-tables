clc; close all; clear;
addpath(fullfile(pwd,'images'));

% This code prompts us to display an image, manually set the origin and the 
% unit vector on the y axis. It allows us then to choose points on the
% image and know their coordinates. This code can be useful if the
% mechanical design of the table changes and we need to determine
% difference length and angles remotely.

% Read the image
image = imread('table_orientation1.jpg');

% Display the image
imshow(image);

% Prompt the user to set the center point
disp('Set the center point by clicking on it');
center_point = ginput(1);

% Plot the center point
hold on;
plot(center_point(1), center_point(2), 'ro');

% Prompt the user to set the y-axis point
disp('Set the y-axis point by clicking on it');
y_coord = ginput(1);

% Plot the y-axis point
plot(y_coord(1), y_coord(2), 'bx');

% Calculate the x-axis point as an orthonormal axis
y_vector = [y_coord(1) - center_point(1), y_coord(2) - center_point(2)];
x_vector = [-y_vector(2), y_vector(1)];
x_coord = center_point + x_vector;

% Plot the x-axis point
plot(x_coord(1), x_coord(2), 'gx');

% Initialize an empty array to store the points and their names
points = [];
name = [];
j = 0;
% Loop to add points and their names

while true
    j = j+1;
    % Prompt the user to select a point on the image or exit
    prompt = 'Click on a point on the image or type "exit" to finish adding points: ';
    str = input(prompt, 's');
    if strcmp(str, 'exit')
        break;
    end
    
    % Get the point's coordinates and add it to the array
    [point_x, point_y] = ginput(1);
    point_vector = [point_x - center_point(1), point_y - center_point(2)];
    x_projection = dot(point_vector, x_vector) / norm(x_vector)^2;
    y_projection = dot(point_vector, y_vector) / norm(y_vector)^2;
    point_coords = [x_projection, y_projection];
    points = [points; point_coords];
    
    % Prompt the user to enter a name for the point and plot it on the image
    prompt = 'Enter a name for the point: ';
    name = [name; input(prompt, 's')];
    plot(point_x, point_y, 'Marker', 'o', 'MarkerSize', 10, 'LineWidth', 2);
    text(point_x, point_y + 20, name(j), 'FontSize', 12, 'HorizontalAlignment', 'center');
end

% Display the coordinates of each point in the reference frame
disp('Point coordinates in the reference frame:');
for i = 1:size(points, 1)
    disp(['   ' name(i) ' = (' num2str(points(i, 1)) ', ' num2str(points(i, 2)) ')']);
end