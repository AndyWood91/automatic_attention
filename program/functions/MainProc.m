function [] = MainProc(main_window, screen_dimensions, instructions_slides, DATA, RGB)

test_rectangle = [0 0 screen_dimensions(1, 1) screen_dimensions(1, 2)];

runET = 1;

commandwindow;

if runET == 1
%     runPTBcalibration; runET = 1;  % ANDY - moved this to PTB screens
end

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

trialStructure = makeTrialStructure; % get the trial structure

DATA.results = zeros(size(trialStructure,1),9); % # of rows, 7 columns (SEE END)
DATA.results(:,1:6) = trialStructure; % can write this part in now

fixEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
instEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
stimEG = cell(size(trialStructure,1),2); % data to be stored for stimulus presentation period.

filename = DATA.experiment.filename;


KbName('UnifyKeyNames');

% parameters
BGcol = RGB('white');
iSize = 50; % Instruction stimulus size
stage2instAT = 161; % when Stage 2 instructions start
stage3instAT = 305; % when Stage 3 instructions start
checkAccAt = 41;
restEvery = 80;
fixSize = 10;
iCol = RGB('grey');
fixCol = RGB('black');

% timings
fixTime = 1;   
fix_to_ITI_time = 0; 
instTime = 1;
timeoutLength = 3;
fbTime = 2;
ITI = .5; 

%% Andy - in PTB_screens now
ScreenRes = [1080 675];
WinHeight = 675;
WinWidth = 1080;
MidH = WinWidth/2;
MidV = WinHeight/2;
winPos = zeros(1,4);
winPos([1 3]) = [(ScreenRes(1)-WinWidth)/2  ScreenRes(1)-(ScreenRes(1)-WinWidth)/2];
winPos([2 4]) = [ScreenRes(2)-WinHeight ScreenRes(2)];


%% Andy - in create_gabors now
% gabor properties
create_gabors;
[myGrating, ~] = CreateProceduralGabor(main_window, gabor_size, gabor_size, 0, [BGcol/255 0], [], 5);
freq = .04; sc = 50; contrast = 20; aspectratio = 1.0;
gabor_proportions = [0 freq, sc, contrast, aspectratio, 0, 0, 0];
GBpos = [50 MidV-gabor_size/2 50+gabor_size MidV+gabor_size/2; WinWidth-50-gabor_size MidV-gabor_size/2 WinWidth-50 MidV+gabor_size/2];

%%

tetio_startTracking;

restCount = 0;

HideCursor;

for trial = 1:size(trialStructure,1) % gets number of trials from size of finalTS
    
    tempTS = zeros(1,4);
    if trial == checkAccAt
        RestrictKeysForKbCheck(KbName('p'));
        d = DATA.results(1:checkAccAt,8);
        mean(d==0)
        mean(d==9999)
        DrawFormattedText(main_window, ['Your error rate so far is ', num2str(round(mean(d==0)*100)), ' %'], 'center', MidV-150);
        DrawFormattedText(main_window, ['Your timeout % so far is ', num2str(round(mean(d==9999)*100)), ' %'], 'center', MidV-50);
        DrawFormattedText(main_window, 'Please contact the experimenter', 'center', MidV+50);
        Screen('Flip', main_window);
        [~, ~] = accKbWait;
    end
    if restCount == restEvery
        restCount = 0;
        Screen('DrawTexture', main_window, instructions_slides(10));
        Screen('Flip', main_window);
        WaitSecs(30);
    end
    restCount = restCount + 1;
    
%     % SETTING INSTRUCTIONS
    RestrictKeysForKbCheck(KbName('space')); % space bar, this isn't working
    if trial == 1 % put up inst 1
        for i = 1:4
            if i == 4
                RestrictKeysForKbCheck(KbName('p'));
            end
            Screen('DrawTexture', main_window, instructions_slides(i), [], test_rectangle);
            Screen('Flip', main_window);
            [~, ~, ~] = accKbWait;
        end
        trialAngles = gabor_angles1; % intial gabor angles for Stage 1
    elseif trial == stage2instAT % Stage 2 instructions
        RestrictKeysForKbCheck(KbName('p'));            
        Screen('DrawTexture', main_window, instructions_slides(5), [], test_rectangle);
        Screen('Flip', main_window);
        [~, ~, ~] = accKbWait;
        trialAngles = gabor_angles2; % new gabor angles for Stage 2
    elseif trial == stage3instAT % Stage 3 instructions
        for i = 6:7
            if i == 7
                RestrictKeysForKbCheck(KbName('p'));
            end
            Screen('DrawTexture', main_window, instructions_slides(i), [], test_rectangle);
            Screen('Flip', main_window);
            [~, ~, ~] = accKbWait;
        end
    end
    RestrictKeysForKbCheck([KbName('LeftArrow') KbName('RightArrow') KbName('q')]);
    
    % read in the trial events
    circleOrder = [trialStructure(trial,2) trialStructure(trial,3)];
    if trialStructure(trial,4) == 1;
        corResp = 37;
    else
        corResp = 39;
    end
    
    RevInst = trialStructure(trial,6);
    
    if RevInst == 0
        RevInst = RGB('yellow');  % normal trial
    elseif RevInst == 1
        RevInst = RGB('green');  % reverse trial
    end
    
    gaze_contingent_fixation(main_window, screen_dimensions, RevInst);
    % TODO: this is redrawing and remaking the textures on every trial,
    % need to refactor it.
    
   
    % Draw gabors on screen
    for c = 1:2
        % I think this drawtexture command is drawing too small
        Screen('DrawTexture', main_window, myGrating, [], GBpos(c,:), trialAngles(circleOrder(c)), [], [], gabor_colours(circleOrder(c),:), [], kPsychDontDoRotation, gabor_proportions);
    end 
    tempTS(3) = Screen('Flip', main_window);
    
%     % screenshot
%     imageArray=Screen('GetImage', main_window);
%     imwrite(imageArray,'ss1','jpg')
    
    % wait for and record response
    RestrictKeysForKbCheck([KbName('LeftArrow') KbName('RightArrow') KbName('q')]);
    [keyCode, keyDown, timeout] = accKbWait(tempTS(3), timeoutLength); % Accurate measure response time, stored as keyDown. If timeout is used specify start time (1) and duration (2).
    RT = 1000 * (keyDown - tempTS(3)); % Response time in ms
    choice = find(keyCode==1);
    
    % determine feedback / accuracy
    % ANDY - this needs to be cleaned up
    accuracy = 0;
    if numel(choice) == 1 
        if corResp == choice
            accuracy = 1;
        end
    elseif numel(choice) == 2
        choice = 9999;
        accuracy = 0;
        RT = 9999;
    else % timeout
        choice = 9999;
        accuracy = 9999;
        RT = 9999;
    end
    
    % F10 to quit program - you might take this out of final version
    if choice == KbName('q');
        tetio_stopTracking;
        sca;
        error('user termination, exiting program');
    end
    
    tempTS(4) = Screen('Flip', main_window); % flip blank screen on after response  
    % error feedback
    if accuracy == 0
        Screen('DrawTexture', main_window, instructions_slides(8));
        Screen('Flip', main_window);
        WaitSecs(fbTime);  
    elseif timeout == 1
        Screen('DrawTexture', main_window, instructions_slides(9));
        Screen('Flip', main_window);
        WaitSecs(fbTime);
    end
    WaitSecs(ITI);
    
    % save response data
    DATA.results(trial,7) = choice;   %left or right key
    DATA.results(trial,8) = accuracy; % accuracy of the response
    DATA.results(trial,9) = RT; %Participant's reaction time (keydown - timeon)
    
    % parse and store EG data
    if runET == 1
        [leftEye, rightEye, TS, ~] = tetio_readGazeData;
        fixEG(trial,:) = parseEyeData(TS, leftEye, rightEye, tempTS(1), tempTS(2));
        instEG(trial,:) = parseEyeData(TS, leftEye, rightEye, tempTS(2), tempTS(3));
        stimEG(trial,:) = parseEyeData(TS, leftEye, rightEye, tempTS(3), tempTS(4));
    end
    
    save(DATA.experiment.filename,'DATA'); % save results to disk
    
end

if runET == 1
    DATA.fixEG = fixEG; DATA.instEG = instEG; DATA.stimEG = stimEG;
    tetio_stopTracking;
end
DATA.totalTimeMins = (GetSecs-timeStart)/60;
RestrictKeysForKbCheck(121); % F10 key
Screen('DrawTexture', main_window, instructions_slides(11));
Screen ('Flip', main_window);
save(filePath,'DATA'); % save results to disk
[~, ~] = accKbWait;

ShowCursor
clear
sca

end