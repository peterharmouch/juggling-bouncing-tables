function [Z, theta_x, theta_y] = compute_exp(str)
%%
% This function takes a csv file storing a recording of one stabilized
% state of the table and deduces from that file the Z, theta_x and theta_y
% coordinated of the table at that point
%%

    %% Selecting the filename and extracting the file number
    filename = fullfile('..', 'csv files', str);
    num = str2double(strcat(str(3), str(4)));
    
    
    %% Extracting data
    % Disabling warning messages
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    
    % Reading the CSV file
    data = readtable(filename); 
    
    % Extracting values
    values = table2array(data(:, 'value'));
    values = reshape(values, length(values)/5, []);
    values = mean(values, 1);
    
    
    %% Computing outputs from data
    Z = values(1);
    Z = (112.17*Z) - 87.531;
    if num < 12 % Compensating for the different calibration on the 2nd day
        Z = Z+0.3347;
    end
    
    quat = [values(5), values(2:4)];
    euler = rad2deg(quat2eul(quat));
    theta_x = wrapTo90(euler(2));
    theta_y = wrapTo90(euler(3));


end