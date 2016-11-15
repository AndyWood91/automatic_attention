clear all;

% global TESTING
global TESTING
TESTING = 1;

Screen('Preference', 'SkipSyncTests', 2);      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!
Screen('Preference', 'DefaultFontName', 'Courier New');
Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen

Screen('CloseAll');

clc;

functionFoldername = fullfile(pwd, 'functions');    % Generate file path for "functions" folder in current working directory
addpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders


global screenNum MainWindow
global scr_centre DATA datafilename p_number
global centOrCents
global screenRes
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier medMultiplier
global calibrationNum
global instrCondition
global starting_total
global awareInstrPause
global stim_size

RGB = RGB_colours();

commandwindow;

exptName = 'VMC_EG_pred_E2';

eyeVersion = false;
realVersion = false;

screenNum = 0;

bigMultiplier = 100;    % Points multiplier for trials with high-value distractor
smallMultiplier = 0;   % Points multiplier for trials with low-value distractor

medMultiplier = 50;

if smallMultiplier == 1
    centOrCents = 'point';
else
    centOrCents = 'points';
end


stim_size = 92;     % 92 Size of stimuli

starting_total = 0;

calibrationNum = 0;

global softTimeoutDuration
softTimeoutDuration = 0.6;     % soft timeout limit for later trials

if eyeVersion
    disp('Initializing tetio...');
    tetio_init();
    
    disp('Browsing for trackers...');
    trackerinfo = tetio_getTrackers();
    trackerId = trackerinfo(1).ProductId;
    
    fprintf('Connecting to tracker "%s"...\n', trackerId);
    tetio_connectTracker(trackerId)
    
    currentFrameRate = tetio_getFrameRate;
    fprintf('Connected!  Sample rate: %d Hz.\n', currentFrameRate);
    
    DATA.trackerID = trackerId;
    
end


if ~exist('CalibrationData', 'dir')
    mkdir('CalibrationData');
end
if ~exist('EyeData', 'dir')
    mkdir('EyeData');
end


instrCondition = 1;


if realVersion
    awareInstrPause = 18;  % 18

    inputError = 1;
    
    while inputError == 1
        inputError = 0;
        
        p_number = input('Participant number  ---> ');
        
        datafilename = ['BehavData\', exptName, '_dataP', num2str(p_number), '.mat'];
        
        if exist(datafilename, 'file') == 2
            disp(['Data for participant ', num2str(p_number),' already exist'])
            inputError = 1;
        end
        
    end
    
    colBalance = 0;
    while colBalance < 1 || colBalance > 2
        colBalance = input('Counterbalance (1-2)---> ');
        if isempty(colBalance); colBalance = 0; end
    end
    
    p_sex = 'a';
    while p_sex ~= 'm' && p_sex ~= 'f' && p_sex ~= 'M' && p_sex ~= 'F'
        p_sex = input('Participant gender (M/F) ---> ', 's');
        if isempty(p_sex); p_sex = 'a'; end
    end
    
    p_age = input('Participant age ---> ');
    
    p_hand = 'a';
    while p_hand ~= 'r' && p_hand ~= 'l' && p_hand ~= 'R' && p_hand ~= 'L'
        p_hand = input('Participant hand (R/L) ---> ','s');
        if isempty(p_hand); p_hand = 'a'; end
    end

else    % If debug version
   
    awareInstrPause = 0.5;  % 0.5

    p_number = 1;
    colBalance = 1;
    p_sex = 'm';
    p_age = 123;
    p_hand = 'r';
    datafilename = ['BehavData\', exptName, '_dataP', num2str(p_number), '.mat'];

end

DATA.subject = p_number;
DATA.instrCondition = instrCondition;
DATA.counterbal = colBalance;
DATA.age = p_age;
DATA.sex = p_sex;
DATA.hand = p_hand;
DATA.start_time = datestr(now,0);


DATA.session_Bonus = 0;
DATA.session_Points = 0;
DATA.actualBonusSession = 0;
DATA.totalBonus = 0;

mkdir('EyeData', ['P', num2str(p_number)]);


% *******************************************************


KbName('UnifyKeyNames');    % Important for some reason to standardise keyboard input across platforms / OSs.


% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
DATA.rSeed = randSeed;
rng(randSeed);

% Get screen resolution, and find location of centre of screen
[scrWidth, scrHeight] = Screen('WindowSize',screenNum);
screenRes = [scrWidth scrHeight];
scr_centre = screenRes / 2;

% now set colors
white = [255,255,255];
black = [0,0,0];
gray = [70 70 70];   %[100 100 100]
red = [255 0 0];
green = [0 143 0];
blue = [87 87 255];
yellow = [255 255 0];

global bgdColour
bgdColour = black;

% [MainWindow, off_window, screen_dimensions] = PTB_screens(RGB('white'), RGB('black'), true);

MainWindow = Screen(screenNum, 'OpenWindow', bgdColour);
Screen('TextFont', MainWindow, 'Courier New');
Screen('TextSize', MainWindow, 46);
Screen('TextStyle', MainWindow, 1);


HideCursor;
DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));


numColourTypes = 7;

distract_col = zeros(numColourTypes,3);

distract_col(7,:) = yellow;       % Practice colour
if colBalance == 1
    distract_col(1,:) = red;      % P distractor colour
    distract_col(2,:) = red;      % P distractor colour
    distract_col(3,:) = blue;      % NP distractor colour
    distract_col(4,:) = blue;      % NP distractor colour
elseif colBalance == 2
    distract_col(1,:) = blue;      % P distractor colour
    distract_col(2,:) = blue;      % P distractor colour
    distract_col(3,:) = red;      % NP distractor colour
    distract_col(4,:) = red;      % NP distractor colour
end

distract_col(5,:) = gray;
distract_col(6,:) = gray;


colourName = cell(numColourTypes,1);

for ii = 1 : length(colourName)
    if distract_col(ii,:) == red
        colourName(ii) = {'RED'};
    elseif distract_col(ii,:) == green
        colourName(ii) = {'GREEN'};
    elseif distract_col(ii,:) == blue
        colourName(ii) = {'BLUE'};
    elseif distract_col(ii,:) == yellow
        colourName(ii) = {'YELLOW'};
    elseif distract_col(ii,:) == gray
        colourName(ii) = {'GRAY'};
    end
end

commandwindow;
% initialInstructions;

if eyeVersion
    runPTBcalibration(MainWindow);
end

% pressSpaceToBegin;

gaze_contingent_fixation(MainWindow);
% [~] = runTrials(0);     % ANDY - this now just shows the fixation cross

% save(datafilename, 'DATA');


% DrawFormattedText(MainWindow, 'Please let the experimenter know\n\nyou are ready to continue', 'center', 'center' , white);
% Screen(MainWindow, 'Flip');
% 
% RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
% KbWait([], 2);
% 
% 
% exptInstructions;
% 
% 
% RestrictKeysForKbCheck([KbName('c'), KbName('t')]);   % Only accept keypresses from keys C and t
% KbWait([], 2);
% [~, ~, keyCode] = KbCheck;      % This stores which key is pressed (keyCode)
% keyCodePressed = find(keyCode, 1, 'first');     % If participant presses more than one key, KbCheck will create a keyCode array. Take the first element of this array as the response
% keyPressed = KbName(keyCodePressed);    % Get name of key that was pressed
% RestrictKeysForKbCheck([]); % Re-enable all keys
% 
% if keyPressed == 'c'
%     if eyeVersion
%         runPTBcalibration;
%     end
% end
% 
% pressSpaceToBegin;
% 
% sessionPoints = runTrials(1);
% 
% 
% awareInstructions;
% awareTest;
% 
% 
% sessionBonus = 100 * (10 + (sessionPoints - 14400)/1920);   % convert points into cents at rate based on pilot testing
% 
% sessionBonus = 10 * ceil(sessionBonus/10);        % ... round this value UP to nearest 10 cents
% sessionBonus = sessionBonus / 100;    % ... then convert to dollars
% 
% if sessionBonus < 7.10        %check to see if participant earned less than $7.10; if so, adjust payment upwards
%     actual_bonus_payment = 7.10;
% elseif sessionBonus > 15.10
%     actual_bonus_payment = 15.10;
% else
%     actual_bonus_payment = sessionBonus;
% end
% 
% DATA.session_Bonus = sessionBonus;
% DATA.session_Points = sessionPoints;
% DATA.actualBonusSession = actual_bonus_payment;
% DATA.totalBonus = actual_bonus_payment + starting_total;
% DATA.end_time = datestr(now,0);
% 
% save(datafilename, 'DATA');
% 
% 
% [~, ny, ~] = DrawFormattedText(MainWindow, ['SESSION COMPLETE\n\nPoints earned = ', separatethousands(sessionPoints, ',')], 'center', 'center' , white);
% [~, ny, ~] = DrawFormattedText(MainWindow, ['\n\n\nTOTAL CASH BONUS = $', num2str(actual_bonus_payment + starting_total, '%0.2f')], 'center', ny, yellow);
% 
% 
% fid1 = fopen('BehavData\_TotalBonus_summary.csv', 'a');
% fprintf(fid1,'%d,%f\n', p_number, actual_bonus_payment + starting_total);
% fclose(fid1);
% 
% 
% 
% 
% 
% DrawFormattedText(MainWindow, '\n\n\nPlease fetch the experimenter', 'center', ny , white);
% 
% Screen(MainWindow, 'Flip');
% 
% RestrictKeysForKbCheck(KbName('ESCAPE'));   % Only accept ESC key to quit
% KbWait([], 2);


rmpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders
Snd('Close');
Screen('Preference', 'SkipSyncTests',0);
Screen('CloseAll');
clear all;
