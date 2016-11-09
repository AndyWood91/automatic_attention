sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

% generic functions
DATA = get_details('automatic_attention', {}, 1, true);
RGB = RGB_colours();
[main_window, off_window, screen_dimensions] = PTB_screens(RGB('white'), RGB('black'));  % setup PTB screens

% sca;

% automatic_attention functions
% instructions_slides = create_instructions('.jpg', main_window);
% MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB);

% testing out gaze fixation


DATA = update_details(DATA);
sca;