function [] = show_instructions(main_window, off_window, instructions)
    
    % colours
    background_colour = [255 255 255];
    text_colour = [0 0 0];
    
    wait_time = 2;

    for a = 1:numel(instructions)

        Screen('FillRect', off_window, background_colour)  % clear offscreen window
        DrawFormattedText(off_window, instructions(a));  % write instructions to offscreen window
        Screen('DrawTexture', main_window, off_window);  % draw offscreen window on main window
        Screen('Flip', main_window);  % refresh main window with new instructions
        WaitSecs(wait_time);

    end

end