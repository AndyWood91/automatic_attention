sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

% generic functions
DATA = get_details('automatic_attention', {}, 1, false);
RGB = RGB_colours();
[main_window, ~, screen_dimensions] = PTB_screens(RGB('white'), RGB('black'));  % setup PTB screens
instructions_slides = create_instructions('.jpg', main_window);

% automatic_attention functions
MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB);
