sca;
clc;
clear all;
KbName('UnifyKeyNames');
addpath('functions');

global TESTING
TESTING = 1;

% RGB colours
white = [255 255 255];
black = [0 0 0];

% instruction strings
instructions = {'a string', 'a different string', 'another string'};

% participant details

[main_window, off_window, screen_dimensions] = PTB_screens(white, black);  % setup PTB screens
screen_centre = screen_dimensions/2;

create_gabors;

show_instructions(main_window, off_window, instructions);

sca;

MainProc;
