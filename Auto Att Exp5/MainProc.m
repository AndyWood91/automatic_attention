function MainProc

runET = 0;

commandwindow;

if runET == 1
    GenericCalibration; runET = 1;
end

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

trialStructure = makeTrialStructure; % get the trial structure

timeStart = GetSecs;

DATA = struct;
DATA.results = zeros(size(trialStructure,1),9); % # of rows, 7 columns (SEE END)
DATA.results(:,1:6) = trialStructure; % can write this part in now

fixEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
instEG = cell(size(trialStructure,1),2); % data to be stored for fixation period.
stimEG = cell(size(trialStructure,1),2); % data to be stored for stimulus presentation period.

%check if this subject and session has been run
subNum = input('Enter participant number ---> ');
app_home = cd;
cd(app_home); 
filename = strcat('Sub ', int2str(subNum));
filePath = strcat(app_home,'/DATA/',filename);

if exist(strcat(filePath,'.mat'), 'file') > 0
    strcat(filename, ' already exists - check program parameters and try again.')
    return
end


% get participant details
age = input('Enter your age ---> ');
sex = input('Enter your gender (M/F) ---> ', 's' );
hand = input('Are you left of right handed? (R/L) ---> ','s');
language = input('Is English your first language? (Y/N) ---> ','s');
start_time = datestr(now,0);
DATA.details = {age sex hand language start_time};
save(filePath,'DATA', '-v7.3'); % save DATA structure

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

% ScreenRes = [2560 1440];
ScreenRes = [1920 1080];
WinHeight = 1080;
WinWidth = 1920;
MidH = WinWidth/2;
MidV = WinHeight/2;
winPos = zeros(1,4);
winPos([1 3]) = [(ScreenRes(1)-WinWidth)/2  ScreenRes(1)-(ScreenRes(1)-WinWidth)/2];
winPos([2 4]) = [ScreenRes(2)-WinHeight ScreenRes(2)];
winPos = [0 0 720 450];

% create windows and textures
MainWindow = Screen ('OpenWindow', 0, BGcol, winPos);
Screen('TextSize', MainWindow, 30);
Screen('TextFont', MainWindow, 'Arial' );
Screen('TextColor',MainWindow, [0 0 0]);

% gabor properties
GBsize = 400;
[myGrating, ~] = CreateProceduralGabor(MainWindow, GBsize, GBsize, 0, [BGcol/255 0], [], 5);
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

% Instructions 
for i = 1:7 
    Ftext = strcat('Instructions/Slide',int2str(i),'.jpg');
    instStim(i) =Screen('MakeTexture', MainWindow, double(imread(Ftext)));
end 
errorFB = Screen('MakeTexture', MainWindow, double (imread('Instructions/Slide8.jpg')));
errorTO = Screen('MakeTexture', MainWindow, double (imread('Instructions/Slide9.jpg')));
restScreen = Screen('MakeTexture', MainWindow, double (imread('Instructions/Slide10.jpg')));
debriefScreen = Screen('MakeTexture', MainWindow, double (imread('Instructions/Slide11.jpg')));

if runET == 1
    tetio_startTracking;
end
restCount = 0;

HideCursor

for trial = 1:size(trialStructure,1) % gets number of trials from size of finalTS
    
    tempTS = zeros(1,4);
    if trial == checkAccAt
        RestrictKeysForKbCheck(112); % F1 key
        d = DATA.results(1:checkAccAt,8);
        mean(d==0)
        mean(d==9999)
        DrawFormattedText(MainWindow, ['Your error rate so far is ', num2str(round(mean(d==0)*100)), ' %'], 'center', MidV-150);
        DrawFormattedText(MainWindow, ['Your timeout % so far is ', num2str(round(mean(d==9999)*100)), ' %'], 'center', MidV-50);
        DrawFormattedText(MainWindow, 'Please contact the experimenter', 'center', MidV+50);
        Screen('Flip', MainWindow);
        [~, ~] = accKbWait;
    end
    if restCount == restEvery
        restCount = 0;
        Screen('DrawTexture', MainWindow, restScreen);
        Screen('Flip', MainWindow);
        WaitSecs(30);
    end
    restCount = restCount + 1;
    
    % SETTING INSTRUCTIONS
    RestrictKeysForKbCheck(32); % space bar
    if trial == 1 % put up inst 1
        for i = 1:4
            if i == 4
                RestrictKeysForKbCheck(112); % F1 key
            end
            Screen('DrawTexture', MainWindow, instStim(i));
            Screen('Flip', MainWindow);
            [~, ~] = accKbWait;
        end
        trialAngles = GBanglesStg1; % intial gabor angles for Stage 1
    elseif trial == stage2instAT % Stage 2 instructions
        RestrictKeysForKbCheck(112); % F1 key            
        Screen('DrawTexture', MainWindow, instStim(5));
        Screen('Flip', MainWindow);
        [~, ~] = accKbWait;
        trialAngles = GBanglesStg2; % new gabor angles for Stage 2
    elseif trial == stage3instAT % Stage 3 instructions
        for i = 6:7
            if i == 7
                RestrictKeysForKbCheck(112); % F1 key
            end
            Screen('DrawTexture', MainWindow, instStim(i));
            Screen('Flip', MainWindow);
            [~, ~] = accKbWait;
        end
    end
    RestrictKeysForKbCheck([]); % opens all keys up for checking
    
    % read in the trial events
    circleOrder = [trialStructure(trial,2) trialStructure(trial,3)];
    if trialStructure(trial,4) == 1;
        corResp = 38;
    else
        corResp = 40;
    end
    RevInst = trialStructure(trial,6);
    
    % fixation dot
    Screen('FillOval', MainWindow , fixCol, [MidH-fixSize MidV-fixSize MidH+fixSize MidV+fixSize])    
    tempTS(1) = Screen('Flip', MainWindow);
    WaitSecs(fixTime);
    % screenshot
    imageArray=Screen('GetImage', MainWindow);
    imwrite(imageArray,'ss1','jpg')
    
    if fix_to_ITI_time > 0
        Screen('Flip', MainWindow); % blank 
        WaitSecs(fix_to_ITI_time + rand * .5);
    end
    
    % Draw normal/reversal instruction
    if RevInst == 0
        Screen('FillOval', MainWindow , iCol, [MidH-iSize MidV-iSize MidH+iSize MidV+iSize]);
    elseif RevInst == 1
        Screen('FillRect', MainWindow , iCol, [MidH-iSize MidV-iSize MidH+iSize MidV+iSize]);
    end
    Screen('FillOval', MainWindow , fixCol, [MidH-fixSize MidV-fixSize MidH+fixSize MidV+fixSize]); 
    tempTS(2) = Screen('Flip', MainWindow);
    WaitSecs(instTime);
        
    % Draw gabors on screen
    for c = 1:2
        Screen('DrawTexture', MainWindow, myGrating, [], GBpos(c,:), trialAngles(circleOrder(c)), [], [], GBcols(circleOrder(c),:), [], kPsychDontDoRotation, GBprop);
    end 
    tempTS(3) = Screen('Flip', MainWindow);
    
%     % screenshot
%     imageArray=Screen('GetImage', MainWindow);
%     imwrite(imageArray,'ss1','jpg')
    
    % wait for and record response
    RestrictKeysForKbCheck([38 40 121]); % wait for response (UP or DOWN or F10)
    [keyCode, keyDown, timeout] = accKbWait(tempTS(3), timeoutLength); % Accurate measure response time, stored as keyDown. If timeout is used specify start time (1) and duration (2).
    RT = 1000 * (keyDown - tempTS(3)); % Response time in ms
    choice = find(keyCode==1);
    
    % determine feedback / accuracy
    accuracy = 0;
    if numel(choice) == 1 
        if corResp == choice %DOWN 
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
    if choice == 121
        disp('someone pressed the F10 key')
        break
    end
    
    tempTS(4) = Screen('Flip', MainWindow); % flip blank screen on after response  
    % error feedback
    if accuracy == 0
        Screen('DrawTexture', MainWindow, errorFB);
        Screen('Flip', MainWindow);
        WaitSecs(fbTime);  
    elseif timeout == 1
        Screen('DrawTexture', MainWindow, errorTO);
        Screen('Flip', MainWindow);
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
    
    save(filePath,'DATA'); % save results to disk
    
end
if runET == 1
    DATA.fixEG = fixEG; DATA.instEG = instEG; DATA.stimEG = stimEG;
    tetio_stopTracking;
end
DATA.totalTimeMins = (GetSecs-timeStart)/60;
RestrictKeysForKbCheck(121); % F10 key
Screen('DrawTexture', MainWindow, debriefScreen);
Screen ('Flip', MainWindow);
save(filePath,'DATA'); % save results to disk
[~, ~] = accKbWait;

ShowCursor
clear
sca

end