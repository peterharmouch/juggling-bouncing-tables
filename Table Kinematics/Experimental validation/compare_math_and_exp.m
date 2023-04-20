clc; clear; close all; 
addpath(fullfile(pwd, 'processing', 'functions'));


%% Reading inputs
filename = fullfile(pwd, 'processing', 'input angles', 'exp_kin_inputs.csv');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
data = readtable(filename); 

idx = table2array(data(:, 'pt'));
qA = table2array(data(:, 'qA'));
qB = table2array(data(:, 'qB'));
qC = table2array(data(:, 'qC'));


%% Computing math outputs
Z_math = zeros(length(qA), 1);
tx_math = zeros(length(qA), 1);
ty_math = zeros(length(qA), 1);
for i = 1:length(qA)
    q1 = qA(i);
    q2 = qB(i);
    q3 = qC(i);
    [Z_math(i), tx_math(i), ty_math(i)] = fwd_kin_general(q1, q2, q3);
end


%% Computing experimental outputs
Z_exp = zeros(length(qA), 1);
tx_exp = zeros(length(qA), 1);
ty_exp = zeros(length(qA), 1);
for i = 1:length(qA)
    if i<10
        number = strcat('0', num2str(i));
    else
        number =  num2str(i);
    end
    str = strcat('pt', number, '.csv');
    [Z_exp(i), tx_exp(i), ty_exp(i)] = compute_exp(str);
end

Z_err = mean(abs(Z_math - Z_exp));
tx_err = mean(abs(tx_math - tx_exp));
ty_err = mean(abs(ty_math - ty_exp));


%% Plotting
figure
subplot(3,1,1) % first subplot
plot(idx, Z_math, 'bo-', idx, Z_exp, 'ro-')
xlabel('Point Number')
ylabel('Z')
legend('Math', 'Exp')
title('Z vs Point Number')

subplot(3,1,2) % second subplot
plot(idx, tx_math, 'bo-', idx, tx_exp, 'ro-')
xlabel('Point Number')
ylabel('tx')
legend('Math', 'Exp')
title('theta_x vs Point Number')

subplot(3,1,3) % third subplot
plot(idx, ty_math, 'bo-', idx, ty_exp, 'ro-')
xlabel('Point Number')
ylabel('ty')
legend('Math', 'Exp')
title('theta_y vs Point Number')
