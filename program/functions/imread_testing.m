[main_window, off_window, screen_dimensions] = PTB_screens([255 255 255], [0 0 0]);

instruction = 'Instructions/Slide1.jpg';
instruction_stimulus = Screen('MakeTexture', main_window, imread(instruction));

Screen('DrawTexture', main_window, instruction_stimulus, [], [5 5 600 600]);
Screen('Flip', main_window);

WaitSecs(2);
sca;
