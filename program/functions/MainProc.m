function [] = MainProc(main_window, screen_dimensions, DATA)

test_rectangle = [0 0 screen_dimensions(1, 1)*0.75 screen_dimensions(1, 2)*0.75];

runET = 0;

commandwindow;

if runET == 1
    GenericCalibration; runET = 1;
end

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

trialStructure = makeTrialStructure; % get the trial structure

% timeStart = GetSecs;  % Andy - in get_details
% 
% DATA = struct;  % Andy - passing in DATA from get_details
DATA.results = zeros(size(trialStructure,1),9); % # of rows, 7 columns (SEE END)
DATA.results(:,1:6) = trialStructure; % can write this part in now

fixEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
instEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
stimEG = cell(size(trialStructure,1),2); % data to be stored for stimulus presentation period.

filename = DATA.experiment.filename;
%% Andy - in get_details now
% %check if this subject and session has been run
% subNum = input('Enter participant number ---> ');
% app_home = cd;
% cd(app_home); 
% filename = strcat('Sub ', int2str(subNum));
% filePath = strcat(app_home,'/DATA/',filename);
% 
% if exist(strcat(filePath,'.mat'), 'file') > 0
%     strcat(filename, ' already exists - check program parameters and try again.')
%     return
% end
% 
% 
% % get participant details
% age = input('Enter your age ---> ');
% sex = input('Enter your gender (M/F) ---> ', 's' );
% hand = input('Are you left of right handed? (R/L) ---> ','s');
% language = input('Is English your first language? (Y/N) ---> ','s');
% start_time = datestr(now,0);
% DATA.details = {age sex hand language start_time};
% save(filePath,'DATA', '-v7.3'); % save DATA structure
%%

KbName('UnifyKeyNames');

% parameters
BGcol = [255 255 255];
iSize = 50; % Instruction stimulus size
stage2instAT = 161; % when Stage 2 instructions start
stage3instAT = 305; % when Stage 3 instructions start
checkAccAt = 41;
restEvery = 80;
fixSize = 10;
iCol = [150 150 150];
fixCol = [0 0 0];

% timings
fixTime = 1;   
fix_to_ITI_time = 0; 
instTime = 1;
timeoutLength = 3;
fbTime = 2;
ITI = .5; 

%% Andy - in PTB_screens now
% % ScreenRes = [2560 1440];
ScreenRes = [1080 675];
WinHeight = 675;
WinWidth = 1080;
MidH = WinWidth/2;
MidV = WinHeight/2;
winPos = zeros(1,4);
winPos([1 3]) = [(ScreenRes(1)-WinWidth)/2  ScreenRes(1)-(ScreenRes(1)-WinWidth)/2];
winPos([2 4]) = [ScreenRes(2)-WinHeight ScreenRes(2)];

% 
% % create windows and textures
% main_window = Screen ('OpenWindow', 0, BGcol, winPos);
% Screen('TextSize', main_window, 30);
% Screen('TextFont', main_window, 'Arial' );
% Screen('TextColor', main_window, [0 0 0]);


%% Andy - in create_gabors now
% gabor properties
GBsize = 400;
[myGrating, ~] = CreateProceduralGabor(main_window, GBsize, GBsize, 0, [BGcol/255 0], [], 5);
GBanglesStg1 = [95 265 95 265 90 270 90 270];
GBanglesStg2 = [95 265 95 265 95 265 95 265];
red = [0 1000 1000];
green = [1000 0 1000];
blue = [1000 1000 0];
grey = [500 500 500];
cols = [red; green; blue; grey];
cols = cols(randperm(4),:); % randomises order of colours
GBcols = [cols(1,:); cols(1,:); cols(2,:); cols(2,:); cols(3,:); cols(3,:); cols(4,:); cols(4,:)];
freq = .04; sc = 50; contrast = 20; aspectratio = 1.0;
GBprop = [0 freq, sc, contrast, aspectratio, 0, 0, 0];
GBpos = [50 MidV-GBsize/2 50+GBsize MidV+GBsize/2; WinWidth-50-GBsize MidV-GBsize/2 WinWidth-50 MidV+GBsize/2];
%% Setup Instruction Screens
for a = 1:11
    instruction_file = ['Instructions/Slide', int2str(a), '.jpg'];
    instruction_stimulus(a) = Screen('MakeTexture', main_window, imread(instruction_file));
end

%% 

if runET == 1
    tetio_startTracking;
end
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
        Screen('DrawTexture', main_window, instruction_stimulus(10));
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
            Screen('DrawTexture', main_window, instruction_stimulus(i), [], test_rectangle);
            Screen('Flip', main_window);
            [bin, ~, ~] = accKbWait;
        end
        trialAngles = GBanglesStg1; % intial gabor angles for Stage 1
    elseif trial == stage2instAT % Stage 2 instructions
        RestrictKeysForKbCheck(KbName('p'));            
        Screen('DrawTexture', main_window, instruction_stimulus(5), [], test_rectangle);
        Screen('Flip', main_window);
        [bin, ~, ~] = accKbWait;
        trialAngles = GBanglesStg2; % new gabor angles for Stage 2
    elseif trial == stage3instAT % Stage 3 instructions
        for i = 6:7
            if i == 7
                RestrictKeysForKbCheck(KbName('p'));
            end
            Screen('DrawTexture', main_window, instruction_stimulus(i), [], test_rectangle);
            Screen('Flip', main_window);
            [bin, ~, ~] = accKbWait;
        end
    end
    RestrictKeysForKbCheck([KbName('LeftArrow') KbName('RightArrow') KbName('q')]);
    
    % read in the trial events
    circleOrder = [trialStructure(trial,2) trialStructure(trial,3)];
    if trialStructure(trial,4) == 1;
        corResp = 79;
    else
        corResp = 80;
    end
    RevInst = trialStructure(trial,6);
    
    % ANDY - Gaze contingent fixation goes here
    
    % fixation dot
    Screen('FillOval', main_window , fixCol, [MidH-fixSize MidV-fixSize MidH+fixSize MidV+fixSize])    
    tempTS(1) = Screen('Flip', main_window);
    WaitSecs(fixTime);
    % screenshot
%     imageArray=Screen('GetImage', main_window);
%     imwrite(imageArray,'ss1','jpg')
    
    if fix_to_ITI_time > 0
        Screen('Flip', main_window); % blank 
        WaitSecs(fix_to_ITI_time + rand * .5);
    end
    
    % Draw normal/reversal instruction
    if RevInst == 0
        Screen('FillOval', main_window , iCol, [MidH-iSize MidV-iSize MidH+iSize MidV+iSize]);
    elseif RevInst == 1
        Screen('FillRect', main_window , iCol, [MidH-iSize MidV-iSize MidH+iSize MidV+iSize]);
    end
    Screen('FillOval', main_window , fixCol, [MidH-fixSize MidV-fixSize MidH+fixSize MidV+fixSize]); 
    tempTS(2) = Screen('Flip', main_window);
    WaitSecs(instTime);
        
    % Draw gabors on screen
    for c = 1:2
        Screen('DrawTexture', main_window, myGrating, [], GBpos(c,:), trialAngles(circleOrder(c)), [], [], GBcols(circleOrder(c),:), [], kPsychDontDoRotation, GBprop);
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
    if choice == 20
        sca;
        error('user termination, exiting program');
        break
    end
    
    tempTS(4) = Screen('Flip', main_window); % flip blank screen on after response  
    % error feedback
    if accuracy == 0
        Screen('DrawTexture', main_window, instruction_stimulus(8));
        Screen('Flip', main_window);
        WaitSecs(fbTime);  
    elseif timeout == 1
        Screen('DrawTexture', main_window, instruction_stimulus(9));
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
Screen('DrawTexture', main_window, instruction_stimulus(11));
Screen ('Flip', main_window);
save(filePath,'DATA'); % save results to disk
[~, ~] = accKbWait;

ShowCursor
clear
sca

end