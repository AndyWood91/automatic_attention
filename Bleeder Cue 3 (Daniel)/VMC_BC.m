
clear all


%Screen('Preference', 'SkipSyncTests', 2 );      % Skips the Psychtoolbox calibrations - REMOVE THIS WHEN RUNNING FOR REAL!

%Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen

Screen('CloseAll');


% Beeper;

clc;

functionFoldername = fullfile(pwd, 'functions');    % Generate file path for "functions" folder in current working directory
addpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders


global MainWindow screenNum
global scr_centre DATA datafilename p_number
global centOrCents
global screenRes
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier
global calibrationNum
global instrCondition
global exptSession
global starting_total starting_total_points runET
global orange green blue pink


screenNum = 0;

runET = 1;

bigMultiplier = 500;    % Points multiplier for trials with high-value distractor
smallMultiplier = 10;   % Points multiplier for trials with low-value distractor


if smallMultiplier == 1
    centOrCents = 'point';
else
    centOrCents = 'points';
end

starting_total = 0;

calibrationNum = 0;

% *************************************************************************
%
% Initialization and connection to the Tobii Eye-tracker
%
% *************************************************************************
if runET == 1
disp('Initializing tetio...');
tetio_init();

disp('Browsing for trackers...');
trackerinfo = tetio_getTrackers();
trackerId = trackerinfo(1).ProductId;

fprintf('Connecting to tracker "%s"...\n', trackerId);
tetio_connectTracker(trackerId)

currentFrameRate = tetio_getFrameRate;
fprintf('Connected!  Sample rate: %d Hz.\n', currentFrameRate);

if exist('BehavData', 'dir') == 0
    mkdir('BehavData');
end
if exist('CalibrationData', 'dir') == 0
    mkdir('CalibrationData');
end
if exist('EyeData', 'dir') == 0
    mkdir('EyeData');
end
end
instrCondition = 0;     % Set this so all participants get no instruction about omission

inputError = 1;

while inputError == 1
    inputError = 0;
    
    p_number = input('Participant number  ---> ');
    
    datafilename = ['BehavData\VMC_BC_2S_dataP', num2str(p_number)];
    
    
    if exist([datafilename, '.mat'], 'file') == 2
        disp(['Data for participant ', num2str(p_number),' already exist'])
        inputError = 1;
    end
    
    
end




    
    colBalance = 0;
    while colBalance < 1 || colBalance > 4
        colBalance = input('Counterbalance (1-4)---> ');
        if isempty(colBalance); colBalance = 0; end
    end
    
    p_age = input('Participant age ---> ');
    p_sex = 'a';
    while p_sex ~= 'm' && p_sex ~= 'f' && p_sex ~= 'M' && p_sex ~= 'F' && p_sex ~= 'o' && p_sex ~= 'O'
        p_sex = input('Participant gender (M/F/O) ---> ', 's');
        if isempty(p_sex);
            p_sex = 'a';
        elseif p_sex == 'o' || p_sex == 'O'
            p_genderInfo = input('(Optional) Please specify --> ', 's');
        elseif p_sex == 'm' || p_sex == 'M'
            p_genderInfo = 'Male';
        elseif p_sex == 'f' || p_sex == 'F'
            p_genderInfo = 'Female';
        end
    end
    
    p_hand = 'a';
    while p_hand ~= 'r' && p_hand ~= 'l' && p_hand ~= 'R' && p_hand ~= 'L'
        p_hand = input('Participant hand (R/L) ---> ','s');
        if isempty(p_hand); p_hand = 'a'; end
    end
    
    starting_total_points = 0;
    

DATA.subject = p_number;
DATA.counterbal = colBalance;
DATA.instrCondition = instrCondition;
DATA.age = p_age;
DATA.sex = p_sex;
DATA.genderInfo = p_genderInfo;
DATA.hand = p_hand;
DATA.start_time = datestr(now,0);
if runET == 1
DATA.trackerID = trackerId;
end
DATA.totalBonus = 0;
DATA.session_Bonus = 0;
DATA.session_Points = 0;
DATA.actualBonusSession = 0;


mkdir(['EyeData\', 'P', num2str(p_number)]);

datafilename = [datafilename, '.mat'];


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

setupMainWindowScreen;
HideCursor;
DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

% now set colors - UPDATED TO FOUR COLOURS 3/5/16 yet to check luminance
white = WhiteIndex(MainWindow);
black = BlackIndex(MainWindow);
gray = [70 70 70];   %[100 100 100]
orange = [193 95 30];
green = [54 145 65];
blue = [37 141 165]; %[87 87 255];
pink = [193 87 135];
yellow = [255 255 0];
Screen('FillRect',MainWindow, black);

distract_col = zeros(9,6);

distract_col(9,:) = [yellow gray];       % Practice colour
switch colBalance
    case 1
        distract_col(1,:) = [orange gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = [blue gray];      % Low-value distractor colour, second colour is the irrelevant distractor
        distract_col(3,:) = [green gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(4,:) = [pink gray];
        distract_col(5,:) = [orange blue];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(6,:) = [green pink];
        
        colourName = char('ORANGE','BLUE','GREEN','PINK');
    case 2
        distract_col(1,:) = [blue gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = [orange gray];      % Low-value distractor colour, second colour is the irrelevant distractor
        distract_col(3,:) = [pink gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(4,:) = [green gray];
        distract_col(5,:) = [blue orange];
        distract_col(6,:) = [pink green];
        colourName = char('BLUE','ORANGE','PINK','GREEN');
    case 3
        distract_col(1,:) = [green gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = [pink gray];      % Low-value distractor colour, second colour is the irrelevant distractor
        distract_col(3,:) = [orange gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(4,:) = [blue gray];
        distract_col(5,:) = [green pink];
        distract_col(6,:) = [orange blue];
        colourName = char('GREEN','PINK','ORANGE','BLUE');
    case 4
        distract_col(1,:) = [pink gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = [green gray];      % Low-value distractor colour, second colour is the irrelevant distractor
        distract_col(3,:) = [blue gray];      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(4,:) = [orange gray];
        distract_col(5,:) = [pink green];
        distract_col(6,:) = [blue orange];
        colourName = char('PINK','GREEN','BLUE','ORANGE');
end
distract_col(7,:) = [gray gray];
distract_col(8,:) = [gray gray];

% for i = 1 : 2
%     if sum(distract_col(i,:)) == sum([orange blue])
%         colName = 'ORANGE & BLUE       ';           % All entries need to have the same length. We'll strip the blanks off later.
%     elseif sum(distract_col(i,:)) == sum([pink green])
%         colName = 'PINK & GREEN        ';
%     end
%
%     if i == 1
%         colourName = char(colName);
%     else
%         colourName = char(colourName, colName);
%     end
% end

initialInstructions;

runCalibration;
pressSpaceToBegin;

[~] = runTrials(0);     % Practice phase

save(datafilename, 'DATA');


DrawFormattedText(MainWindow, 'Please let the experimenter know\n\nyou are ready to continue', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
KbWait([], 2);


exptInstructions;


RestrictKeysForKbCheck([KbName('c'), KbName('t')]);   % Only accept keypresses from keys C and t
KbWait([], 2);
[~, ~, keyCode] = KbCheck;      % This stores which key is pressed (keyCode)
keyCodePressed = find(keyCode, 1, 'first');     % If participant presses more than one key, KbCheck will create a keyCode array. Take the first element of this array as the response
keyPressed = KbName(keyCodePressed);    % Get name of key that was pressed
RestrictKeysForKbCheck([]); % Re-enable all keys

if keyPressed == 'c'
    runCalibration;
end

pressSpaceToBegin;

sessionPoints = runTrials(1);


    awareInstructions;
    awareTest;




sessionBonus = sessionPoints / 160;   % convert points into cents at rate of 13 000 points = $1. Updated 13/5.

sessionBonus = 10 * ceil(sessionBonus/10);        % ... round this value UP to nearest 10 cents
sessionBonus = sessionBonus / 100;    % ... then convert back to dollars



DATA.session_Bonus = sessionBonus;
DATA.session_Points = sessionPoints;

totalBonus = starting_total + sessionBonus;


    if totalBonus < 7.10        %check to see if participant earned less than $10.10; if so, adjust payment upwards
        actual_bonus_payment = 7.10;
    else
        actual_bonus_payment = totalBonus;
    end


DATA.totalBonus = totalBonus;
DATA.actualTotalBonus = actual_bonus_payment;



DATA.end_time = datestr(now,0);

save(datafilename, 'DATA');


    [~, ny, ~] = DrawFormattedText(MainWindow, ['SESSION COMPLETE\n\nPoints in this session = ', separatethousands(sessionPoints, ','), '\n\nTOTAL PAYMENT = $', num2str(actual_bonus_payment, '%0.2f')], 'center', 'center' , white, [], [], [], 1.4);



    fid1 = fopen('BehavData\_TotalBonus_summary.csv', 'a');
    fprintf(fid1,'%d,%f\n', p_number, actual_bonus_payment + starting_total);
    fclose(fid1);





DrawFormattedText(MainWindow, '\n\nPlease fetch the experimenter', 'center', ny , white, [], [], [], 1.5);

Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('q'));   % Only accept Q key to quit
KbWait([], 2);




rmpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders
Snd('Close');

Screen('Preference', 'SkipSyncTests',0);

Screen('CloseAll');

clear all
