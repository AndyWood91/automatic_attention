function [main_window, off_window, screen_dimensions] = PTB_screens(background, text)
    
    global TESTING
    
    % screen dimensions
    screen_number = 0;  % primary monitor
    [screen_width, screen_height] = Screen('WindowSize', screen_number);
    screen_dimensions = [screen_width, screen_height];
    
    % PTB window
    if TESTING == 1
        Screen('Preference', 'SkipSyncTests', 1);  % skip PTB calibration
        PTB_screen = [0 0 screen_width/2 screen_height/2];  % quarter screen
    elseif TESTING == 0
        PTB_screen = [0 0 screen_width screen_height];  % full screen
    else
        error('global variable TESTING is set incorrectly');
    end
    
    % PTB windows
    main_window = Screen('OpenWindow', screen_number, background, PTB_screen);

    off_window = Screen('OpenOffscreenWindow', screen_number, background, PTB_screen);
    Screen('TextSize', off_window, 50);
    Screen('TextFont', off_window, 'Arial');
    Screen('TextColor', off_window, text);  % already an input
    % set font, size, colour, etc. here - could be inputs later
    

end