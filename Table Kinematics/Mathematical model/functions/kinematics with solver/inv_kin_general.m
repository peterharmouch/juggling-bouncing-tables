function [qA, qB, qC] = inv_kin_general(Z, theta_x, theta_y, version)
%%
% This function computes the inverse kinematics of the bouncing table given 
% the desired position and orientation of the end effector. It returns the
% joint angles qA, qB, and qC in degrees that would achieve the desired
% configuration.
%
% Inputs:
%    Z        - Scalar value representing the desired height of the end effector.
%    theta_x  - Scalar value representing the desired angle that the end effector makes with the x-axis.
%    theta_y  - Scalar value representing the desired angle that the end effector makes with the y-axis.
%    version:  - String that specifies the type of geometry to generate. It can be one of the following values:
%                *'v1' (default): the real table.
%                *'v2': the real table with arms pointing towards the origin.
%                *'v3': new design that gives us a larger feasible space.
%                Check the documentation of the generate_geom.m function 
%                for the different geometric dimensions and their meanings.
%
% Outputs:
%    qA       - Scalar value representing the joint angle in degrees.
%    qB       - Scalar value representing the joint angle in degrees.
%    qC       - Scalar value representing the joint angle in degrees.
%
%%
% Computing the joint angles using fsolve
fun = @(x) fwd_kin_general_out(x(1), x(2), x(3), version) - [Z, theta_x, theta_y];
q0 = [10, 10, 10]; % Initial guess for joint angles
options = optimoptions('fsolve', 'Display', 'off');
q = fsolve(fun, q0, options);
qA = q(1);
qB = q(2);
qC = q(3);
end