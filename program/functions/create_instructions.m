function [instructions_slides] = create_instructions(extension, main_window)

    if nargin < 1
        extension = '.jpg';
    end
    
    instructions = dir('instructions/*.JPG');
    instructions_length = length(instructions);  % count everything that matches the extension and isn't a directory
    
    for a = 1:instructions_length
        instructions_file = ['instructions/slide', int2str(a), extension];
        instructions_slides(a) = Screen('MakeTexture', main_window, imread(instructions_file));
    end
    
    
end