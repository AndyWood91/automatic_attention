sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

RGB_colours;

% participant details
DATA = get_details('automatic_attention', {}, 1, false);

[main_window, off_window, screen_dimensions] = PTB_screens(white, black);  % setup PTB screens
create_gabors;
sca;

MainProc(main_window, off_window);
