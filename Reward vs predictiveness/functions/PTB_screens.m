function [main_window, off_window, screen_dimensions] = PTB_screens(background, text, tracking)

    if nargin <3
        tracking = true;
    end
    
    global TESTING
    
    % screen dimensions
    screen_number = 0;  % primary monitor
    [screen_width, screen_height] = Screen('WindowSize', screen_number);
    screen_dimensions = [screen_width, screen_height; screen_width/2, screen_height/2];
    
    % PTB window
    if TESTING == 1
        Screen('Preference', 'SkipSyncTests', 2);      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!
        Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen
%         PTB_screen = [0 0 screen_width*.75 screen_height*.75];  % three quarter screen
        PTB_screen = [0 0 screen_width screen_height];  % full screen

    elseif TESTING == 0
        PTB_screen = [0 0 screen_width screen_height];  % full screen
    else
        error('global variable TESTING is set incorrectly');
    end
    
    if tracking == true
        %
    end
    
    % PTB windows
    main_window = Screen('OpenWindow', screen_number, background, PTB_screen);

    off_window = Screen('OpenOffscreenWindow', screen_number, background, PTB_screen);
    Screen('TextSize', off_window, 50);
    Screen('TextFont', off_window, 'Arial');
    Screen('TextColor', off_window, text);  % already an input
    % set font, size, colour, etc. here - could be inputs later
    

end