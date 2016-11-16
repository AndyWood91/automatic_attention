function [RGB] = RGB_colours()
% RGB_COLOURS:  Returns a Map container with keys for common colour names and
% their RGB triplets as values

    RGB_names = {'white', 'grey', 'black', 'red', 'green', 'blue', ...
        'cyan', 'purple', 'yellow'};
    RGB_triplets = {[255 255 255], [127 127 127], [0 0 0], [255 0 0], ...
        [0 255 0], [0 0 255] [0 255 255] [255 0 255] [255 255 0]};
    
    RGB = containers.Map(RGB_names, RGB_triplets);

end