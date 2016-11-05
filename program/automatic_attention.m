sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

DATA = get_details('automatic_attention', {}, 1, false);

[RGB] = RGB_colours();
[main_window, ~, screen_dimensions] = PTB_screens(RGB('white'), RGB('black'));  % setup PTB screens

create_gabors;


for a = 1:11
    instruction_slides{a} = ['Instructions/Slide', int2str(a), '.jpg'];
end

% show_instructions(main_window, off_window, instruction_slides);

MainProc(main_window, screen_dimensions, DATA);
