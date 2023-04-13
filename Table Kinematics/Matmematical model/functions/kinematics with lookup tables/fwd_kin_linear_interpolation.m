function [z, tx, ty] = fwd_kin_linear_interpolation(QA, QB, QC, lookup_table)
%%
% This function computes the forward kinematics table using a lookup table.
% It does linear interpolation to compute the values that are not in the
% table.
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
z = griddata(qA, qB, qC, Z, QA, QB, QC, method);
tx = griddata(qA, qB, qC, theta_x, QA, QB, QC, method);
ty = griddata(qA, qB, qC, theta_y, QA, QB, QC, method);

end