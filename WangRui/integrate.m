%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     FANUC LRMate200iD/7L Robot Experimentor
% Using starting point coord, tangent info to integrate
%      and get the coord of graspPoint in TSM-RPM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Created by Rui Wang, 08/02/2017       
%  MSC Lab, UC Berkeley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function grippingPoint = integrate(xy, points_test_q, graspPt, LENGTH)
x = xy(1);
y = xy(2);
for i = 1 : graspPt - 1 % e.g. for 1st point on rope, no need to integrate
    x = x + LENGTH * cos(points_test_q(i) / 180 * pi);
    y = y + LENGTH * sin(points_test_q(i) / 180 * pi);
end
grippingPoint = [x, y];
end