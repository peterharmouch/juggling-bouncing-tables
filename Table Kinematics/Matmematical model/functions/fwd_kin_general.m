function[Z, theta_x, theta_y] = fwd_kin_general(qA, qB, qC, version, draw)
%%
% This function computes the forward kinematics of the bouncing table given 
% the joint angles qA, qB, and qC in degrees. It returns the height of the 
% end effector (Z), and the angles (theta_x and theta_y) that the end 
% effector makes with the x and y axes, respectively. It can also
% optionally display a plot of the table's end effector based on the user's 
% input.
%
% Inputs:
%    qA        - Scalar value representing the joint angle in degrees.
%    qB        - Scalar value representing the joint angle in degrees.
%    qC        - Scalar value representing the joint angle in degrees.
%    version:  - String that specifies the type of geometry to generate. It can be one of the following values:
%                *'v1' (default): the real table.
%                *'v2': the real table with arms pointing towards the origin.
%                *'v3': new design that gives us a larger feasible space.
%                Check the documentation of the generate_geom.m function 
%                for the different geometric dimensions and their meanings.
%    draw      - Optional scalar value representing the type of plot to be displayed.
%                * 0 (default): No plot will be displayed.
%                * 1: The top plate will be displayed.
%                * 3: A triangle will be displayed.
%                * 4: A rectangle will be displayed.
%
% Outputs:
%    Z        - Scalar value representing the height of the end effector.
%    theta_x  - Scalar value representing the angle that the end effector makes with the x-axis.
%    theta_y  - Scalar value representing the angle that the end effector makes with the y-axis.
%
%%
    %% Obtaining the tree points of contact between the arms and the table
    if nargin < 4 || (isempty(version) && isempty(draw))
        version = 'v1';
        draw = 0;
    elseif nargin < 5 || isempty(draw)
        draw = 0;
    end    
    
    % Loading geometry
    geom = generate_geom(version);
    d = geom.d;
    L1 = geom.L1;
    L2 = geom.L2;
    L3 = geom.L3;
    R = geom.R;
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


    %% Computing points of interest to compute the outputs and for plotting
    % Computing the geometric center of the table
    center = 1/3*[A3(1)+B3(1)+C3(1), A3(2)+B3(2)+C3(2), A3(3)+B3(3)+C3(3)];
    
    % Generating points to facilitate the computation of theta_y and to draw
    % a rectangle on the plane of the top plate
    CB = C3 - B3;
    rectB = A3 + 0.5*(CB);
    rectC = A3 - 0.5*(CB);
    
    % Computing the coefficients of the plane of the top plate
    AB = B3 - A3;
    AC = C3 - A3;
    N = cross(AB, AC);
    A = N(1);
    B = N(2);
    C = N(3);
    D = -dot(N, A3);
    
    % Defining the height z of the plane in terms of x and y
    z = @(x, y) (-A*x - B*y - D) / C;
    
    % Generating points to draw the top plate of the circle
    theta = linspace(0,360,100);
    xx = R*cosd(theta);
    yy = R*sind(theta);
    zz = z(xx, yy);


    %% Computing the outputs
    % Z is the height of the center of the table
    Z = center(3);
    
    % theta_x is the angle of inclination around the x axis
    theta_x = wrapTo90(atan2d((B3(3)-C3(3)),(B3(1)-C3(1))));
    
    % theta_y is the angle of inclination around the x axis
    theta_y = wrapTo90(atan2d((rectB(3)-C3(3)),(rectB(1)-B3(1))));

        
    %% Plotting the results
    if draw > 0
        % Plotting the points
        scatter3([A3(1), A2(1), A1(1)], [A3(2), A2(2), A1(2)], [A3(3), A2(3), A1(3)], 'filled');
        hold on;
        scatter3([B3(1), B2(1), B1(1)], [B3(2), B2(2), B1(2)], [B3(3), B2(3), B1(3)], 'filled');
        scatter3([C3(1), C2(1), C1(1)], [C3(2), C2(2), C1(2)], [C3(3), C2(3), C1(3)], 'filled');
        scatter3(center(1), center(2), center(3), 'filled');
        
        % Drawing the arms
        plot3([A3(1), A2(1), A1(1)], [A3(2), A2(2), A1(2)], [A3(3), A2(3), A1(3)], 'LineWidth', 2);
        plot3([B3(1), B2(1), B1(1)], [B3(2), B2(2), B1(2)], [B3(3), B2(3), B1(3)], 'LineWidth', 2);
        plot3([C3(1), C2(1), C1(1)], [C3(2), C2(2), C1(2)], [C3(3), C2(3), C1(3)], 'LineWidth', 2);
        
        if draw == 1
            % Drawing the top plate the table
            plot3(xx, yy, zz, 'r', 'LineWidth', 2);
            fill3(xx, yy, zz, 'r', 'FaceAlpha', 0.2);
        
        elseif draw == 3
            % Drawing the triangle formed by the three points of contact
            plot3([A3(1), B3(1), C3(1), A3(1)], [A3(2), B3(2), C3(2), A3(2)], [A3(3), B3(3), C3(3), A3(3)], 'b', 'LineWidth', 2);
            fill3([A3(1), B3(1), C3(1), A3(1)], [A3(2), B3(2), C3(2), A3(2)], [A3(3), B3(3), C3(3), A3(3)], 'b', 'FaceAlpha', 0.2);
        
        elseif draw == 4
            % Drawing a rectangle on top of the table
            scatter3(rectB(1), rectB(2), rectB(3), 'filled');
            scatter3(rectC(1), rectC(2), rectC(3), 'filled');
            plot3([B3(1), C3(1), rectB(1), rectC(1), B3(1)], [B3(2), C3(2), rectB(2), rectC(2), B3(2)], [B3(3), C3(3), rectB(3), rectC(3), B3(3)], 'g', 'LineWidth', 2);
            fill3([B3(1), C3(1), rectB(1), rectC(1), B3(1)], [B3(2), C3(2), rectB(2), rectC(2), B3(2)], [B3(3), C3(3), rectB(3), rectC(3), B3(3)], 'g', 'FaceAlpha', 0.2);
        end
        
        % Adding axis labels and title
        daspect([1 1 1]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        title(['Bouncing Table: qA = ' num2str(qA) ', qB = ' num2str(qB) ', qC = ' num2str(qC)]);
        
        % Adding text box with the outputs
        dim = [0.73 0.6 0.7 0.1];
        str = {['Z = ' num2str(round(Z, 2)) ' cm'], ['\theta_x = ' num2str(round(theta_x, 2)) '°'], ['\theta_y = ' num2str(round(theta_y, 2)) '°']};
        annotation('textbox',dim,'String',str,'FitBoxToText','on','Margin',10,'FontWeight','bold','FontSize',14,'EdgeColor','k','BackgroundColor',[1 1 1],'FaceAlpha',1);
    end


end