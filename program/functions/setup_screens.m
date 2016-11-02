global TESTING

TESTING = 1;  % experimental version = 0, test version = 1

% colours
white = [255 255 255];
black = [0 0 0];

% instruction strings
str = 'a string';
str1 = 'a different string';
str2 = 'another string';
instructions = {str, str1, str2};


[main_window, off_window] = PTB_windows(white);

show_instructions(main_window, off_window, instructions);

sca;
