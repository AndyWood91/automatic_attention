<<<<<<< HEAD
sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 0;  % 0 = test version, for debugging, 1 = experiment version
tracking = true;  % run ET or not.

% generic functions
DATA = get_details('automatic_attention', {}, 1, true);
RGB = RGB_colours();
[main_window, off_window, screen_dimensions] = PTB_screens(RGB('black'), RGB('white'), DATA, tracking);  % setup PTB screens

% fixation_textures;

% automatic_attention functions
instructions_slides = create_instructions('.jpg', main_window);
MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB, false);

DATA = update_details(DATA);
=======
sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 0;

% generic functions
DATA = get_details('automatic_attention', {}, 1, true);
RGB = RGB_colours();
[main_window, off_window, screen_dimensions] = PTB_screens(RGB('black'), RGB('white'), DATA, false);  % setup PTB screens

% fixation_textures;

% automatic_attention functions
instructions_slides = create_instructions('.jpg', main_window);
MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB, false);

DATA = update_details(DATA);
>>>>>>> 32d93088fe70586bc52f571b33bdba2d53917f4a
sca;