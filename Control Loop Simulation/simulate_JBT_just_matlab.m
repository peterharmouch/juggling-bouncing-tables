clc; clear; close all;
addpath(genpath(fullfile(pwd, '..', 'Table Kinematics', 'Mathematical model', 'lookup tables')));
addpath(genpath(fullfile(pwd, '..', 'Table Kinematics', 'Mathematical model', 'functions')));


%% Choose parameters
tic;
Ts = 0.01; % Sampling time
t_end = 5; % Total duration

trajectoryType = "Z step"; % Check next section for options
dynamicsType = "identified"; % Choose between "identified" or "no dynamics"
kinematicsMethod = "nearest"; % Choose between "interpolation" or "nearest" or "solver"
controller = "PID"; % Choose between "PID" or "no control"

switch kinematicsMethod
    case "interpolation"
        LT = load("lookup_table_v1_dq2.mat");
    case "nearest"
        LT = load("lookup_table_v1_dq1.mat");
end


%% Defining trajectories to be tracked
t = 0:Ts:t_end;
switch trajectoryType
    case "Z step"
        t_jump = 1;
        t1 = 0:Ts:t_jump;
        t2 = (1+Ts):Ts:t_end;
        Z_in = [14 * ones(1, length(t1)), 15 * ones(1, length(t2))];
        tx_in = [0 * ones(1, length(t1)), 0 * ones(1, length(t2))];
        ty_in = [0 * ones(1, length(t1)), 0 * ones(1, length(t2))];
    case "Z and theta_y step"
        t_jump = 1;
        t1 = 0:Ts:t_jump;
        t2 = (1+Ts):Ts:t_end;
        Z_in = [15 * ones(1, length(t1)), 12 * ones(1, length(t2))];
        tx_in = [10 * ones(1, length(t1)), 10 * ones(1, length(t2))];
        ty_in = [-5 * ones(1, length(t1)), 5 * ones(1, length(t2))];
    case "Z ramp"
        Z_in = linspace(12, 15, floor(length(t)));
        tx_in = linspace(10, 10, length(t));
        ty_in = linspace(-5 ,-5, length(t));
    case "Z and theta_y ramp"
        Z_in = [linspace(15, 12, floor(length(t)/2)), 12, linspace(12, 15, floor(length(t)/2))];
        tx_in = linspace(0, 0, length(t));
        ty_in = linspace(0 ,0, length(t));
end


%% Inverse kinematics
switch kinematicsMethod
    case "interpolation"
        [qA_in, qB_in, qC_in] = inv_kin_linear_interpolation(Z_in, tx_in, ty_in, LT);
    case "nearest"
        [qA_in, qB_in, qC_in] = inv_kin_nearest(Z_in, tx_in, ty_in, LT);
    case "solver"
        qA_in = zeros(size(Z_in)); qB_in = zeros(size(Z_in)); qC_in = zeros(size(Z_in));
        for i = 1: length(Z_in)
            [qA_in(i), qB_in(i), qC_in(i)] = inv_kin_general(Z_in(i), tx_in(i), ty_in(i), 'v1');
        end
end


%% Controller
switch controller
    case "PID"
        Kp = 1;
        Ki = 0.02;
        Kd = 0.02;
        Tf = 0;
        C = pid(Kp,Ki,Kd,Tf,Ts);
    case "no control"
        C = 1;
end


%% System dynamics
switch dynamicsType
    case "identified"
        [qA_out, qB_out, qC_out] = identified_system_dynamics(qA_in, qB_in, qC_in, t, Ts, C);      
    case "no dynamics"
        qA_out = qA_in;
        qB_out = qB_in;
        qC_out = qC_in;
end


%% Forward kinematics
switch kinematicsMethod
    case "interpolation"
        [Z_out, tx_out, ty_out] = fwd_kin_linear_interpolation(qA_out, qB_out, qC_out, LT);
    case "nearest"
        [Z_out, tx_out, ty_out] = fwd_kin_nearest(qA_out, qB_out, qC_out, LT);
    case "solver"
        Z_out = zeros(size(Z_in)); tx_out = zeros(size(Z_in)); ty_out = zeros(size(Z_in));
        for i = 1:length(Z_in)
            [Z_out(i), tx_out(i), ty_out(i)] = fwd_kin_general(qA_out(i), qB_out(i), qC_out(i), 'v1'); 
        end
end


%% Plot output tracking
figure(1);
% Plot in the first subplot
subplot(3,1,1);
plot(t, Z_in);
hold on;
stairs(t, Z_out);
title('Z');
xlabel('Time');
ylabel('Z');
legend('Z_{in}', 'Z_{out}');

% Plot in the second subplot
subplot(3,1,2);
plot(t, tx_in);
hold on;
stairs(t, tx_out);
title('theta_x');
xlabel('Time');
ylabel('theta_x');
legend('theta_{x_{in}}', 'theta_{x_{out}}');

% Plot in the third subplot
subplot(3,1,3);
plot(t, ty_in);
hold on;
stairs(t, ty_out);
title('theta_y');
xlabel('Time');
ylabel('theta_y');
legend('theta_{y_{in}}', 'theta_{y_{out}}');

% Adjust the layout of subplots
sgtitle('Tracking outputs');


%% Plot input tracking
figure(2);
% Plot in the first subplot
subplot(3,1,1);
plot(t, qA_in);
hold on;
stairs(t, qA_out);
title('qA');
xlabel('Time');
ylabel('qA');
legend('qA_{in}', 'qA_{out}');

% Plot in the second subplot
subplot(3,1,2);
plot(t, qB_in);
hold on;
stairs(t, qB_out);
title('qB');
xlabel('Time');
ylabel('qB');
legend('qB_{in}', 'qB_{out}');

% Plot in the third subplot
subplot(3,1,3);
plot(t, qC_in);
hold on;
stairs(t, qC_out);
title('qC');
xlabel('Time');
ylabel('qC');
legend('qC_{in}', 'qC_{out}');

% Adjust the layout of subplots
sgtitle('Tracking servo angles');


%% Plot input to be tracked
figure(3);
% Plot in the first subplot
subplot(3,1,1);
plot(t, Z_in);
title('Z');
xlabel('Time');
ylabel('Z');
legend('Z_{in}');

% Plot in the second subplot
subplot(3,1,2);
plot(t, tx_in);
title('theta_x');
xlabel('Time');
ylabel('theta_x');
legend('theta_{x_{in}}');

% Plot in the third subplot
subplot(3,1,3);
plot(t, ty_in);
title('theta_y');
xlabel('Time');
ylabel('theta_y');
legend('theta_{y_{in}}');

% Adjust the layout of subplots
sgtitle('To be tracked');

toc
