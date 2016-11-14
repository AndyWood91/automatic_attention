gabor_size = 400;  % in pixels
[gabor_ID, ~] = CreateProceduralGabor(main_window, gabor_size, gabor_size, 0, [1 1 1 0], [], 5);  % dunno
gabor_angles1 = [95 265 95 265 90 270 90 270];  % angled & flat
gabor_angles2 = [95 265 95 265 95 265 95 265];  % both angled
colours = [RGB('blue'); RGB('black'); RGB('red'); RGB('green')];
colours = colours(randperm(4),:); % randomise order of colours
gabor_colours = [colours(1,:); colours(1,:); colours(2,:); colours(2,:); ...
    colours(3,:); colours(3,:); colours(4,:); colours(4,:)];
freq = .04; sc = 50; contrast = 20; aspectratio = 1.0;
gabor_proportions = [0 freq, sc, contrast, aspectratio, 0, 0, 0];
gabor_position = [50, (screen_dimensions(2, 2)-gabor_size)/2, 50+gabor_size, ...
    (screen_dimensions(2, 2)+gabor_size)/2, screen_dimensions(1, 1)-50-gabor_size, ...
    (screen_dimensions(2, 2)-gabor_size)/2, screen_dimensions(1, 1)-50, ...
    (screen_dimensions(2, 2)+gabor_size)/2];
