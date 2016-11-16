function [main_window, off_window, screen_dimensions] = PTB_screens(background, text, DATA, tracking)

    if nargin < 4
        tracking = false;  % default, no eye tracking
    end
    
    global TESTING
    % screen dimensions
    screen_number = 0;  % primary monitor
    [screen_width, screen_height] = Screen('WindowSize', screen_number);
    screen_dimensions = [screen_width, screen_height; screen_width/2, screen_height/2];
    
    % PTB window
    if TESTING == 1  % test version
        Screen('Preference', 'SkipSyncTests', 2);      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!
        Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen
        
        PTB_screen = [0 0 screen_width screen_height];  % full screen
%         PTB_screen = [0 0 screen_width * 0.75 screen_height * 0.75];  % three quarter screen
%         screen_dimensions = screen_dimensions * 0.75;

    elseif TESTING == 0  % experiment version
        PTB_screen = [0 0 screen_width screen_height];  % full screen
    else
        error('global variable TESTING is set incorrectly');
    end
    
    if tracking == true
        
        
        %% Connect to Tetio trackers
        disp('Initializing tetio...');
        tetio_init();

        disp('Browsing for trackers...');
        trackerinfo = tetio_getTrackers();
        trackerId = trackerinfo(1).ProductId;

        fprintf('Connecting to tracker "%s"...\n', trackerId);
        tetio_connectTracker(trackerId)

        currentFrameRate = tetio_getFrameRate;
        fprintf('Connected!  Sample rate: %d Hz.\n', currentFrameRate);
        
        % TODO: save trackerId.
        
        calibration_directory = [DATA.experiment.title, '_CalibrationData'];
        eyegaze_directory = [DATA.experiment.title, '_EyeData'];
        
        
        if ~exist(calibration_directory, 'dir')  % check for directory to save calibration data
            mkdir(calibration_directory);  % make it if it doesn't exist
        end
        
        if ~exist(eyegaze_directory, 'dir')  % check for directory to save eyegaze data
            mkdir(eyegaze_directory);  % make it if it doesn't exist
        end
        
        mkdir(calibration_directory, ['Participant', DATA.experiment.number, '_session', DATA.experiment.session]);
        mkdir(eyegaze_directory, ['Participant', DATA.experiment.number, '_session', DATA.experiment.session]);
        
        
        
        %% 
        
        main_window = Screen('OpenWindow', screen_number, background, PTB_screen);
        
        % ANDY - no idea what below does.
        Screen('BlendFunction', main_window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %This allows for transparent background on white dot


%         runPTBcalibration;

% ANDY - I know why this is being pulled but I'm not sure it's needed.
        oldTextFont = Screen('TextFont', main_window);
        oldTextSize = Screen('TextSize', main_window);
        oldTextStyle = Screen('TextStyle', main_window);

        % set focal points



        %% This is the calibration stage
        Calib = SetCalibParamsPTB(background, screen_dimensions); 

        TrackStatusPTB(Calib, main_window);

        calibPoints = HandleCalibWorkflowPsychToolBox(Calib, main_window); % calibPoints is what you will want to save (or add to your data file)

        %% Closes everything down
        
        calibrationNum = 0;
        calibrationNum = calibrationNum + 1;

        filepath = [calibration_directory, '/Participant', DATA.experiment.number, '_session', DATA.experiment.session '_Cal', num2str(calibrationNum)];

        save(filepath,'calibPoints')

        clear calibPoints;
        clear filePath;

        Screen('TextFont', main_window, oldTextFont);
        Screen('TextSize', main_window, oldTextSize);
        Screen('TextStyle', main_window, oldTextStyle);
    else
    
    % PTB windows
    main_window = Screen('OpenWindow', screen_number, background, PTB_screen);
    
    end

    off_window = Screen('OpenOffscreenWindow', screen_number, background, PTB_screen);
    Screen('TextSize', off_window, 50);
    Screen('TextFont', off_window, 'Arial');
    Screen('TextColor', off_window, text);  % already an input
    % set font, size, colour, etc. here - could be inputs later
    

end