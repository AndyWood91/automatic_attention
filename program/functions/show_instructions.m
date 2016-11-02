function [] = show_instructions(main_window, off_window, instructions)
    
    % might want to set background and text colours as inputs
    wait_time = 2;  % this should be an input

    for a = 1:numel(instructions)
        
        Screen('FillRect', off_window, [255 255 255])  % clear offscreen window
        DrawFormattedText(off_window, instructions{a});  % write instructions to offscreen window
        Screen('DrawTexture', main_window, off_window);  % draw offscreen window on main window
        Screen('Flip', main_window);  % refresh main window with new instructions
        WaitSecs(wait_time);
        
    end

end