function angle = wrapTo90(angleInDegrees)
% Wrap angle in degrees to [-90 90)

angle = mod(angleInDegrees, 360);
if angle >= 270
    angle = angle - 360;
elseif angle < -90
    angle = angle + 360;
end

if angle >= 90
    angle = angle - 180;
elseif angle < -90
    angle = angle + 180;
end
end