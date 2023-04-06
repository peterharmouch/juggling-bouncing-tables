function [q1, q2, q3] = inv_kin(z, tx, ty, lookup_table)
%%
% This function computes the inverse kinematics of the bouncing table given
% the desired end effector height (z), and the angles (tx and ty) that the
% end effector makes with the x and y axes, respectively. It uses a lookup
% table of precomputed joint angles (qA, qB, and qC) and corresponding
% end effector positions (Z, theta_x, and theta_y) to find the joint angles
% that produce the desired end effector position.
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
% q1 - the closest joint angle qA that produces the desired end effector position.
% q2 - the closest joint angle qB that produces the desired end effector position.
% q3 - the closest joint angle qC that produces the desired end effector position.
%
%%
% Extracting the relevant data from the lookup table
Z = lookup_table.Z;
theta_x = lookup_table.theta_x;
theta_y = lookup_table.theta_y;
qA = lookup_table.qA;
qB = lookup_table.qB;
qC = lookup_table.qC;

% Computing the Euclidean distance between the desired position and all entries in the table
dist = sqrt((Z(:) - z).^2 + (theta_x(:) - tx).^2 + (theta_y(:) - ty).^2);

% Finding the index of the entry with the smallest distance
[~, index] = min(dist);

% Getting the corresponding joint angles
q1 = qA(index);
q2 = qB(index);
q3 = qC(index);

end