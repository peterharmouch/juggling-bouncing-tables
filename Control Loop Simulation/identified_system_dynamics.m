function [qA_out, qB_out, qC_out] = identified_system_dynamics(qA_in, qB_in, qC_in, t, Ts, C)

% Numerator and denominator coefficients for the second-order system
num = [-10, 150];
den = [1, 12, 150];

% Create transfer function for the second-order system
G = tf(num, den);

% Discretize the transfer function with Ts sampling time
Gd = c2d(G, Ts, 'zoh');


% Initialize the output variables
qA_out = lsim(C*Gd, qA_in-qA_in(1), t) + qA_in(1);
qB_out = lsim(C*Gd, qB_in-qB_in(1), t) + qB_in(1);
qC_out = lsim(C*Gd, qC_in-qC_in(1), t) + qC_in(1);

% Saturation
qA_out(qA_out<0) = 0;
qB_out(qB_out<0) = 0;
qC_out(qC_out<0) = 0;

qA_out(qA_out>88) = 88;
qB_out(qB_out>88) = 88;
qC_out(qC_out>88) = 88;

qA_out = qA_out';
qB_out = qB_out';
qC_out = qC_out';
end