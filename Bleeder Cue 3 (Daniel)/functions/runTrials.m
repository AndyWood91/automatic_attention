
function sessionPay = runTrials(exptPhase)

global MainWindow
global scr_centre DATA datafilename p_number
global distract_col
global white black gray yellow
global bigMultiplier smallMultiplier
global stim_size stimLocs
global stimCentre aoiRadius
global fix_aoi_radius
global instrCondition
global exptSession
global awareInstrPause
global softTimeoutDurationLate
global starting_total starting_total_points runET colourName

%%%%%%%%%%%%%%%%%%%%% CHANGELOG (STARTED 14/01/16) %%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gamma = 0.2;    % Controls smoothing of displayed gaze location. Lower values give more smoothing

softTimeoutDurationEarly = 1;    % soft timeout limit for early trials
softTimeoutDurationLate = 1;     % soft timeout limit for later trials

timeoutDuration = [4, 2];     % [4, 2] timeout duration
fixationTimeoutDuration = 5;    % 5 fixation timeout duration

iti = 0.7;            % 0.7
feedbackDuration = [0.7, 2.5, 1.5];       %[0.001, 0.001, 0.001]    [0.7, 2.5, 1.5]  FB duration: Practice, first block of expt phase, later in expt phase

yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
blankScreenAfterFixationPause = 0.15;        % UPDATED 14/01/16 IN LINE WITH FAILING ET AL. PAPER

initialPause = 2;   % 2 ***
breakDuration = 15;  % 15 ***
awareInstrPause = 16;  % 16

requiredFixationTime = 0.1;     % Time that target must be fixated for trial to be successful
omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial

fixationFixationTime = 0.7;       % Time that fixation cross must be fixated for trial to begin

fixationPollingInterval = 0.03;    % Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display

junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated
junkGazeCycles = junkFixationPeriod / trialPollingInterval;


numDistractType = 4;        % Three types of distractor present trial (high, low)
numDoubleDistractType = 2;
numDistractTrialsPerBlock = 1;
numDoubleDistractTrialsPerBlock = 4;


numAbsentType = 2;      % Two types of distractor absent trial (high reward and low reward)
numAbsentTrialsPerBlock = 2;        % 2


exptTrialsPerBlock = numDistractType * numDistractTrialsPerBlock + numDoubleDistractType * numDoubleDistractTrialsPerBlock + numAbsentType * numAbsentTrialsPerBlock;    % Gives 14

exptTrialsBeforeBreak = 4 * exptTrialsPerBlock;     % 4 * exptTrialsPerBlock = 56

exptTrialsBeforeCalibration = 7 * exptTrialsPerBlock;  % 7 * exptTrialsPerBlock

pracTrials = 8;    % 8
exptTrials = 50 * exptTrialsPerBlock;    % 50 * exptTrialsPerBlock = 700

stimLocs = 6;       % Number of stimulus locations
stim_size = 92;     % 92 Size of stimuli
perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

circ_diam = 200;    % Diameter of imaginary circle on which stimuli are positioned

fix_size = 20;      % This is the side length of the fixation cross
fix_aoi_radius = fix_size * 3;

gazePointRadius = 10;


winMultiplier = zeros(4,1);     % winMultiplier is a bad name now; it's actually the amount that they win
winMultiplier(1) = bigMultiplier;         % High-val distractors
winMultiplier(2) = bigMultiplier;     % Low-val distractors
winMultiplier(3) = smallMultiplier;         % no distractor, big win
winMultiplier(4) = smallMultiplier;     % no distractor, small win
winMultiplier(5) = bigMultiplier;
winMultiplier(6) = smallMultiplier;
winMultiplier(7) = 0; % no reward on grey trials
winMultiplier(8) = 0; % no reward on grey trials



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
    DATA.practrialInfo = zeros(pracTrials, 18);
    
    distractArray = zeros(1, pracTrials);
    distractArray(1 : pracTrials) = 9;
    
else
    numTrials = exptTrials;
    DATA.expttrialInfo = zeros(exptTrials, 27);
    distractArray = zeros(1,exptTrialsPerBlock);
    distractArray = [ones(1,numDistractTrialsPerBlock) ones(1,numDistractTrialsPerBlock)*2 ones(1,numDistractTrialsPerBlock)*3 ones(1,numDistractTrialsPerBlock)*4 ones(1,numDoubleDistractTrialsPerBlock)*5 ones(1,numDoubleDistractTrialsPerBlock)*6 ones(1,numAbsentTrialsPerBlock)*7 ones(1,numAbsentTrialsPerBlock)*8];  

end

sessionPay = 0;

shuffled_distractArray = shuffleTrialorder(distractArray, exptPhase);   % Calls a function to shuffle trials

trialCounter = 0;
block = 1;
trials_since_break = 0;
DATA.fixationTimeouts = 0;
DATA.trialTimeouts = 0;
omissionTracker = zeros(9,numDistractTrialsPerBlock);
omissionCounter = zeros(9,1);
trialEGarray = zeros(timeoutDuration(exptPhase + 1) * 2 * 300, 27);    % Preallocate memory for eyetracking data. Tracker samples at 300Hz, so multiplying timeout duration by 2*300 means there will be plenty of slots


WaitSecs(initialPause);

for trial = 1 : numTrials
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
    

    if exptPhase == 0
        FB_duration = feedbackDuration(1);
    else
        if block == 1
            FB_duration = feedbackDuration(2);
        else
            FB_duration = feedbackDuration(3);
        end
        
    end
    
    if trial <= exptTrialsPerBlock
        softTimeoutDuration = softTimeoutDurationEarly;
    else
        softTimeoutDuration = softTimeoutDurationLate;
    end
    
    targetLoc = randi(stimLocs);
    
    distractLoc = targetLoc;
    while distractLoc == targetLoc || abs(distractLoc - targetLoc) == 3 %distractor is either next to target or removed from target by 1
        distractLoc = randi(stimLocs);
    end
    
    distractType = shuffled_distractArray(trialCounter);
    omissionCounter(distractType,1) = omissionCounter(distractType,1) + 1;
    
    secondDistractLoc = targetLoc - (distractLoc - targetLoc);      %second distractor location is a mirror image of the first
    if secondDistractLoc < 1
        secondDistractLoc = secondDistractLoc + stimLocs;
    elseif secondDistractLoc > stimLocs
        secondDistractLoc = secondDistractLoc - stimLocs;
    end
    
    postFixationPause = blankScreenAfterFixationPause; %UPDATED IN LINE WITH FAILING ET AL. 14/01/16
    
    Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    %Screen('DrawTexture', stimWindow, fixationTex, [], fixRect); UPDATED
    %14/01/16 IN LINE WITH FAILING ET AL.
    
    for i = 1 : stimLocs
        Screen('FillOval', stimWindow, gray, stimRect(i,:), perfectDiam);       % Draw stimulus circles
        aoiRadius(i) = distractorAOIradius;     % Set large AOIs around all locations (we'll change the AOI around the target location in a minute)
    end
    Screen('FillOval', stimWindow, distract_col(distractType,1:3), stimRect(distractLoc,:), perfectDiam);      % Draw first coloured circle in distractor 1 location
    Screen('FillOval', stimWindow, distract_col(distractType,4:6), stimRect(secondDistractLoc,:), perfectDiam);  %Draw second coloured circle in distractor 2 location
    Screen('DrawTexture', stimWindow, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    
%     imageArray = Screen('GetImage', stimWindow);
%     fileName = ['Screen' num2str(distractType) '.jpg'];
%     imwrite(imageArray, fileName, 'jpg');
    
    aoiRadius(targetLoc) = targetAOIradius;     % Set a special (small) AOI around the target
    
    %     for i = 1 : stimLocs          % Draw AOI circles (remove this from final version)
    %         Screen('FrameOval', stimWindow, white, [stimCentre(i,1) - aoiRadius(i), stimCentre(i,2) - aoiRadius(i), stimCentre(i,1) + aoiRadius(i), stimCentre(i,2) + aoiRadius(i)], 1, 1);
    %     end
    
    tetio_startTracking; % start recording
    
    
    Screen('FillRect',MainWindow, black);
    
    
    Screen(MainWindow, 'Flip');     % Clear screen
    WaitSecs(iti);

    
    Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    timeOnFixation = zeros(2);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = 2;   % 1 = fixation cross, 2 = everywhere else
    fixated_on_fixation_cross = 0;
    fixationBadSamples = 0;
    fixationTimeout = 0;
    
    startFixationTime = Screen(MainWindow, 'Flip', [], 1);     % Present fixation cross
    
    [~, ~, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
    startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the trial. Need to convert to double so can divide by 10^6 later to change to seconds
    startFixationTimeoutPeriod = startEyePeriod;
    
    currentGazePoint = zeros(1,2);
    gazeCycle = 0;
    
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
        
        Screen(MainWindow, 'Flip');     % Update display with gaze point
        
    end
    
    fixationTime = GetSecs - startFixationTime;      % Length of fixation period in ms
    fixationPropGoodSamples = 1 - double(fixationBadSamples) / double(gazeCycle);
    
    Screen('DrawTexture', MainWindow, colouredFixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, colouredFixationTex, [], fixRect);
    Screen(MainWindow, 'Flip');     % Present coloured fixation cross
    
    WaitSecs(yellowFixationDuration);
    
    tetio_stopTracking; % reset tracker in case it ballsed up during the fixation period
    tetio_startTracking;
    
    FixOff = Screen(MainWindow, 'Flip');     % Show fixation cross without circle (and record off time)
    
    trialEnd = 0;
    timeOnLoc = zeros(1, stimLocs + 1);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = stimLocs + 1;
    trialBadSamples = 0;
    trialEGarray(:,:) = 0;
    gazeCycle = 0;
    arrayRowCounter = 2;    % Used to write EG data to the correct rows of an array. Starts at 2 because we write the first row in separately below (line marked ***)
    
    Screen('DrawTexture', MainWindow, stimWindow);      % Copy stimuli to main window
    
    WaitSecs(postFixationPause-(GetSecs-FixOff)); % UPDATED 14/01/16 to ensure that post-fixation pause is as close to 150ms as possible
    
    startTrialTime = Screen(MainWindow, 'Flip', [], 1);      % Present stimuli, and record start time (st) when they are presented.
    
    [lefteye, righteye, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
    
    startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the first eye tracking period
    startEyeTrial = startEyePeriod;     % This will be used to judge timeouts below
    
    trialEGarray(1,:) = [double(ts(length(ts))), lefteye(length(ts),:), righteye(length(ts),:)];       % *** First row of saved EG array gives start time
    trialGazeOrderArray(1,:) = [double(ts(length(ts))), 0];
    gazeNum = 1;
    while trialEnd == 0
        WaitSecs(trialPollingInterval);      % Pause between updates of eye position
        [lefteye, righteye, ts, ~] = tetio_readGazeData;    % Get eye-tracker data since previous call
        
        if isempty(ts) == 0
            
            
            [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts));    % Find mean gaze location during the previous polling interval
            
            endPoint = arrayRowCounter + length(ts) - 1;
            trialEGarray(arrayRowCounter:endPoint,:) = [double(ts), lefteye, righteye];
            arrayRowCounter = endPoint + 1;
            
            gazeCycle = gazeCycle + 1;
            
            if validPoints > 0
                stimSelected = checkEyesOnStim(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                if gazeNum == 1
                    trialGazeOrderArray(gazeNum,:) = [double(ts(end)),stimSelected];
                    gazeNum = gazeNum + 1;
                elseif gazeNum > 1
                    if stimSelected ~= trialGazeOrderArray(gazeNum-1,2);
                        trialGazeOrderArray(gazeNum,:) = [double(ts(end)), stimSelected];
                        gazeNum = gazeNum + 1;
                    end
                end
            else
                trialBadSamples = trialBadSamples + 1;
                stimSelected = stimLocs + 1;   % If no gaze detected, record gaze as "everywhere else"
            end
            
            endEyePeriod = double(ts(end));     % Last entry in timestamp data gives end time of polling period
            timeOnLoc(stimSelected) = timeOnLoc(stimSelected) + (endEyePeriod - startEyePeriod) / 10^6;   % Divided by 10^6 because eyetracker gives time in microseconds
            startEyePeriod = endEyePeriod;      % Start of next polling period is end of the last one
            
        end
        
        if timeOnLoc(targetLoc) >= requiredFixationTime         % If fixated on target
            trialEnd = 1;
        elseif (endEyePeriod - startEyeTrial)/ 10^6 >= timeoutDuration(exptPhase + 1)        % If time since start of trial > timeout limit for this phase
            trialEnd = 2;
        end
        
    end
    
    rt = GetSecs - startTrialTime;      % Response time
    
    Screen('Flip', MainWindow);
    
    tetio_stopTracking; % stop the tracker
    
    trialPropGoodSamples = 1 - double(trialBadSamples) / double(gazeCycle);
    
    timeout = 0;
    softTimeoutTrial = 0;
    omissionTrial = 0;
    trialPay = 0;
    lookedAtMainDistractor = 0;
    lookedAtSecondDistractor = 0;
    
    if trialEnd == 2
        timeout = 1;
        % Beeper;
        fbStr = 'TOO SLOW\n\nPlease try to look at the diamond more quickly';
        
    else
        
        fbStr = 'correct';
        
        
        if exptPhase == 1       % If this is NOT practice
            
            if timeOnLoc(distractLoc) > omissionTimeLimit          % If people have looked at the distractor location (includes trials with no distractor actually presented)
                switch distractType
                    case {2,4}
                        omissionTrial = omissionTracker(distractType, omissionCounter(distractType,1));
                        %%% yoked stuff
                    case {1,3}
                        omissionTrial = 1;
                        omissionTracker(distractType,omissionCounter(distractType,1)) = 1;
                    otherwise
                        omissionTrial = 1;
                end
                lookedAtMainDistractor = 1;
            else
                if distractType == 2 || distractType == 4 %if participant didnt look at the distractor, but due to have a yoked omission trial
                    omissionTrial = omissionTracker(distractType, omissionCounter(distractType,1));
                end
            end
            if timeOnLoc(secondDistractLoc) > omissionTimeLimit
                 lookedAtSecondDistractor = 1;
            end
            
            if rt > softTimeoutDuration      % If RT is greater than the "soft" timeout limit, don't get reward (but also don't get explicit timeout feedback)
                softTimeoutTrial = 1;
            end
            
            if omissionTrial ~= 1 && softTimeoutTrial ~= 1      % If this trial is NOT an omission trial or a soft timeout then reward, otherwise pay zero
                trialPay = winMultiplier(distractType);       % winMultiplier is a bad name now; it's actually the amount that they win
            else
                trialPay = 0;
            end
            
            if trialPay == 1
                centCents = 'point';
            else
                centCents = 'points';
            end
            
            sessionPay = sessionPay + trialPay;
            fbStr = ['+', num2str(trialPay), ' ', centCents];
            
            if softTimeoutTrial == 1
                fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nToo slow'];
                
            elseif lookedAtMainDistractor == 1
                
                if instrCondition == 1
                    fbStr = ['+', num2str(trialPay), ' ', centCents];
                else
                    if distractType <5                        
                        fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nYou looked at the ', strtrim(colourName(distractType,:)), ' circle'];
                    elseif distractType == 5
                        fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nYou looked at the ', strtrim(colourName(1,:)), ' circle'];
                    elseif distractType == 6
                        fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nYou looked at the ', strtrim(colourName(3,:)), ' circle'];
                    end
                end
            elseif lookedAtSecondDistractor == 1
                if distractType == 5
                    fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nYou looked at the ', strtrim(colourName(2,:)), ' circle'];
                elseif distractType == 6
                    fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nYou looked at the ', strtrim(colourName(4,:)), ' circle'];
                end
            end
            
            Screen('TextSize', MainWindow, 36);
            DrawFormattedText(MainWindow, [separatethousands(sessionPay+starting_total_points, ','), ' points total'], 'center', 760, white);
            
        end
    end
    
    
    Screen('TextSize', MainWindow, 52);
    DrawFormattedText(MainWindow, fbStr, 'center', 'center', yellow, [], [], [], 1.3);
    %DrawFormattedText(instrWin, insStr, 0, 0 , white, 60, [], [], 1.5);
    
    
    Screen('Flip', MainWindow);
    
    WaitSecs(FB_duration);

    
    Screen('Flip', MainWindow);
    WaitSecs(iti);
    
    
    
    if exptPhase == 0
        DATA.practrialInfo(trial,:) = [trial, targetLoc, distractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, omissionTrial, rt, distractType, timeOnLoc(1,:)];
    else
        DATA.expttrialInfo(trial,:) = [block, trial, trialCounter, trials_since_break, targetLoc, distractLoc, secondDistractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, softTimeoutTrial, omissionTrial, lookedAtMainDistractor, lookedAtSecondDistractor, rt, trialPay, sessionPay, distractType, timeOnLoc(1,:)];
        
        DATA.fixationTimeouts = DATA.fixationTimeouts + fixationTimeout;
        DATA.trialTimeouts = DATA.trialTimeouts + timeout;
        DATA.sessionPayment = sessionPay;
        
        EGdatafilename = ['EyeData\P', num2str(p_number), '\GazeDataP', num2str(p_number), 'T', num2str(trial), '.mat'];
        
        savedEGdata = trialEGarray(1:arrayRowCounter-1, :);     % Trim off empty, excess rows and save EG data
        save(EGdatafilename, 'savedEGdata');
        
        DATA.gazeOrderArray{trial,1} = trialGazeOrderArray;

        if mod(trial, exptTrialsPerBlock) == 0
            shuffled_distractArray = shuffleTrialorder(distractArray, exptPhase);     % Re-shuffle order of distractors
            trialCounter = 0;
            omissionCounter = zeros(8,1);
            DATA.blocksCompleted = block;
            block = block + 1;
            omissionTracker(2,:) = omissionTracker(1,randperm(length(omissionTracker(1,:)))); %randomise order of high val trials for irrelevant cue
            omissionTracker(4,:) = omissionTracker(3,randperm(length(omissionTracker(3,:)))); %randomise order of low val trials for irrelevant cue
            omissionTracker([1,3,5:8],:) = zeros(6,numDistractTrialsPerBlock);
            %Beeper;
        end
        
        if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
            save(datafilename, 'DATA');
            
            take_a_break(breakDuration, initialPause, 0, sessionPay); %removed the additional calibrations that would occur throughout expt 14/01/16
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




function take_a_break(breakDur, pauseDur, runCalib, totalPointsSoFar)

global MainWindow white

if runCalib == 0
    
    [~, ny, ~] = DrawFormattedText(MainWindow, ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\nRemember that you should be trying to move your eyes to the diamond as quickly and as accurately as possible!'], 'center', 'center', white, 50, [], [], 1.5);
    
    DrawFormattedText(MainWindow, ['Total so far = ', separatethousands(totalPointsSoFar, ','), ' points'], 'center', ny + 150, white, 50, [],[], 1.5);

    Screen(MainWindow, 'Flip');
    WaitSecs(breakDur);
    
else
    
    DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center', white);
    Screen(MainWindow, 'Flip');
    RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
    KbWait([], 2);
    RestrictKeysForKbCheck([]);   % Re-enable all keys
    runCalibration;
    
end

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

DrawFormattedText(MainWindow, 'Please put your chin back in the chinrest,\nand press the spacebar when you are ready to continue', 'center', 'center' , white, [], [], [], 1.5);
Screen(MainWindow, 'Flip');

KbWait([], 2);
Screen(MainWindow, 'Flip');

WaitSecs(pauseDur);

end


function [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fs, gpr)

global MainWindow
global fix_aoi_radius
global white black gray yellow
global stim_size

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

% This plots the points of a large diamond, that will be filled with colour
d_pts = [stim_size/2, 0;
    stim_size, stim_size/2;
    stim_size/2, stim_size;
    0, stim_size/2];


% Create an offscreen window, and draw the two diamonds onto it to create a diamond-shaped frame.
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, d_pts);

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', fixationTex, white, 0, fs/2, fs, fs/2, 2);
Screen('DrawLine', fixationTex, white, fs/2, 0, fs/2, fs, 2);


colouredFixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', colouredFixationTex, yellow, 0, fs/2, fs, fs/2, 4);
Screen('DrawLine', colouredFixationTex, yellow, fs/2, 0, fs/2, fs, 4);

% Create a sprite for the circular AOI around the fixation cross
fixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', fixationAOIsprite, white, [], 1, 1);   % Draw fixation aoi circle

colouredFixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', colouredFixationAOIsprite, yellow, [], 2, 2);   % Draw fixation aoi circle


% Create a marker for eye gaze
gazePointSprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 gpr*2 gpr*2]);
Screen('FillOval', gazePointSprite, yellow, [0 0 gpr*2 gpr*2], perfectDiam);       % Draw stimulus circles

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);
end
