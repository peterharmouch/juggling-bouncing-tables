function [z, tx, ty] = fwd_kin_nearest(q1, q2, q3, lookup_table)
%%
% This function computes the forward kinematics table using a lookup table.
% It doesn't do interpolation, it simply selects the value nearest to that
% of the requested value
%%
% Extracting the relevant data from the lookup table
Z = lookup_table.Z;
theta_x = lookup_table.theta_x;
theta_y = lookup_table.theta_y;
qA = lookup_table.qA;
qB = lookup_table.qB;
qC = lookup_table.qC;

% Computing the Euclidean distance between the desired position and all entries in the table
dist = sqrt((qA(:) - q1).^2 + (qB(:) - q2).^2 + (qC(:) - q3).^2);

% Finding the index of the entry with the smallest distance
[~, index] = min(dist);

% Getting the corresponding joint angles
z = Z(index);
tx = theta_x(index);
ty = theta_y(index);

end