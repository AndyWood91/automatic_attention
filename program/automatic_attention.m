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

fixation_size = 20;
gazePointRadius = 10;
fix_aoi_radius = 60;
[fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(20, 10, main_window);
fixAOIrect = [screen_dimensions(2, 1) - fix_aoi_radius    screen_dimensions(2, 2) - fix_aoi_radius   screen_dimensions(2, 1) + fix_aoi_radius   screen_dimensions(2, 2) + fix_aoi_radius];

% Draw Fixation textures to screen
fixation_rectangle = [(screen_dimensions(2, 1) - fixation_size / 2), (screen_dimensions(2, 2) - fixation_size / 2), ...
    (screen_dimensions(2, 1) + fixation_size / 2), (screen_dimensions(2, 2) + fixation_size / 2)];
Screen('DrawTexture', stimWindow, fixationTex, [], fixation_rectangle);
Screen('Flip', main_window);
WaitSecs(2);
Screen('DrawTexture', main_window, fixationAOIsprite, [], fixAOIrect);
Screen('DrawTexture', main_window, fixationTex, [], fixation_rectangle);
Screen('Flip', main_window);
WaitSecs(2);

% automatic_attention functions
instructions_slides = create_instructions('.jpg', main_window);
MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB);

DATA = update_details(DATA);
sca;