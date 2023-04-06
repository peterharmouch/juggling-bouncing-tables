function geom = generate_geom(type)
%%
% This function generates a structure containing the geometric parameters 
% of a specific type of geometry. The function takes a string argument 
% that specifies the type of geometry and returns a structure with the 
% following fields:
% d:     the distance between a servo and the origin 
%        (d = (distance between servos)/sqrt(3))                    
% L1:    the length of the first arm
% L2:    the length of the second arm
% L3:    the length of a side of the triangle formed by the points of contact
%        between the arms and the table
% R:     the radius of the top plate
% alpha: the angle formed by the two following vectors:
%        - the vector starting on the servo and pointing towards the origin
%        - the vector starting on the servo and pointing towards the arm on the
%          xy plane
% 
% Input Arguments:
% type : a string that specifies the type of geometry to generate. It can be one of the following values:
% 'v1' : the real table.
% 'v2' : old approximation of the table with slightly different dimensions and arms pointing to the origin.
% 'v3' : a new design that gives us a larger feasible space.
%
% Output:
% geom : a structure containing the geometric parameters of the specified type of geometry.
%%
    switch type
        case 'v1'
            geom = struct('d', 9, ...
                'L1', 7, ...
                'L2', 9.6, ...
                'L3', 13.3, ...
                'R', 14, ...
                'alpha', 16);
        case 'v2'
            geom = struct('d', 7.5, ...
                'L1', 7, ...
                'L2', 8.5, ...
                'L3', 13, ...
                'R', 15, ...
                'alpha', 0);
        case 'v3'
            geom = struct('d', 13, ...
                'L1', 12, ...
                'L2', 13, ...
                'L3', 13, ...
                'R', 15, ...
                'alpha', 0);
        otherwise
            error('Unknown geometry type')
    end
end
