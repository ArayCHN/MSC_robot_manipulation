%% comunication with Ubuntu
% Run the following commands after setting up your PC's ros master IP, and connecting it to kinect
setenv('ROS_MASTER_URI','http://192.168.1.40:11311')
setenv('ROS_IP','192.168.1.90')
rosinit()

%% Brake Off
wasStopped = tg_start_stop('start');
wasBrakeOff = brake_on_off(si.ParamSgnID, 'off');

%% Subsribe to ROS topic
sub = rossubscriber('tracker/object'); % your PC, as ros master, should be publishing this topic (tracked obj) now
received_data = receive(sub,3); % wait for at most 3 seconds.
points = received_data.Rope.Nodes; % N*1 vector, each element: .X, .Y, .Z
N = size(points,1); % total num of nodes on a rope

%% Now, we need to get the tangent info of all nodes from TSM_RPM, use EM to get a non-rigid transform that minimizes the cost of TSM_RPM
% first, try to get the info of the tangent of a rope from bullet physics library!
% Angles could be derived from the positions of nodes or directly from bullet (which seems difficult?)

%% Load all points and transform them into the world frame
clear points_Test_U
T_W2U = transl((22.5 * 2.54 + 2.486 * 5) / 100, -2.486 * 2.5 / 100, 0) * trotz(-pi / 2); % transformation matrix, World to Kinect
T_B2U = inv(si.ri{1}.T_B2W) * T_W2U; % transformation matrix, Robot Base to Kinect
load('F:\WANGRUI\V4.0\data\Rope\TSM_RPM_rope.mat'); % load the training data of trajectory
load('F:\WANGRUI\V4.0\data\Rope\Traj_Train_traj.mat'); % load the training data of rope

%% transform points from kinect frame to world frame
points_Test_U = [[points.X]', [points.Y]', [points.Z]']; % convert points(i).X,Y,Z to points_T_U(i, 1,2,3)
points_U = [points_U, ones(size(points_U, 1), 1)];
points_W = (T_W2U * points_U')';
points_W = points_W(:, 1 : 3);
points_U = points_U(:, 1 : 3); % all training points transformed to world finished
points_Test_U = [points_Test_U, ones(size(points_Test_U, 1), 1)];
points_Test_W = (T_W2U * points_Test_U')';
points_Test_W = points_Test_W(:, 1 : 3);
points_Test_U = points_Test_U(:, 1 : 3); % testing points transformed to world finished

k = 2;
WarpIndex = [1, 2]; % WarpIndex can be 1, 2, or [1, 2]
LTT_Data_Train.ReplayTime{1} = k * LTT_Data_Train.ReplayTime{1};
LTT_Data_Train.ReplayTime{2} = k * LTT_Data_Train.ReplayTime{2};

%% TPS-RPM-Warp the robot trajectory
[LTT_Data_Test, warp] = TPS_RPM_Warp(LTT_Data_Train, points_W, points_Test_W, si, WarpIndex);

disp('Please double check which robot''s motion needs to be warped!');
% Use the traj above to generate excecutable LTT_Data_Test series:

% visualize the warping of the original training rope and the test rope
fig3_handle = figure(3);
set(fig3_handle, 'position', [962 562 958 434]);
orig_fig = subplot(1,2,1); scatter(points_W(:, 1), points_W(:, 2), 'r*'); title('Train'); % plot the original rope 2-D shape
warp_fig = subplot(1,2,2); scatter(points_Test_W(:, 1), points_Test_W(:, 2), 'r*'); title('Test'); % plot the test rope
% draw_grid([-0.5 0.8], [1 -0.7], warp, 20, orig_fig, warp_fig)
% subplot(orig_fig); axis equal; xlim([-0.5,1]); ylim([-0.7,0.8]); drawnow;
% subplot(warp_fig); axis equal; xlim([-0.5,1]); ylim([-0.7,0.8]); drawnow; % plote the grid

%% Run CFS, which displays an animation of fanuc robot following designed trajectory
disp('======================================================================')
% Remember to check collision if workpiece location is changed substantially!
disp('======================================================================');
fig1_handle = figure(2);
set(fig1_handle, 'position', [962 42 958 434]);
% save as LTT_Data_UCBtest for CFS check
LTT_Data_UCBtest = LTT_Data_Test;
save('F:\TeTang\V4.0\CFS_ver1.1\dataLTT\UCBTest.mat', 'LTT_Data_UCBtest');
% CFS check
CFS_Main
input('Use CFS toolbox to check collision. Press any key to execute the motion!!!')


%% Finally run the robot

Traj_Download_Run(LTT_Data_Test, si, 'Download', 'Run');