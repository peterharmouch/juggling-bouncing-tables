function [q1, q2, q3] = inv_kin_linear_interpolation(z, tx, ty, lookup_table)
%%
% This function computes the inverse kinematics of the bouncing table given
% the desired end effector height (z), and the angles (tx and ty) that the
% end effector makes with the x and y axes, respectively. It uses a lookup
% table of precomputed joint angles (qA, qB, and qC) and corresponding
% end effector positions (Z, theta_x, and theta_y) and performs 
% interpolation to find the joint angles that produce the desired end 
% effector position.
%
% Inputs:
% z - Scalar value representing the desired height of the end effector.
% tx - Scalar value representing the desired angle that the end effector makes with the x-axis.
% ty - Scalar value representing the desired angle that the end effector makes with the y-axis.
% lookup_table - A structure containing the precomputed joint angles 
% (qA, qB, and qC) and corresponding end effector positions 
% (Z, theta_x, and theta_y).
%
% Outputs:
% q1 - Interpolated joint angle qA that produces the desired end effector position.
% q2 - Interpolated joint angle qB that produces the desired end effector position.
% q3 - Interpolated joint angle qC that produces the desired end effector position.
%
%%
method = "linear";
% Extracting the relevant data from the lookup table
Z = lookup_table.Z;
theta_x = lookup_table.theta_x;
theta_y = lookup_table.theta_y;
qA = lookup_table.qA;
qB = lookup_table.qB;
qC = lookup_table.qC;

% Interpolating the joint angles at the desired position using the lookup table
q1 = griddata(Z, theta_x, theta_y, qA, z, tx, ty, method);
q2 = griddata(Z, theta_x, theta_y, qB, z, tx, ty, method);
q3 = griddata(Z, theta_x, theta_y, qC, z, tx, ty, method);

end