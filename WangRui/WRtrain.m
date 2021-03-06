% record the bullet position
clear points_U
sub=rossubscriber('tracker/object');
received_data = receive(sub,3); 
points = received_data.Rope.Nodes;
%load('F:\WANGRUI\V4.0\data\Rope\Straightening.mat') ;%�only use during the test
N=size(points,1);
for i=1:N
        points_U(i,1)=points(i).X;
        points_U(i,2)=points(i).Y;
        points_U(i,3)=points(i).Z;
end
save('F:\WANGRUI\V4.0\data\Rope\TSM_RPM_rope.mat', 'points_U');

%% record the teaching trajectory
LTT_Data_Train = Load_LTT(si);
LTT_Data_Train = LTT_Data_Refine(LTT_Data_Train, si);
save('F:\WANGRUI\V4.0\data\Rope\Traj_Train.mat','LTT_Data_Train');

%% show the teaching trajectory
    disp('======================================================================');
    fig1_handle = figure(2);
    set(fig1_handle,'position', [962 42 958 434]);
    % save as LTT_Data_UCBtest for CFS check
    LTT_Data_UCBtest =LTT_Data_Train ;
    save('F:\TeTang\V4.0\CFS_ver1.1\dataLTT\UCBTest.mat', 'LTT_Data_UCBtest');
    % CFS check (graphics display of robots carrying out traj -WR)
    CFS_Main