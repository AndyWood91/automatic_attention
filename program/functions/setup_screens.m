Screen('Preference', 'SkipSyncTests', 1);  % skip PTB calibration

% screen properties
screen_number = 0;  % primary monitor
[screen_width, screen_height] = Screen('WindowSize', screen_number);
test_rectangle = [0 0 screen_width/2 screen_height/2];
full_rectangle = [0 0 screen_width screen_height];

% colours
white = [255 255 255];
black = [0 0 0];

% instruction strings
str = 'a string';
str1 = 'a different string';
instructions = {str, str1};

% PTB windows
main_window = Screen('OpenWindow', screen_number, white, test_rectangle);
off_window = Screen('OpenOffscreenWindow', main_window, white, test_rectangle);

WaitSecs(2);

% turn this into a function
% Screen('FillRect', off_window, white);
% DrawFormattedText(off_window, str);
% Screen('DrawTexture', main_window, off_window);
% Screen('Flip', main_window)
% WaitSecs(2);
% 
% Screen('FillRect', off_window, white);
% DrawFormattedText(off_window, str1);
% Screen('DrawTexture', main_window, off_window);
% Screen('Flip', main_window);
% WaitSecs(2);
show_instructions(main_window, off_window, instructions);

sca;
