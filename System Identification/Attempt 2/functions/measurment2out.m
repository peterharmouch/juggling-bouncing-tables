function [Z, theta_x, theta_y] = measurment2out(height, qx, qy, qz, qw)

    %% Computing outputs from data
    Z = (112.17*height) - 87.531;
    
    theta_x = zeros(size(qx));
    theta_y = zeros(size(qx));
    for i = 1:length(qx)
        quat = [qw(i), qx(i), qy(i), qz(i)];
        euler = rad2deg(quat2eul(quat));
        theta_x(i) = wrapTo90(euler(2));
        theta_y(i) = wrapTo90(euler(3));
    end

end