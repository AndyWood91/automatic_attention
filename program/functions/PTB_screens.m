function [main_window, off_window] = PTB_screens(background)
    
    global TESTING
    
    % screen dimensions
    screen_number = 0;  % primary monitor
    [screen_width, screen_height] = Screen('WindowSize', screen_number);
    
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
    % set font, size, colour, etc. here
    off_window = Screen('OpenOffscreenWindow', screen_number, background, PTB_screen);
    % set font, size, colour, etc. here
    

end