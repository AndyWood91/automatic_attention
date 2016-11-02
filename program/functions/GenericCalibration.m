% Screen('Preference', 'SkipSyncTests', 1)

% Input participant number in order to save calibration data

p_number = input('Participant number  ---> ');


% Test Calibration Script
HideCursor;

%% This just adds the functions folder to the path for calling the Tobii functions
app_home = cd;
cd(app_home);
addpath(genpath(strcat(app_home, '\functions')))
%% Sets up MainWindow
global MainWindow Calib calibCoordinatesX calibCoordinatesY

calibCoordinatesX = [192 1728 960 1728 192];
calibCoordinatesY = [108 108 540 972 972];


% ScreenRes = [2560 1440];
ScreenRes = [1920 1080];
WinHeight = 1080;
WinWidth = 1920;
winPos = zeros(1,4);
winPos([1 3]) = [(ScreenRes(1)-WinWidth)/2  ScreenRes(1)-(ScreenRes(1)-WinWidth)/2];
winPos([2 4]) = [ScreenRes(2)-WinHeight ScreenRes(2)];

% create windows and textures
MainWindow = Screen ('OpenWindow', 0, [0 0 0], winPos);
%% Connecting to eyetracker
disp('Initializing tetio...');
tetio_init();

disp('Browsing for trackers...');
trackerinfo = tetio_getTrackers();
trackerId = trackerinfo(1).ProductId;

fprintf('Connecting to tracker "%s"...\n', trackerId);
tetio_connectTracker(trackerId);

currentFrameRate = tetio_getFrameRate;
fprintf('Connected! Sample rate: %d Hz.\n', currentFrameRate);
%% This is the calibration stage
SetCalibParamsPTB; 

TrackStatusPTB;

calibPoints = HandleCalibWorkflowPsychToolBox(Calib); %calibPoints is what you will want to save (or add to your data file)
%% Closes everything down
if exist('CalibrationData', 'dir') == 0
    mkdir('CalibrationData');
end

filepath = ['CalibrationData\P', num2str(p_number), '_Cal'];

save(filepath,'calibPoints')

clear

sca; 
ShowCursor;