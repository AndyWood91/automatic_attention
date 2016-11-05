function [RGB] = RGB_colours()
% RGB_COLOURS:  Returns a Map container with keys for common colour names and
% their RGB triplets as values

    RGB = containers.Map({'white', 'grey', 'black', 'red', ...
        'green', 'blue'}, [[0 0 0] [127 127 127] [255 255 255] ...
        [0 255 255] [255 0 255] [255 255 0]]);

end