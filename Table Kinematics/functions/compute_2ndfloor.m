function [a7, b7, c7] = compute_2ndfloor(A1, B1, C1, qA, qB, qC, d, L1, theta)

a1 = A1(1:2);
b1 = B1(1:2);
c1 = C1(1:2);

a2 = ((d - L1)/ d) * a1;
b2 = ((d - L1)/ d) * b1;
c2 = ((d - L1)/ d) * c1;

a3 = a1 + ([cosd(theta), -sind(theta); sind(theta), cosd(theta)]*(a2 - a1)')';
b3 = b1 + ([cosd(theta), -sind(theta); sind(theta), cosd(theta)]*(b2 - b1)')';
c3 = c1 + ([cosd(theta), -sind(theta); sind(theta), cosd(theta)]*(c2 - c1)')';

a4 = [a3, 0];
b4 = [b3, 0];
c4 = [c3, 0];

a5 = [a1, 0];
b5 = [b1, 0];
c5 = [c1, 0];

a8 = a3 - a1;
b8 = b3 - b1;
c8 = c3 - c1;

av = -[-a8(2), a8(1), 0];
bv = -[-b8(2), b8(1), 0];
cv = -[-c8(2), c8(1), 0];

a6 = rotate_3D(a4' - a5', 'any', qA, av', 'degree');
b6 = rotate_3D(b4' - b5', 'any', qB, bv', 'degree');
c6 = rotate_3D(c4' - c5', 'any', qC, cv', 'degree');

a7 = a5 + L1 * normalize(a6');
b7 = b5 + L1 * normalize(b6');
c7 = c5 + L1 * normalize(c6');
end