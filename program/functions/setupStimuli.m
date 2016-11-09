function [fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fs, gpr, main_window)

white = [255 255 255];
black = [0 0 0];
yellow = [255 255 0];

stim_size = 92;
fix_aoi_radius = 60;
perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

% % This plots the points of a large diamond, that will be filled with colour
% d_pts = [stim_size/2, 0;
%     stim_size, stim_size/2;
%     stim_size/2, stim_size;
%     0, stim_size/2];


% Create an offscreen window, and draw the two diamonds onto it to create a diamond-shaped frame.
% diamondTex = Screen('OpenOffscreenWindow', main_window, black, [0 0 stim_size stim_size]);
% Screen('FillPoly', diamondTex, gray, d_pts);

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', main_window, black, [0 0 fs fs]);  % fs = fullscreen?
Screen('DrawLine', fixationTex, white, 0, fs/2, fs, fs/2, 2);
Screen('DrawLine', fixationTex, white, fs/2, 0, fs/2, fs, 2);


colouredFixationTex = Screen('OpenOffscreenWindow', main_window, black, [0 0 fs fs]);
Screen('DrawLine', colouredFixationTex, yellow, 0, fs/2, fs, fs/2, 4);
Screen('DrawLine', colouredFixationTex, yellow, fs/2, 0, fs/2, fs, 4);

% Create a sprite for the circular AOI around the fixation cross
fixationAOIsprite = Screen('OpenOffscreenWindow', main_window, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', fixationAOIsprite, white, [], 1, 1);   % Draw fixation aoi circle

colouredFixationAOIsprite = Screen('OpenOffscreenWindow', main_window, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', colouredFixationAOIsprite, yellow, [], 2, 2);   % Draw fixation aoi circle


% Create a marker for eye gaze
gazePointSprite = Screen('OpenOffscreenWindow', main_window, [0 0 0 0], [0 0 gpr*2 gpr*2]);
Screen('FillOval', gazePointSprite, [yellow 255], [0 0 gpr*2 gpr*2], perfectDiam);       % Draw stimulus circles

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', main_window, black);
end
