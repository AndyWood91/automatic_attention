
global Calib calibCoordinatesX calibCoordinatesY
global p_number
global calibrationNum


oldTextFont = Screen('TextFont', main_window);
oldTextSize = Screen('TextSize', main_window);
oldTextStyle = Screen('TextStyle', main_window);


[scrWidth, scrHeight] = Screen('WindowSize', main_window);

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

Screen('TextFont', main_window, oldTextFont);
Screen('TextSize', main_window, oldTextSize);
Screen('TextStyle', main_window, oldTextStyle);
