function[center] = get_center_coordinates(qA, qB, qC, version, plot_bool)
%%
% This function computes the center of a table using the positions of 
% the three robotic arms on the table.
%
% Inputs:
% qA : angle of the first arm in degrees.
% qB : angle of the second arm in degrees.
% qC : angle of the third arm in degrees.
% plot_bool (logical): boolean to determine if the output should be plotted.
%
% Outputs:
% center : 1x3 array representing the center of the table.
%
%%
    %% Obtaining the tree points of contact between the arms and the table
    if nargin < 4 || (isempty(version) && isempty(plot_bool))
        version = 'v1';
        plot_bool = 0;
    elseif nargin < 5 || isempty(plot_bool)
        plot_bool = 0;
    end    
    
    % Loading geometry
    geom = generate_geom(version);

    d = geom.d;
    L1 = geom.L1;
    L2 = geom.L2;
    L3 = geom.L3;
    alpha = geom.alpha;
    
    % Defining the positions of the 3 motors
    A1 = d*[0, 1, 0];
    B1 = d*[sind(120), cosd(120), 0];
    C1 = d*[-sind(120), cosd(120), 0];
    
    % Computing the positions of the articulations between the two arms
    [A2, B2, C2] = compute_2ndfloor(A1, B1, C1, qA, qB, qC, d, L1, alpha);
       
    % Computing normals to the planes
    ez = [0, 0, 1]; % Unit vector of the z axis
    
    nA = cross(A2 - A1, ez) / norm(cross(A2 - A1, ez));
    nB = cross(B2 - B1, ez) / norm(cross(B2 - B1, ez));
    nC = cross(C2 - C1, ez) / norm(cross(C2 - C1, ez));
    
    % Defining a function to be solved by fsolve, the goal is to compute the 
    % coordinates of the three points of intersection between the table and
    % the arms (the location of the ball and socket for each arm).
    fun = @(x) [
        % The first 3 equations guarantee that the distances between each 
        % point and its previous joint are conserved
        ((x(1)-A2(1))^2 + (x(2)-A2(2))^2 + (x(3)-A2(3))^2) - L2^2;
        ((x(4)-B2(1))^2 + (x(5)-B2(2))^2 + (x(6)-B2(3))^2) - L2^2;
        ((x(7)-C2(1))^2 + (x(8)-C2(2))^2 + (x(9)-C2(3))^2) - L2^2;
        % The second 3 equations guarantee that the distances between the
        % 3 points are conserved
        ((x(1)-x(4))^2 + (x(2)-x(5))^2 + (x(3)-x(6))^2) - L3^2;
        ((x(4)-x(7))^2 + (x(5)-x(8))^2 + (x(6)-x(9))^2) - L3^2;
        ((x(7)-x(1))^2 + (x(8)-x(2))^2 + (x(9)-x(3))^2) - L3^2;
        % The last 3 equations guarantee that the point in on the plane of 
        % the arm
        dot(nA, [x(1)-A1(1), x(2)-A1(2), x(3)-A1(3)]);
        dot(nB, [x(4)-B1(1), x(5)-B1(2), x(6)-B1(3)]);
        dot(nC, [x(7)-C1(1), x(8)-C1(2), x(9)-C1(3)])
    ];
    
    % Solving the system of equations using fsolve
    x0 = [0, L1, L1+L2, L1*B1(1), L1*B1(2), L1+L2, L1*C1(1), L1*C1(2), L1+L2];
    options = optimoptions('fsolve', 'Display', 'off');
    x = fsolve(fun, x0, options);
    
    % Accessing the three points of intersection between the table and the arms
    A3 = x(1:3);
    B3 = x(4:6);
    C3 = x(7:9);
    
    % Computing the geometric center of the table
    center = 1/3*[A3(1)+B3(1)+C3(1), A3(2)+B3(2)+C3(2), A3(3)+B3(3)+C3(3)];
    
            
    %% Plotting the results
    if plot_bool
        scatter3(center(1), center(2), center(3), 'filled');
        hold on;
        
        % Adding axis labels and title
        daspect([1 1 1]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');       
    end

end