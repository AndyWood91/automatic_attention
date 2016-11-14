function [] = gaze_contingent_fixation(main_window, screen_dimensions, fixation_colour)
% GAZE_CONTINGENT_FIXATION: 

RGB = RGB_colours;
black = RGB('black');
% ugly fix

exptPhase = 0;
gamma = 0.2;  % Controls smoothing of displayed gaze location. Lower values give more smoothing

timeoutDuration = [4, 2];     % [4, 2] timeout duration
fixationTimeoutDuration = 5;    % 5 fixation timeout duration

itiDuration = 1.2;            % 1.2
briefPause = 0.1;       % 0.1
yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
initialPause = 2.5;   % 2.5 ***
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


[fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow, main_window] = setupStimuli(main_window, fix_size, gazePointRadius);

trialEGarray = zeros(timeoutDuration(exptPhase + 1) * 2 * 300, 27);    % Preallocate memory for eyetracking data. Tracker samples at 300Hz, so multiplying timeout duration by 2*300 means there will be plenty of slots

Screen('Flip', main_window);     % Clear anything that's on the screen

WaitSecs(initialPause);

% ANDY - want to take the fixation out of the loop (just do it once)

   
Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
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

                stimSelected = checkEyesOnFixation(eyeX, eyeY, screen_dimensions);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"

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

fixationTime = GetSecs - startFixationTime;      % Length of fixation period in ms
fixationPropGoodSamples = 1 - double(fixationBadSamples) / double(gazeCycle);

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

function [eyeXpos, eyeYpos, sum_validities] = findMeanGazeLocation(lefteyeData, righteyeData, samples, screen_dimensions)

lefteyeValidity = zeros(samples,1);
righteyeValidity = zeros(samples,1);

for ii = 1 : samples
    if lefteyeData(ii,13) == 4 && righteyeData(ii,13) == 4
        lefteyeValidity(ii) = 0; righteyeValidity(ii) = 0;
    elseif lefteyeData(ii,13) == righteyeData(ii,13)
        lefteyeValidity(ii) = 0.5; righteyeValidity(ii) = 0.5;
    elseif lefteyeData(ii,13) < righteyeData(ii,13)
        lefteyeValidity(ii) = 1; righteyeValidity(ii) = 0;
    elseif lefteyeData(ii,13) > righteyeData(ii,13)
        lefteyeValidity(ii) = 0; righteyeValidity(ii) = 1;
    end
end

sum_validities = sum(lefteyeValidity) + sum(righteyeValidity);
if sum_validities > 0
    eyeXpos = screen_dimensions(1, 1) * (lefteyeData(:,7)' * lefteyeValidity + righteyeData(:,7)' * righteyeValidity) / sum_validities;
    eyeYpos = screen_dimensions(1, 2) * (lefteyeData(:,8)' * lefteyeValidity + righteyeData(:,8)' * righteyeValidity) / sum_validities;

    if eyeXpos > screen_dimensions(1, 1)       % This guards against the possible bug that Tom identified where gaze can be registered off-screen
        eyeXpos = screen_dimensions(1, 1);
    end
    if eyeYpos > screen_dimensions(1, 2)
        eyeYpos = screen_dimensions(1, 2);
    end

else
    eyeXpos = 0;
    eyeYpos = 0;
end

end




function detected = checkEyesOnStim(x, y)
global stimCentre aoiRadius stimLocs

detected = stimLocs + 1;
for s = 1 : stimLocs
    if (x - stimCentre(s,1))^2 + (y - stimCentre(s,2))^2 <= aoiRadius(s)^2
        detected = s;
        return
    end
end

end


function detected = checkEyesOnFixation(x, y, screen_dimensions)
global fix_aoi_radius

detected = 2;
if (x - screen_dimensions(2, 1))^2 + (y - screen_dimensions(2, 2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end
