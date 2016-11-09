sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

% generic functions
% DATA = get_details('automatic_attention', {}, 1, true);
RGB = RGB_colours();
[main_window, off_window, screen_dimensions] = PTB_screens(RGB('white'), RGB('black'));  % setup PTB screens
% instructions_slides = create_instructions('.jpg', main_window);
% sca;

% automatic_attention functions
% MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB);

% testing out gaze fixation
gaze_fixation(main_window, off_window, screen_dimensions, RGB)

% DATA = update_details(DATA);
sca;