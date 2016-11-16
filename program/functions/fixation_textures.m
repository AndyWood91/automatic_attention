fixation_size = 20;
gazePointRadius = 10;
fix_aoi_radius = 60;
[fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(20, 10, main_window);
fixAOIrect = [screen_dimensions(2, 1) - fix_aoi_radius    screen_dimensions(2, 2) - fix_aoi_radius   screen_dimensions(2, 1) + fix_aoi_radius   screen_dimensions(2, 2) + fix_aoi_radius];

% Draw Fixation textures to screen
fixation_rectangle = [(screen_dimensions(2, 1) - fixation_size / 2), (screen_dimensions(2, 2) - fixation_size / 2), ...
    (screen_dimensions(2, 1) + fixation_size / 2), (screen_dimensions(2, 2) + fixation_size / 2)];

Screen('Flip', main_window);  % blank screen
WaitSecs(1);

% target screen
Screen('DrawTexture', main_window, fixationAOIsprite, [], fixAOIrect);
Screen('DrawTexture', main_window, fixationTex, [], fixation_rectangle);
Screen('Flip', main_window);
WaitSecs(1);

% % blank screen
% Screen('Flip', main_window);
% WaitSecs(2); 

% fixated screen
Screen('DrawTexture', main_window, colouredFixationAOIsprite, [], fixAOIrect, [], [], [], RGB('yellow'));
Screen('DrawTexture', main_window, colouredFixationTex, [], fixation_rectangle, [], [], [], RGB('yellow'));
Screen('Flip', main_window);
WaitSecs(1);