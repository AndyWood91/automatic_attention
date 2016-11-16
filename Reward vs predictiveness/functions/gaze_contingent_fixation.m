function [] = gaze_contingent_fixation(main_window, screen_dimensions)
% GAZE_CONTINGENT_FIXATION: 

global scr_centre DATA p_number
global stimLocs
global fix_aoi_radius
global softTimeoutDuration

scr_centre 

exptPhase = 0;

gamma = 0.2;    % Controls smoothing of displayed gaze location. Lower values give more smoothing

softTimeoutDuration = 0.6;     % soft timeout limit for later trials

timeoutDuration = [4, 2];     % [4, 2] timeout duration
fixationTimeoutDuration = 5;    % 5 fixation timeout duration

itiDuration = 1.2;            % 1.2
briefPause = 0.1;       % 0.1

yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
blankScreenAfterFixationPause = [0.6, 0.7, 0.8];        % [0.6, 0.7, 0.8] Blank screen after fixation disappears (sampled randomly)

initialPause = 2.5;   % 2.5 ***
breakDuration = 20;  % 20 ***

fixationFixationTime = 0.7;       % Time that fixation cross must be fixated for trial to begin

fixationPollingInterval = 0.03;    % Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display

junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated
junkGazeCycles = junkFixationPeriod / trialPollingInterval;


stimLocs = 6;       % Number of stimulus locations

fix_size = 20;      % This is the side length of the fixation cross
fix_aoi_radius = fix_size * 3;

gazePointRadius = 10;




% Create a rect for the fixation cross
fixRect = [screen_dimensions(2, 1) - fix_size/2    screen_dimensions(2, 2) - fix_size/2   screen_dimensions(2, 1) + fix_size/2   screen_dimensions(2, 2) + fix_size/2];


% Create a rect for the circular fixation AOI
fixAOIrect = [screen_dimensions(2, 1) - fix_aoi_radius    screen_dimensions(2, 2) - fix_aoi_radius   screen_dimensions(2, 1) + fix_aoi_radius   screen_dimensions(2, 2) + fix_aoi_radius];

%%
[diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);
<<<<<<< Updated upstream
=======
%%

% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
stimRect = zeros(stimLocs,4);

for i = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    stimRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
end

stimCentre = zeros(stimLocs, 2);
for i = 1 : stimLocs
    stimCentre(i,:) = [stimRect(i,1) + stim_size / 2,  stimRect(i,2) + stim_size / 2];
end
distractorAOIradius = 2 * (circ_diam / 2) * sin(pi / stimLocs);       % This gives circular AOIs that are tangent to each other
targetAOIradius = round(stim_size * 0.75);        % This gives a smaller AOI that will be used to determine target fixations on each trial

aoiRadius = zeros(stimLocs);


if exptPhase == 0
    numTrials = pracTrials;
    
    distractArray = zeros(1, pracTrials);
    distractArray(1 : pracTrials) = 7;
    
else
    numTrials = exptTrials;
    
%     distractArray = zeros(1,exptTrialsPerBlock);
%     
%     loopStart = 1;
%     
%     for jj = 1 : numDistractType      % Predictive and nonpredictive cue
%         loopEnd = loopStart + numDistractTrialsPerBlock - 1;
%         for ii = loopStart : loopEnd
%             distractArray(ii) = jj;
%         end
%         loopStart = loopEnd + 1;
%     end
%     
%     
%     for jj = numDistractType + 1 : numDistractType + numAbsentType      % Distractor absent trials
%         loopEnd = loopStart + numAbsentTrialsPerBlock - 1;
%         for ii = loopStart : loopEnd
%             distractArray(ii) = jj;
%         end
%         loopStart = loopEnd + 1;
%     end
    
end

blockPay = 0;
sessionPay = 0;

blockOmissionCounter = 0;
blockOmissionReward = 0;

% shuffled_distractArray = shuffleTrialorder(distractArray, exptPhase);   % Calls a function to shuffle trials

trialCounter = 0;
block = 1;
trials_since_break = 0;
DATA.fixationTimeouts = 0;
DATA.trialTimeouts = 0;
>>>>>>> Stashed changes

trialEGarray = zeros(timeoutDuration(exptPhase + 1) * 2 * 300, 27);    % Preallocate memory for eyetracking data. Tracker samples at 300Hz, so multiplying timeout duration by 2*300 means there will be plenty of slots

Screen('Flip', main_window);     % Clear anything that's on the screen

WaitSecs(initialPause);

% ANDY - want to take the fixation out of the loop (just do it once)
   
%     Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    Screen('DrawTexture', stimWindow, fixationTex, [], fixRect);
    
%     for i = 1 : stimLocs
%         Screen('FillOval', stimWindow, gray, stimRect(i,:), perfectDiam);       % Draw stimulus circles
%         aoiRadius(i) = distractorAOIradius;     % Set large AOIs around all locations (we'll change the AOI around the target location in a minute)
%     end
%     Screen('FillOval', stimWindow, distract_col(distractType,:), stimRect(distractLoc,:), perfectDiam);      % Draw coloured circle in distractor location
%     Screen('DrawTexture', stimWindow, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
%     aoiRadius(targetLoc) = targetAOIradius;     % Set a special (small) AOI around the target
    
    
    tetio_startTracking; % start recording
    
    
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
            
            
            [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts));    % Find mean gaze location during the previous polling interval
            
            gazeCycle = gazeCycle + 1;
            
            if validPoints > 0
                if gazeCycle <= junkGazeCycles
                    currentGazePoint = [eyeX, eyeY];        % If in junk period at start of trial, keep track of gaze location; this will determine starting point of gaze when the junk period ends
                else
                    currentGazePoint = (1 - gamma) * currentGazePoint + gamma * [eyeX, eyeY];       % Calculate smoothed gaze location using weighted moving average of current and previous locations
                    
                    Screen('DrawTexture', main_window, gazePointSprite, [], [currentGazePoint(1) - gazePointRadius, currentGazePoint(2) - gazePointRadius, currentGazePoint(1) + gazePointRadius, currentGazePoint(2) + gazePointRadius]);
                    Screen('DrawingFinished', main_window);
                    
                    stimSelected = checkEyesOnFixation(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                    
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
    
    tetio_stopTracking; % stop the tracker
    WaitSecs(2);
    

    
%     trialEnd = 0;
    timeOnLoc = zeros(1, stimLocs + 1);    % a slot for each stimulus location, and one for "everywhere else"
%     stimSelected = stimLocs + 1;
%     trialBadSamples = 0;
    trialEGarray(:,:) = 0;
%     gazeCycle = 0;
    arrayRowCounter = 2;    % Used to write EG data to the correct rows of an array. Starts at 2 because we write the first row in separately below (line marked ***)
    
%     Screen('DrawTexture', main_window, stimWindow);      % Copy stimuli to main window
%     
%     startTrialTime = Screen('Flip', main_window, [], 1);      % Present stimuli, and record start time (st) when they are presented.
%     
%     [lefteye, righteye, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
%     
%     startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the first eye tracking period
%     startEyeTrial = startEyePeriod;     % This will be used to judge timeouts below
%     
%     trialEGarray(1,:) = [double(ts(length(ts))), lefteye(length(ts),:), righteye(length(ts),:)];       % *** First row of saved EG array gives start time
%     
%     while trialEnd == 0
%         WaitSecs(trialPollingInterval);      % Pause between updates of eye position
%         [lefteye, righteye, ts, ~] = tetio_readGazeData;    % Get eye-tracker data since previous call
%         
%         if isempty(ts) == 0
%             
%             
%             [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts));    % Find mean gaze location during the previous polling interval
%             
%             endPoint = arrayRowCounter + length(ts) - 1;
%             trialEGarray(arrayRowCounter:endPoint,:) = [double(ts), lefteye, righteye];
%             arrayRowCounter = endPoint + 1;
%             
%             gazeCycle = gazeCycle + 1;
%             
%             if validPoints > 0
%                 stimSelected = checkEyesOnStim(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
%             else
%                 trialBadSamples = trialBadSamples + 1;
%                 stimSelected = stimLocs + 1;   % If no gaze detected, record gaze as "everywhere else"
%             end
%             
%             endEyePeriod = double(ts(end));     % Last entry in timestamp data gives end time of polling period
%             timeOnLoc(stimSelected) = timeOnLoc(stimSelected) + (endEyePeriod - startEyePeriod) / 10^6;   % Divided by 10^6 because eyetracker gives time in microseconds
%             startEyePeriod = endEyePeriod;      % Start of next polling period is end of the last one
%             
%         end
%         
%         if timeOnLoc(targetLoc) >= requiredFixationTime         % If fixated on target
%             trialEnd = 1;
%         elseif (endEyePeriod - startEyeTrial)/ 10^6 >= timeoutDuration(exptPhase + 1)        % If time since start of trial > timeout limit for this phase
%             trialEnd = 2;
%         end
%         
%     end
%     
%     rt = GetSecs - startTrialTime;      % Response time
%     
%     Screen('Flip', main_window);
%     
%     tetio_stopTracking; % stop the tracker
%     
%     trialPropGoodSamples = 1 - double(trialBadSamples) / double(gazeCycle);
%     
%     timeout = 0;
%     softTimeoutTrial = 0;
%     omissionTrial = 0;
%     trialPay = 0;
%     
%     if trialEnd == 2
%         timeout = 1;
%         % Beeper;
%         fbStr = 'TOO SLOW\n\nPlease try to look at the diamond more quickly';
%         
%     else
%         
%         fbStr = 'correct';
%         
%         
%         if exptPhase == 1       % If this is NOT practice
%             
%             if timeOnLoc(distractLoc) > omissionTimeLimit          % If people have looked at the distractor location (includes trials with no distractor actually presented)
%                 omissionTrial = 1;
%             end
%             
%             trialPay = winMultiplier(distractType);
%             
%             
%             if rt > softTimeoutDuration      % If RT is greater than the "soft" timeout limit, don't get reward (but also don't get explicit timeout feedback)
%                 softTimeoutTrial = 1;
%                 trialPay = 0;
%             end
%                
%             
%             if instrCondition == 1      % Standard omission condition
%                 
%                 if omissionTrial
%                     trialPay = 0;       % Looking at distractor causes immediate omission of reward
%                 end
%                 
%             else      % Summary feedback condition
%                 
%                 if omissionTrial
%                     blockOmissionCounter = blockOmissionCounter + 1;
%                     blockOmissionReward = blockOmissionReward + trialPay;   % record how much was won (in dollars) so we can take it off later on.
%                 end
%                 
%                 
%             end
%                 
%             
%             if trialPay == 1
%                 centCents = 'point';
%             else
%                 centCents = 'points';
%             end
%             
%             blockPay = blockPay + trialPay;
%             
%             if omissionTrial == 0
%                 sessionPay = sessionPay + trialPay;     % Need the if loop because trialPay may not be zero on an omission trial for the summary instructions group
%             end
%             
%             
%             fbStr = ['+', num2str(trialPay), ' ', centCents];
%             
%             if softTimeoutTrial == 1
%                 fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nToo slow'];
%             end
%                 
%             
%             Screen('TextSize', main_window, 35);
%             DrawFormattedText(main_window, [separatethousands(sessionPay, ','), ' points total'], 'center', 760, white);
%             
%         end
%     end
%     
%     
%     Screen('TextSize', main_window, 54);
%     DrawFormattedText(main_window, fbStr, 'center', 'center', yellow, [], [], [], 1.3);
%     
%     
%     Screen('Flip', main_window);
%     
%     WaitSecs(FB_duration);

    
    if exptPhase == 0
%         trialData = [trial, targetLoc, distractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, omissionTrial, rt, distractType, timeOnLoc(1,:)];
% 
%         if trial == 1
%             DATA.practrialInfo = zeros(numTrials, size(trialData,2));
%         end
%         
%         DATA.practrialInfo(trial,:) = trialData(:);

% ANDY - shouldn't need to add this back in if we're alreaedy saving the
% trail data elsewhere
    
    
    else
        trialData = [block, trial, trialCounter, trials_since_break, targetLoc, distractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, softTimeoutTrial, omissionTrial, rt, trialPay, sessionPay, distractType, timeOnLoc(1,:)];

        if trial == 1
            DATA.expttrialInfo = zeros(numTrials, size(trialData,2));
        end
        
        DATA.expttrialInfo(trial,:) = trialData(:);
        
        
        DATA.fixationTimeouts = DATA.fixationTimeouts + fixationTimeout;
        DATA.trialTimeouts = DATA.trialTimeouts + timeout;
        DATA.sessionPayment = sessionPay;
        
        EGdatafilename = ['EyeData\P', num2str(p_number), '\GazeDataP', num2str(p_number), 'T', num2str(trial), '.mat'];
        
        save(EGdatafilename, 'savedEGdata');
    end
    
    
    
    RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
    startITItime = Screen('Flip', main_window);
    
    [~, keyCode, ~] = KbWait([], 2, startITItime + itiDuration);    % Wait for ITI duration while monitoring keyboard
    
    RestrictKeysForKbCheck([]);   % Re-enable all keys
    
    % If pressed C during ITI period, run an extraordinary calibration, otherwise
    % carry on with the experiment
    if sum(keyCode) > 0
        take_a_break(breakDuration, initialPause, 1, sessionPay, 1);
        [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);
    end
   
    
    
 
Screen('Close', diamondTex);
Screen('Close', fixationTex);
Screen('Close', colouredFixationTex);
Screen('Close', fixationAOIsprite);
Screen('Close', colouredFixationAOIsprite);
Screen('Close', gazePointSprite);
Screen('Close', stimWindow);


end

function [eyeXpos, eyeYpos, sum_validities] = findMeanGazeLocation(lefteyeData, righteyeData, samples)
global screenRes

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
    eyeXpos = screenRes(1) * (lefteyeData(:,7)' * lefteyeValidity + righteyeData(:,7)' * righteyeValidity) / sum_validities;
    eyeYpos = screenRes(2) * (lefteyeData(:,8)' * lefteyeValidity + righteyeData(:,8)' * righteyeValidity) / sum_validities;

    if eyeXpos > screenRes(1)       % This guards against the possible bug that Tom identified where gaze can be registered off-screen
        eyeXpos = screenRes(1);
    end
    if eyeYpos > screenRes(2)
        eyeYpos = screenRes(2);
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


function detected = checkEyesOnFixation(x, y)
global scr_centre fix_aoi_radius

detected = 2;
if (x - screen_dimensions(2, 1))^2 + (y - screen_dimensions(2, 2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end



