function [RGB] = RGB_colours()
% RGB_COLOURS:  Returns a Map container with keys for common colour names and
% their RGB triplets as values

    RGB_names = {'white', 'grey', 'black', 'red', 'green', 'blue'};
    RGB_triplets = {[0 0 0], [127 127 127], [255 255 255], [0 255 255], ...
        [255 0 255], [255 255 0]};
    
    RGB = containers.Map(RGB_names, RGB_triplets);

end