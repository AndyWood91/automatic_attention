function [] = gaze_contingent_fixation(main_window, screen_dimensions, fixation_colour)
% ANDY - this is using offscreen windows so it's a bit dated.

% GAZE_CONTINGENT_FIXATION: 


exptPhase = 0;
gamma = 0.2;  % Controls smoothing of displayed gaze location. Lower values give more smoothing

timeoutDuration = [4, 2];     % [4, 2] timeout duration
fixationTimeoutDuration = 5;    % 5 fixation timeout duration

itiDuration = 0;            % 1.2
briefPause = 0.1;       % 0.1
yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
initialPause = 0;   % 2.5 ***
breakDuration = 20;  % 20 ***
fixationFixationTime = 0.7;       % Time that fixation cross must be fixated for trial to begin
fixationPollingInterval = 0.03;    % Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display
junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated
junkGazeCycles = junkFixationPeriod / trialPollingInterval;


fix_size = 20;      % This is the side length of the fixation cross
fix_aoi_radius = fix_size * 3;
gazePointRadius = 10;



% Create a rect for the fixation cross
fixRect = [screen_dimensions(2, 1) - fix_size/2    screen_dimensions(2, 2) - fix_size/2   screen_dimensions(2, 1) + fix_size/2   screen_dimensions(2, 2) + fix_size/2];


% Create a rect for the circular fixation AOI
fixAOIrect = [screen_dimensions(2, 1) - fix_aoi_radius    screen_dimensions(2, 2) - fix_aoi_radius   screen_dimensions(2, 1) + fix_aoi_radius   screen_dimensions(2, 2) + fix_aoi_radius];


% [fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow, main_window] = setupStimuli(main_window, fix_size, gazePointRadius, fixation_colour);
% ANDY - going to try and take this out of a function, textures should
% probably be made with the PTB_screens
%%
RGB = RGB_colours;

stim_size = 92;
fs = fix_size; 
gpr = gazePointRadius;

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
%%
trialEGarray = zeros(timeoutDuration(exptPhase + 1) * 2 * 300, 27);    % Preallocate memory for eyetracking data. Tracker samples at 300Hz, so multiplying timeout duration by 2*300 means there will be plenty of slots
% ANDY - still need this, but it's currently wron.

Screen('Flip', main_window);     % Clear anything that's on the screen

WaitSecs(initialPause);

% ANDY - want to take the fixation out of the loop (just do it once)

% Andy - should be able to flip the screen   
Screen('FillRect', stimWindow, RGB('black'));  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
Screen('DrawTexture', stimWindow, fixationTex, [], fixRect);


Screen('Flip', main_window);     % Clear screen
WaitSecs(briefPause);


Screen('DrawTexture', main_window, fixationAOIsprite, [], fixAOIrect);
Screen('DrawTexture', main_window, fixationTex, [], fixRect);

timeOnFixation = zeros(2);    % a slot for each stimulus location, and one for "everywhere else"
stimSelected = 2;   % 1 = fixation cross, 2 = everywhere else
fixated_on_fixation_cross = 0;
fixationBadSamples = 0;
fixationTimeout = 0;

currentGazePoint = zeros(1,2);
gazeCycle = 0;

startFixationTime = Screen('Flip', main_window, [], 1);     % Present fixation cross


[~, ~, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the trial. Need to convert to double so can divide by 10^6 later to change to seconds
startFixationTimeoutPeriod = startEyePeriod;


while fixated_on_fixation_cross == 0
    
    Screen('DrawTexture', main_window, fixationAOIsprite, [], fixAOIrect);   % Redraw fixation cross and AOI, and draw gaze point on top of that
    Screen('DrawTexture', main_window, fixationTex, [], fixRect);

    WaitSecs(fixationPollingInterval);      % Pause between updates of eye position
    [lefteye, righteye, ts, ~] = tetio_readGazeData;    % Get eye-tracker data since previous call

    if isempty(ts) == 0

        [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts), screen_dimensions);    % Find mean gaze location during the previous polling interval

        gazeCycle = gazeCycle + 1;

        if validPoints > 0
            if gazeCycle <= junkGazeCycles
                currentGazePoint = [eyeX, eyeY];        % If in junk period at start of trial, keep track of gaze location; this will determine starting point of gaze when the junk period ends
            else
                currentGazePoint = (1 - gamma) * currentGazePoint + gamma * [eyeX, eyeY];       % Calculate smoothed gaze location using weighted moving average of current and previous locations

                Screen('DrawTexture', main_window, gazePointSprite, [], [currentGazePoint(1) - gazePointRadius, currentGazePoint(2) - gazePointRadius, currentGazePoint(1) + gazePointRadius, currentGazePoint(2) + gazePointRadius]);
                Screen('DrawingFinished', main_window);

                stimSelected = checkEyesOnFixation(eyeX, eyeY, screen_dimensions, fix_aoi_radius);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"

            end

        else
            stimSelected = 2;   % If no gaze detected, record gaze as "everywhere else"
            fixationBadSamples = fixationBadSamples + 1;
        end

        endEyePeriod = double(ts(end));     % Last entry in timestamp data gives end time of polling period
        timeOnFixation(stimSelected) = timeOnFixation(stimSelected) + (endEyePeriod - startEyePeriod) / 10^6;   % Divided by 10^6 because eyetracker gives time in microseconds
        startEyePeriod = endEyePeriod;      % Start of next polling period is end of the last one

    end

    if timeOnFixation(1) >= fixationFixationTime         % If fixated on target
        fixated_on_fixation_cross = 1;
    elseif (endEyePeriod - startFixationTimeoutPeriod)/ 10^6 >= fixationTimeoutDuration        % If time since start of fixation period > fixation timeout limit
        fixated_on_fixation_cross = 2;
        fixationTimeout = 1;
    end

    Screen('Flip', main_window);     % Update display with gaze point

end


Screen('DrawTexture', main_window, colouredFixationAOIsprite, [], fixAOIrect);
Screen('DrawTexture', main_window, colouredFixationTex, [], fixRect);
Screen('Flip', main_window);     % Present coloured fixation cross

WaitSecs(yellowFixationDuration);

tetio_stopTracking; % reset tracker in case it ballsed up during the fixation period
tetio_startTracking;

Screen('Flip', main_window);     % Show fixation cross without circle

% TODO: save trial data

RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
startITItime = Screen('Flip', main_window);

[~, keyCode, ~] = KbWait([], 2, startITItime + itiDuration);    % Wait for ITI duration while monitoring keyboard

RestrictKeysForKbCheck([]);   % Re-enable all keys

% If pressed C during ITI period, run an extraordinary calibration, otherwise
% carry on with the experiment
if sum(keyCode) > 0
    take_a_break(breakDuration, initialPause, 1, sessionPay, 1);
    [fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(main_window, fix_size, gazePointRadius);
end
   
    
Screen('Close', fixationTex);
Screen('Close', colouredFixationTex);
Screen('Close', fixationAOIsprite);
Screen('Close', colouredFixationAOIsprite);
Screen('Close', gazePointSprite);
Screen('Close', stimWindow);


end