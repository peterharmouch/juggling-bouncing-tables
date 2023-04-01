clc; clear; close all;


%% set the variable to choose the correct file
delay_type = "delay100"; % change this to the desired delay type

% Choosing the filename and setting some parameters based on the delay type
filename = fullfile(pwd, 'csv files', delay_type);
switch delay_type
    case "delay100"
        t_start = 4.9;
        t_end = 14.9;
        thresh_coef = 0.5;
        t_reaction = 5.71;
        t_input = 5.74;
    case "delay75"
        t_start = 1.5;
        t_end = 11.5;
        thresh_coef = 0.5;
        t_reaction = 3;
        t_input = 3.035;
    case "delay50"
        t_start = 3;
        t_end = 13;
        thresh_coef = 0.4;
        t_reaction = 8.31;
        t_input = 8.341;
    case "delayMix"
        t_start = 4.7;
        t_end = 14.7;
        thresh_coef = 0.4;
        t_reaction = 8.3;
        t_input = 8.345;
    otherwise
        error("Invalid delay type");
end


%% Extracting data
% Disabling warning messages
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

% Reading the CSV file
data = readtable(filename);  

% Extracting the "elapsedTime" and "value" columns as MATLAB arrays
% "elapsedTime": The elapsed time from the beginning of the recording
% "value": The value of the Z coordinate of the rigid body
time = table2array(data(:, 'elapsedTime'));
Z = table2array(data(:, 'value'));

% Extracting the rows in the desired time interval
idx = (time >= t_start) & (time <= t_end);
time = time(idx);
Z = Z(idx);


%% Simulating PRBS input sequence

% I didn't record the input that was given, and I'm not sure about the best
% way to capture it correctly. Therefore, I will simulate a potential input
% for the known output

% Estimating the positions of the 1s and constructing a vector of 1s and 0s
threshold = thresh_coef * (max(Z) - min(Z));
one_locs = find(Z > threshold + min(Z));
prbs_input = zeros(size(Z));
prbs_input(one_locs) = 1;

% Adding some fake delay for causality
idx_delay = sum((time >= t_reaction) & (time <= t_input));
prbs_input = prbs_input(idx_delay+1:end);

% Create a new array to store the modified values
input = zeros(size(prbs_input));

% Replace each 0 with 0.882 and each 1 with 0.097
input(prbs_input == 0) = 0.88187;
input(prbs_input == 1) = 0.897;

% Cutting the time and Z arrays
time = time(1:end-idx_delay);
Z = Z(1:end-idx_delay);


%% Plotting input and output for visualization
% Points of interest for plotting
z1 = 0.88187;
z2 = 0.897231;
y1 = 0;
y2 = 1;
buffer = 0.25;

% Plotting Z and input with different scales
figure(1);
plot(time, Z)
ylabel('Z')
ylim([z1-buffer*(z2-z1), z2+buffer*(z2-z1)]) % Set the limits of the z-axis with a buffer
hold on
plot(time, input)

%% System identification and bode plot
% Computing average sampling time:
Ts = mean(time(2:end) - time(1:end-1));

% Importing data into an iddata object
data = iddata(Z, input, Ts);
data = detrend(data);

% Identifying the system and plotting the non-parametric Bode plot
figure(2);
sys_np = spa(data);
bode(sys_np);
grid on;
xlim([1e-1, 1e3]);
title('Non-parametric Bode plot');

% Identifying the system and plotting the parametric Bode plot
figure(3);
sys_p = tfest(data, 2);
bode(sys_p);
grid on;
xlim([1e-1, 1e3]);
title('Parametric Bode plot');


%% Fourrier transform
% Computing the Fourier transform of Z
Z = Z - mean(Z);
fft_Z = fft(Z);

% Computing the frequency axis
N = length(Z);
f = (0:N-1) / (N * Ts);

% Plotting the Fourier transform
figure(4)
plot(f, abs(fft_Z));
xlabel('Frequency (Hz)');
ylabel('Magnitude');

