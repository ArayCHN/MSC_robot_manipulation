%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     FANUC LRMate200iD/7L Robot Experimentor
%  Find the closest grasping node on rope for TSM-RPM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Created by Rui Wang, 08/03/2017       
%  MSC Lab, UC Berkeley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [closestPts, ManOrNot, picIdx, stepBegin] = FindClosestPts(LTT_Data_Train, WarpIndex, points_W) % points_W is an array of rope pics

% set grip state representatives
gripKeep  = [0 0 0 0 0 1]; % under this state, the grip does not change
gripClose = [3 0 0 1 0 1]; % under this state, the grip closes
gripOpen  = [0 0 0 1 0 1]; % under this state, the grip opens

totalSteps = size(LTT_Data_Train.GrpCmd{1}, 1);
% define rope and gripper status in each step
for idx = WarpIndex
    [~, GripCloseSteps] = ismember(gripClose, LTT_Data_Train.GrpCmd{idx}, 'rows'); % find steps where gripper closes
    [~, GripOpenSteps] = ismember(gripOpen, LTT_Data_Train.GrpCmd{idx}, 'rows'); % find steps where gripper opens
    grpState = 0; % gripper is open(0) by default; 0: the gripper clenches
    cnt = 0; % counting the index of the pic of the current rope
    picIdx = []; % stores the index of the pic of the current rope
    % scan through all steps and get robot motion states!
    for step = 1 : totalSteps
        if ismember(step, GripCloseSteps) % if gripper closes at this step
            grpState = 1;
            cnt = cnt + 1;
        end
        if ismember(step, GripOpenSteps) % gripper opens
            grpState = 0;
            cnt = cnt + 1;
        end
        picIdx(step) = cnt; % which pic should be followed, if is grasping
        gripOrNot{idx}(step) = grpState; % if == 1, the gripper is closed
        if step > 1 && norm(LTT_Data_Train.TCP_xyzwpr_W{idx}(step, 1:2) - LTT_Data_Train.TCP_xyzwpr_W{idx}(step - 1, 1:2)) < 50 ...
            || idx == 1 && step == 1 && norm(LTT_Data_Train.TCP_xyzwpr_W{idx}(step, 1:2) - [680, 635]) < 10 ...
            || idx == 2 && step == 1 && norm(LTT_Data_Train.TCP_xyzwpr_W{idx}(step, 1:2) - [680, -637]) < 10
            % if the robot is not moving at all
            % Note: only applicable for robots of current state!
            MvOrNot{idx}(step) = 0;
        else
            MvOrNot{idx}(step) = 1;
        end
    end
    ManOrNot{idx} = 0; % all steps default to zero | if == 1, the robot is manipulating the rope, i.e. grasping & moving it
    for step = 1 : totalSteps
        if MvOrNot{idx}(step) == 1 && gripOrNot{idx}(step) == 1 % is gripping and moving rope
            ManOrNot{idx}(step) = 1;
        elseif MvOrNot{idx}(step) == 1 && gripOrNot{idx}(step) == 0 % is moving to a target node
            ManOrNot{idx}(step) = -1;
        else ManOrNot{idx}(step) = 0; % not moving
        end
    end
    % If ManOrNot{idx}(step) == 1, the (x, y) coord of gripper should be
    % calculated by warping in tangent space & integration
end

% find the training rope pic for each step
totalSteps = size(LTT_Data_Train.GrpCmd{1}, 1);
picIdx = ones(totalSteps, 1);
picCnt = 1; % counting which pic of rope is the curr rope
stepBegin(picCnt) = 1;
for step = 1 : totalSteps
    if ManOrNot{1}(step) == 1 || ManOrNot{2}(step) == 1
        picCnt = picCnt + 1;
        stepBegin(picCnt) = step + 1;
    end
    picIdx(step) = picCnt;
end

closestPts = {zeros(totalSteps, 1), zeros(totalSteps, 1)};
for idx = WarpIndex
    % now find point on training rope closest to gripping point
    for step = 1 : totalSteps
        closestPts{idx}(step, :) = dsearchn(points_W{picIdx(step)}(:, 1:2)*1000, ...
        LTT_Data_Train.TCP_xyzwpr_W{idx}(step, 1:2)); % built-in matlab func for closest pt
        % points_W{idx, num} stores the whole rope, for robot No.idx's
        % No.num step
    end
    % Now closestPts{idx}(i) is the index of rope node closest to grasping
    % point if step i is grasping step; otherwise it's 0
end
end