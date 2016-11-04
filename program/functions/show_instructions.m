function [] = show_instructions(main_window, off_window, instructions)
    
    % might want to set background and text colours as inputs
%     wait_time = 2;  % this should be an input

    for a = 1:numel(instructions)
        
        RestrictKeysForKbCheck(KbName('space'));
        instruction_stimulus(a) = Screen('MakeTexture', main_window, imread(instructions{a}));
        Screen('DrawTexture', main_window, instruction_stimulus(a), [], [0 0 1080 675]);
        Screen('Flip', main_window);  % refresh main window with new instructions
        accKbWait;
        
    end

end