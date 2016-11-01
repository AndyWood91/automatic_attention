Screen('Preference', 'SkipSyncTests', 1);  % skip PTB calibration

screen_number = 0;  % primary monitor
[screen_width, screen_height] = Screen('WindowSize', screen_number);
test_rectangle = [0 0 screen_width/2 screen_height/2];

white = [255 255 255];
black = [0 0 0];


main_window = Screen('OpenWindow', screen_number, black, test_rectangle);
WaitSecs(2);
HideCursor;
WaitSecs(2);
ShowCursor;

off_window = Screen('OpenOffscreenWindow', screen_number, white, test_rectangle);

sca;