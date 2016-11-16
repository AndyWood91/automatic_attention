function [fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow, main_window] = setupStimuli(main_window, fs, gpr, fixation_colour)

RGB = RGB_colours;

stim_size = 92;

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

% fixation_colour = RGB('green');

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', 0, RGB('black'), [0 0 fs fs]);  % fs = fullscreen?
Screen('DrawLine', fixationTex, RGB('white'), 0, fs/2, fs, fs/2, 2);
Screen('DrawLine', fixationTex, RGB('white'), fs/2, 0, fs/2, fs, 2);


colouredFixationTex = Screen('OpenOffscreenWindow', 0, RGB('black'), [0 0 fs fs]);
Screen('DrawLine', colouredFixationTex, fixation_colour, 0, fs/2, fs, fs/2, 4);
Screen('DrawLine', colouredFixationTex, fixation_colour, fs/2, 0, fs/2, fs, 4);

% Create a sprite for the circular AOI around the fixation cross
fixationAOIsprite = Screen('OpenOffscreenWindow', 0, RGB('black'), [0 0  120  120]);
Screen('FrameOval', fixationAOIsprite, RGB('white'), [], 1, 1);   % Draw fixation aoi circle

colouredFixationAOIsprite = Screen('OpenOffscreenWindow', 0, RGB('black'), [0 0  120  120]);
Screen('FrameOval', colouredFixationAOIsprite, fixation_colour, [], 2, 2);   % Draw fixation aoi circle


% Create a marker for eye gaze
gazePointSprite = Screen('OpenOffscreenWindow', 0, [0 0 0 0], [0 0 gpr*2 gpr*2]);
Screen('FillOval', gazePointSprite, [fixation_colour 255], [0 0 gpr*2 gpr*2], perfectDiam);       % Draw stimulus circles

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', 0, RGB('black'));
end
