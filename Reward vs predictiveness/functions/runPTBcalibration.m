
global Calib calibCoordinatesX calibCoordinatesY
global p_number
global calibrationNum
global MainWindow


oldTextFont = Screen('TextFont', MainWindow);
oldTextSize = Screen('TextSize', MainWindow);
oldTextStyle = Screen('TextStyle', MainWindow);


[scrWidth, scrHeight] = Screen('WindowSize', MainWindow);

calibCoordinatesX = scrWidth * [0.2, 0.8, 0.5, 0.8, 0.2];
calibCoordinatesY = scrHeight * [0.2, 0.2, 0.5, 0.8, 0.8];


%% This is the calibration stage
SetCalibParamsPTB; 

TrackStatusPTB;

calibPoints = HandleCalibWorkflowPsychToolBox(Calib); % calibPoints is what you will want to save (or add to your data file)

%% Closes everything down

calibrationNum = calibrationNum + 1;

filepath = ['CalibrationDat\P', num2str(p_number), '_Cal', num2str(calibrationNum)];

save(filepath,'calibPoints')

clear calibPoints;
clear filePath;

Screen('TextFont', MainWindow, oldTextFont);
Screen('TextSize', MainWindow, oldTextSize);
Screen('TextStyle', MainWindow, oldTextStyle);
