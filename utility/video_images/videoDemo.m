% Wenjie Chen, FANUC Corporation, 2016/03/24
% Based on VIDEODEMO from Kin2 toolbox

if exist('../init_setup.m', 'file')
    run('../init_setup.m');
end

% Create Kinect 2 object and initialize it
% Select sources as input parameters.
% Available sources: 'color', 'depth', 'infrared' and 'body'
k2 = Kin2('color','depth','infrared');

% images sizes
depth_width = 512; depth_height = 424; outOfRange = 4000;
color_width = 1920; color_height = 1080;

% Color image is to big, let's scale it down
colorScale = 0.5;

% Create matrices for the images
depth = zeros(depth_height,depth_width,'uint16');
infrared = zeros(depth_height,depth_width,'uint16');
color = zeros(color_height*colorScale,color_width*colorScale,3,'uint8');

% depth stream figure
figure, h1 = imshow(depth,[0 outOfRange]);
title('Depth Source (press q to exit)')
colormap('Jet')
colorbar
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress

% color stream figure
figure, h2 = imshow(color,[]);
title('Color Source (press q to exit)');
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress

% infrared stream figure
figure, h3 = imshow(infrared,[]);
title('Infrared Source (press q to exit)');
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress

% Loop until pressing 'q' on any figure
k=[];  
videoFileName = char(datetime('now','Format','yyyyMMdd_HHmmssMS'));
V_color = VideoWriter(['./data/video/vid_', videoFileName, '.avi']);
V_color.FrameRate = 10;
open(V_color);

disp('Press q on any figure to exit')
while true
    % Get frames from Kinect and save them on underlying buffer
    validData = k2.updateKin2;
    
    % Before processing the data, we need to make sure that a valid
    % frame was acquired.
    if validData
        % Copy data to Matlab matrices
        depth = k2.getDepth;
        color = k2.getColor;
        infrared = k2.getInfrared;

        % update depth figure
        depth(depth>outOfRange) = outOfRange; % truncate depht
        set(h1,'CData',depth); 

        % update color figure
        color = imresize(color,colorScale);
        set(h2,'CData',color); 

        % update infrared figure
        set(h3,'CData',infrared); 
        
        writeVideo(V_color, im2frame(color));
    end
    
    % If user presses 'q', exit loop
    if ~isempty(k)
        if strcmp(k,'q'); break; end;
    end
  
    pause(0.02)
end

% Close kinect object
k2.delete;
close(V_color);

close all;
