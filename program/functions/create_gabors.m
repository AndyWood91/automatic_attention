gabor_size = 400;  % in pixels
[gabor_ID, ~] = CreateProceduralGabor(main_window, gabor_size, gabor_size);  % dunno
gabor_angles1 = [95 265 95 265 90 270 90 270];  % angled & flat
gabor_angles2 = [95 265 95 265 95 265 95 265];  % both angled
% gonna change this
% gabor_angles = [95 265 95 265; 
colours = [RGB('blue'); RGB('grey'); RGB('red'); RGB('green')];  % none of these actually come through
colours = colours(randperm(4),:); % randomise order of colours
gabor_colours = [colours(1,:); colours(1,:); colours(2,:); colours(2,:); ...
    colours(3,:); colours(3,:); colours(4,:); colours(4,:)];
freq = .04; sc = 50; contrast = 20; aspectratio = 1.0;
gabor_proportions = [0 freq, sc, contrast, aspectratio, 0, 0, 0];

% gabor_position is a rectangle to draw the gabor into. Going to change
% this to three values: left, right, and centre
% gabor_position = [
%     50, (screen_dimensions(2, 2)-gabor_size/2), 50+gabor_size, (screen_dimensions(2, 2)+gabor_size/2); 
%     screen_dimensions(1, 1)-50-gabor_size, (screen_dimensions(2, 2)-gabor_size/2), screen_dimensions(1, 1)-50, (screen_dimensions(2, 2)+gabor_size/2)];

gabor_position = [50, (screen_dimensions(2, 2) - gabor_size/2), (50 + gabor_size), (screen_dimensions(2, 2) + gabor_size/2); ...  % left box
    (screen_dimensions(1, 1) - 50 - gabor_size), (screen_dimensions(2, 2) - gabor_size/2), screen_dimensions(1, 1) - 50, (screen_dimensions(2, 2) + gabor_size/2);  % right box
    (screen_dimensions(2, 1) - gabor_size/2), (screen_dimensions(2, 2) - gabor_size/2), (screen_dimensions(2, 1) + gabor_size/2), (screen_dimensions(2, 2) + gabor_size/2)];  % centre box