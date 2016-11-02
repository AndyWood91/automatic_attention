global Calib calibCoordinatesX calibCoordinatesY

screensize = get(0,'Screensize');
Calib.mondims1.x = screensize(1);
Calib.mondims1.y = screensize(2);
Calib.mondims1.width = screensize(3);
Calib.mondims1.height = screensize(4);

Calib.MainMonid = 1; 
Calib.TestMonid = 1;

Calib.points.x = calibCoordinatesX./Calib.mondims1.width;  % X coordinates in [0,1] coordinate system 
Calib.points.y = calibCoordinatesY./Calib.mondims1.height;  % Y coordinates in [0,1] coordinate system 
Calib.points.n = size(Calib.points.x, 2); % Number of calibration points
Calib.bkcolor = [217 217 217]; % background color used in calibration process
Calib.fgcolor = [0 0 255]; % (Foreground) color used in calibration process
Calib.fgcolor2 = [255 0 0]; % Color used in calibratino process when a second foreground color is used (Calibration dot)
Calib.BigMark = 25; % the big marker 
Calib.TrackStat = 25; % 
Calib.SmallMark = 7; % the small marker
Calib.delta = 200; % Moving speed from point a to point b
Calib.resize = 1; % To show a smaller window
%Calib.NewLocation = get(gcf,'position');


