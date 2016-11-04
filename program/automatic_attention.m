sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

RGB_colours;
DATA = get_details('automatic_attention', {}, 1, false);
[main_window, off_window, screen_dimensions] = PTB_screens(white, black);  % setup PTB screens
create_gabors;

for a = 1:11
    instruction_slides{a} = ['Instructions/Slide', int2str(a), '.jpg'];
end

show_instructions(main_window, off_window, instruction_slides);

MainProc(main_window, off_window, screen_dimensions, DATA);
