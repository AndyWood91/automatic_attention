
function sessionPay = runTrials(exptPhase)

global MainWindow
global scr_centre DATA datafilename p_number
global distract_col
global white gray yellow
global bigMultiplier smallMultiplier medMultiplier
global stim_size stimLocs
global stimCentre aoiRadius
global fix_aoi_radius
global instrCondition
global softTimeoutDuration

Screen('BlendFunction', MainWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %This allows for transparent background on white dot

gamma = 0.2;    % Controls smoothing of displayed gaze location. Lower values give more smoothing

softTimeoutDuration = 0.6;     % soft timeout limit for later trials

timeoutDuration = [4, 2];     % [4, 2] timeout duration
fixationTimeoutDuration = 5;    % 5 fixation timeout duration

itiDuration = 1.2;            % 1.2
briefPause = 0.1;       % 0.1
feedbackDuration = [0.7, 2.5, 1.5];       %[0.001, 0.001, 0.001]    [0.7, 2.5, 1.5]  FB duration: Practice, first block of expt phase, later in expt phase

yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
blankScreenAfterFixationPause = [0.6, 0.7, 0.8];        % [0.6, 0.7, 0.8] Blank screen after fixation disappears (sampled randomly)

initialPause = 2.5;   % 2.5 ***
breakDuration = 20;  % 20 ***

requiredFixationTime = 0.1;     % Time that target must be fixated for trial to be successful
omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial

fixationFixationTime = 0.7;       % Time that fixation cross must be fixated for trial to begin

fixationPollingInterval = 0.03;    % Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display

junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated
junkGazeCycles = junkFixationPeriod / trialPollingInterval;


numDistractType = 4;        % Four types of distractor-present trial (P-med, P-med, NP-high, NP-low)
numDistractTrialsPerBlock = 5;     % 5
numAbsentType = 2;      % Two types of distractor absent trial (high reward and low reward)
numAbsentTrialsPerBlock = 2;        % 2


exptTrialsPerBlock = numDistractType * numDistractTrialsPerBlock + numAbsentType * numAbsentTrialsPerBlock;    % Gives 24

exptTrialsBeforeBreak = 2 * exptTrialsPerBlock;     % 2 * exptTrialsPerBlock = 48

exptTrialsBeforeCalibration = 99999;  % Used to be 10 * exptTrialsPerBlock

pracTrials = 8;    % 8
exptTrials = 20 * exptTrialsPerBlock;    % 20 * exptTrialsPerBlock = 480


stimLocs = 6;       % Number of stimulus locations
perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

circ_diam = 200;    % Diameter of imaginary circle on which stimuli are positioned

fix_size = 20;      % This is the side length of the fixation cross
fix_aoi_radius = fix_size * 3;

gazePointRadius = 10;


winMultiplier = zeros(numDistractType + numAbsentType, 1);     % winMultiplier is a bad name now; it's actually the amount that they win
winMultiplier(1) = medMultiplier;         % Predictive distractor
winMultiplier(2) = medMultiplier;     % Predictive distractor
winMultiplier(3) = bigMultiplier;         % NP distractor, big win
winMultiplier(4) = smallMultiplier;     % NP distractor, small win
winMultiplier(5) = bigMultiplier;         % No distractor, big win
winMultiplier(6) = smallMultiplier;     % No distractor, small win



% Create a rect for the fixation cross
fixRect = [scr_centre(1) - fix_size/2    scr_centre(2) - fix_size/2   scr_centre(1) + fix_size/2   scr_centre(2) + fix_size/2];


% Create a rect for the circular fixation AOI
fixAOIrect = [scr_centre(1) - fix_aoi_radius    scr_centre(2) - fix_aoi_radius   scr_centre(1) + fix_aoi_radius   scr_centre(2) + fix_aoi_radius];


[diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);


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
    
    distractArray = zeros(1,exptTrialsPerBlock);
    
    loopStart = 1;
    
    for jj = 1 : numDistractType      % Predictive and nonpredictive cue
        loopEnd = loopStart + numDistractTrialsPerBlock - 1;
        for ii = loopStart : loopEnd
            distractArray(ii) = jj;
        end
        loopStart = loopEnd + 1;
    end
    
    
    for jj = numDistractType + 1 : numDistractType + numAbsentType      % Distractor absent trials
        loopEnd = loopStart + numAbsentTrialsPerBlock - 1;
        for ii = loopStart : loopEnd
            distractArray(ii) = jj;
        end
        loopStart = loopEnd + 1;
    end
    
end

blockPay = 0;
sessionPay = 0;

blockOmissionCounter = 0;
blockOmissionReward = 0;

shuffled_distractArray = shuffleTrialorder(distractArray, exptPhase);   % Calls a function to shuffle trials

trialCounter = 0;
block = 1;
trials_since_break = 0;
DATA.fixationTimeouts = 0;
DATA.trialTimeouts = 0;

trialEGarray = zeros(timeoutDuration(exptPhase + 1) * 2 * 300, 27);    % Preallocate memory for eyetracking data. Tracker samples at 300Hz, so multiplying timeout duration by 2*300 means there will be plenty of slots

Screen('Flip', MainWindow);     % Clear anything that's on the screen


WaitSecs(initialPause);

for trial = 1 : numTrials
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
    

    if exptPhase == 0
        FB_duration = feedbackDuration(1);
    else
        FB_duration = feedbackDuration(2);
    end
    
   
    targetLoc = randi(stimLocs);
    
    distractLoc = targetLoc;
    while distractLoc == targetLoc || abs(distractLoc - targetLoc) == 1 || abs(distractLoc - targetLoc) == 5
        distractLoc = randi(stimLocs);
    end
    
    distractType = shuffled_distractArray(trialCounter);
    
    
    postFixationPause = blankScreenAfterFixationPause(randi(3));
    
%     Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    Screen('DrawTexture', stimWindow, fixationTex, [], fixRect);
    
    for i = 1 : stimLocs
        Screen('FillOval', stimWindow, gray, stimRect(i,:), perfectDiam);       % Draw stimulus circles
        aoiRadius(i) = distractorAOIradius;     % Set large AOIs around all locations (we'll change the AOI around the target location in a minute)
    end
    Screen('FillOval', stimWindow, distract_col(distractType,:), stimRect(distractLoc,:), perfectDiam);      % Draw coloured circle in distractor location
    Screen('DrawTexture', stimWindow, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    aoiRadius(targetLoc) = targetAOIradius;     % Set a special (small) AOI around the target
    
    
    tetio_startTracking; % start recording
    
    
    Screen('Flip', MainWindow);     % Clear screen
    WaitSecs(briefPause);

    
    Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    timeOnFixation = zeros(2);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = 2;   % 1 = fixation cross, 2 = everywhere else
    fixated_on_fixation_cross = 0;
    fixationBadSamples = 0;
    fixationTimeout = 0;
    
    currentGazePoint = zeros(1,2);
    gazeCycle = 0;

    startFixationTime = Screen('Flip', MainWindow, [], 1);     % Present fixation cross
    
    [~, ~, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
    startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the trial. Need to convert to double so can divide by 10^6 later to change to seconds
    startFixationTimeoutPeriod = startEyePeriod;
    
    
    while fixated_on_fixation_cross == 0
        Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);   % Redraw fixation cross and AOI, and draw gaze point on top of that
        Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
        
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
                    
                    Screen('DrawTexture', MainWindow, gazePointSprite, [], [currentGazePoint(1) - gazePointRadius, currentGazePoint(2) - gazePointRadius, currentGazePoint(1) + gazePointRadius, currentGazePoint(2) + gazePointRadius]);
                    Screen('DrawingFinished', MainWindow);
                    
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
        
        Screen('Flip', MainWindow);     % Update display with gaze point
        
    end
    
    fixationTime = GetSecs - startFixationTime;      % Length of fixation period in ms
    fixationPropGoodSamples = 1 - double(fixationBadSamples) / double(gazeCycle);
    
    Screen('DrawTexture', MainWindow, colouredFixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, colouredFixationTex, [], fixRect);
    Screen('Flip', MainWindow);     % Present coloured fixation cross
    
    WaitSecs(yellowFixationDuration);
    
    tetio_stopTracking; % reset tracker in case it ballsed up during the fixation period
    tetio_startTracking;
    
    Screen('Flip', MainWindow);     % Show fixation cross without circle
    
    tetio_stopTracking; % stop the tracker
    WaitSecs(2);
    

    
    trialEnd = 0;
    timeOnLoc = zeros(1, stimLocs + 1);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = stimLocs + 1;
    trialBadSamples = 0;
    trialEGarray(:,:) = 0;
    gazeCycle = 0;
    arrayRowCounter = 2;    % Used to write EG data to the correct rows of an array. Starts at 2 because we write the first row in separately below (line marked ***)
    
%     Screen('DrawTexture', MainWindow, stimWindow);      % Copy stimuli to main window
%     
%     startTrialTime = Screen('Flip', MainWindow, [], 1);      % Present stimuli, and record start time (st) when they are presented.
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
%     Screen('Flip', MainWindow);
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
%             Screen('TextSize', MainWindow, 35);
%             DrawFormattedText(MainWindow, [separatethousands(sessionPay, ','), ' points total'], 'center', 760, white);
%             
%         end
%     end
%     
%     
%     Screen('TextSize', MainWindow, 54);
%     DrawFormattedText(MainWindow, fbStr, 'center', 'center', yellow, [], [], [], 1.3);
%     
%     
%     Screen('Flip', MainWindow);
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
        
        savedEGdata = trialEGarray(1:arrayRowCounter-1, :);     % Trim off empty, excess rows and save EG data
        save(EGdatafilename, 'savedEGdata');
    end
    
    
    
    RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
    startITItime = Screen('Flip', MainWindow);
    
    [~, keyCode, ~] = KbWait([], 2, startITItime + itiDuration);    % Wait for ITI duration while monitoring keyboard
    
    RestrictKeysForKbCheck([]);   % Re-enable all keys
    
    % If pressed C during ITI period, run an extraordinary calibration, otherwise
    % carry on with the experiment
    if sum(keyCode) > 0
        take_a_break(breakDuration, initialPause, 1, sessionPay, 1);
        [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);
    end
   
    
    
    if exptPhase == 1

        if mod(trial, exptTrialsPerBlock) == 0
            shuffled_distractArray = shuffleTrialorder(distractArray, exptPhase);     % Re-shuffle order of distractors
            trialCounter = 0;
            DATA.blocksCompleted = block;
            block = block + 1;
        end
        
        if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
            save(datafilename, 'DATA');
            
            if mod(trial, exptTrialsBeforeCalibration) ~= 0;
                take_a_break(breakDuration, initialPause, 0, sessionPay, 0);
            else
                take_a_break(breakDuration, initialPause, 1, sessionPay, 0);
                [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);
            end
            
            blockPay = 0;
            blockOmissionCounter = 0;
            blockOmissionReward = 0;
            trials_since_break = 0;
        end
        
    end
    
    save(datafilename, 'DATA');
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
if (x - scr_centre(1))^2 + (y - scr_centre(2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end



function shuffArray = shuffleTrialorder(inArray,ePhase)

acceptShuffle = 0;

while acceptShuffle == 0
    shuffArray = inArray(randperm(length(inArray)));     % Shuffle order of distractors
    acceptShuffle = 1;   % Shuffle always OK in practice phase
    if ePhase == 1
        if shuffArray(1) > 2 || shuffArray(2) > 2
            acceptShuffle = 0;   % Reshuffle if either of the first two trials (which may well be discarded) are rare types
        end
    end
end

end




function take_a_break(breakDur, pauseDur, runCalib, totalPointsSoFar, extraordinaryCalib)

global MainWindow white

if extraordinaryCalib
    runPTBcalibration;
    
else    
    
    if runCalib == 0
        
        [~, ny, ~] = DrawFormattedText(MainWindow, ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\nRemember that you should be trying to move your eyes to the diamond as quickly and as accurately as possible!'], 'center', 'center', white, 50, [],[], 1.1);
        
        DrawFormattedText(MainWindow, ['Total so far = ', separatethousands(totalPointsSoFar, ','), ' points'], 'center', ny + 150, white, 50, [],[], 1.1);
        
        Screen(MainWindow, 'Flip');
        WaitSecs(breakDur);
        
    else
        
        DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center', white);
        Screen(MainWindow, 'Flip');
        RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
        KbWait([], 2);
        RestrictKeysForKbCheck([]);   % Re-enable all keys
        runPTBcalibration;
        
    end    
    
end

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

DrawFormattedText(MainWindow, 'Please put your chin back in the chinrest,\nand press the spacebar when you are ready to continue', 'center', 'center' , white, [], [], [], 1.1);
Screen(MainWindow, 'Flip');

KbWait([], 2);
Screen(MainWindow, 'Flip');

WaitSecs(pauseDur);

end
