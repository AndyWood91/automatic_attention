function awareTest()

global MainWindow scr_centre DATA datafilename
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier medMultiplier
global centOrCents
global stim_size


awareTest_iti = 1;

testColours = 2;

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed


valButtonWidth = 300;
valButtonHeight = 130;
valButtonTop = 470;
valButtonDisplacement = 400;


confButtons = 5;
confButtonWidth = 100;
confButtonHeight = 100;
confButtonTop = 820;
confButtonBetween = 150;


valButtonWinNum = 3;
valButtonWin = zeros(valButtonWinNum,1);
for i = 1 : valButtonWinNum
    valButtonWin(i) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 valButtonWidth valButtonHeight]);
    Screen('FillRect', valButtonWin(i), gray);
    Screen('TextSize', valButtonWin(i), 40);
    Screen('TextFont', valButtonWin(i), 'Calibri');
end


DrawFormattedText(valButtonWin(1), [num2str(smallMultiplier), ' ', centOrCents], 'center', 'center', yellow);
DrawFormattedText(valButtonWin(2), [num2str(medMultiplier), ' points'], 'center', 'center', yellow);
DrawFormattedText(valButtonWin(3), [num2str(bigMultiplier), ' points'], 'center', 'center', yellow);

valButtonRect = zeros(valButtonWinNum,4);
valButtonRect(1,:) = [scr_centre(1) - valButtonWidth/2 - valButtonDisplacement   valButtonTop   scr_centre(1) + valButtonWidth/2 - valButtonDisplacement  valButtonTop + valButtonHeight];
valButtonRect(2,:) = [scr_centre(1) - valButtonWidth/2   valButtonTop   scr_centre(1) + valButtonWidth/2   valButtonTop + valButtonHeight];
valButtonRect(3,:) = [scr_centre(1) - valButtonWidth/2 + valButtonDisplacement   valButtonTop   scr_centre(1) + valButtonWidth/2 + valButtonDisplacement  valButtonTop + valButtonHeight];


confButtonWin = zeros(confButtons,1);
confButtonRect = zeros(confButtons, 4);
for i = 1 : confButtons
    confButtonWin(i) = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 confButtonWidth confButtonHeight]);
    Screen('FillRect', confButtonWin(i), gray);
    Screen('TextFont', confButtonWin(i), 'Arial');
    Screen('TextSize', confButtonWin(i), 46);
    DrawFormattedText(confButtonWin(i), num2str(i), 'center', 'center', white);
    
    confButtonRect(i,:) = [scr_centre(1) + confButtonWidth * (i - 1 - confButtons/2) + confButtonBetween * (i-1 - (confButtons - 1)/2)    confButtonTop    scr_centre(1) + confButtonWidth * (i - 1 - confButtons/2) + confButtonBetween * (i-1 - (confButtons - 1)/2) + confButtonWidth    confButtonTop + confButtonHeight];
    
end


instructStr2 = 'Use the mouse to select the appropriate amount';
instructStr3 = 'How confident are you of this choice?';

instructStr4 = 'Not at all\nconfident';
instructStr5 = 'Very\nconfident';

instructStr4Win = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instructStr4Win, 30);
Screen('TextFont', instructStr4Win, 'Arial');
[~,~,instr4boundsRect] = DrawFormattedText(instructStr4Win, instructStr4, 'center', 'center', white, [], [], [], 1.3);
instr4width = instr4boundsRect(3) -  instr4boundsRect(1);
instr4height = instr4boundsRect(4) -  instr4boundsRect(2);

instructStr5Win = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instructStr5Win, 30);
Screen('TextFont', instructStr5Win, 'Arial');
[~,~,instr5boundsRect] = DrawFormattedText(instructStr5Win, instructStr5, 'center', 'center', white, [], [], [], 1.3);
instr5width = instr5boundsRect(3) -  instr5boundsRect(1);
instr5height = instr5boundsRect(4) -  instr5boundsRect(2);



DATA.awareTestInfo = zeros(testColours, 4);



% Create and shuffle the test trial types

trialOrder = [1, 3];
trialOrder = trialOrder(randperm(length(trialOrder)));


ShowCursor('Arrow');


for trial = 1 : testColours
    
    instructStr1 = ['What amount were you most likely to win for quickly and accurately moving your eyes to the diamond when one of the circles was ', char(colourName(trialOrder(trial))),'?'];
    
    DrawFormattedText(MainWindow, instructStr1, 'center', 50, white, 50, [], [], 1.1);
    oldTextSize = Screen('TextSize', MainWindow, 34);
    DrawFormattedText(MainWindow, instructStr2, 'center', 390, white);
    Screen('TextSize', MainWindow, oldTextSize);
    
    circle_top = 240;	% Position of top of sample circle
    Screen('FillOval', MainWindow, distract_col(trialOrder(trial),:), [scr_centre(1) - stim_size / 2    circle_top   scr_centre(1) + stim_size / 2    circle_top + stim_size], perfectDiam);      % Draw circle
    for i = 1 : valButtonWinNum
        Screen('DrawTexture', MainWindow, valButtonWin(i), [], valButtonRect(i,:));
    end
    
    Screen('Flip', MainWindow, [], 1);
    
    
    for i = 1 : confButtons
        Screen('DrawTexture', MainWindow, confButtonWin(i), [], confButtonRect(i,:));
    end
    
    rate_instr_below = 30;
    Screen('DrawTexture', MainWindow, instructStr4Win, instr4boundsRect, [confButtonRect(1,1) + confButtonWidth/2 - instr4width/2     confButtonTop + confButtonHeight + rate_instr_below   confButtonRect(1,1) + confButtonWidth/2 + instr4width/2    confButtonTop + confButtonHeight + rate_instr_below + instr4height]);
    Screen('DrawTexture', MainWindow, instructStr5Win, instr5boundsRect, [confButtonRect(5,1) + confButtonWidth/2 - instr5width/2     confButtonTop + confButtonHeight + rate_instr_below   confButtonRect(5,1) + confButtonWidth/2 + instr5width/2    confButtonTop + confButtonHeight + rate_instr_below + instr5height]);
    
    
    Screen('FillRect', MainWindow, black, [0, circle_top + stim_size + 5, 1920, valButtonTop - 50]);    % Cover up instr2
    
    
    clickedValButton = 0;
    while clickedValButton == 0
        [~, x, y, ~] = GetClicks(MainWindow, 0);
        for i = 1 : valButtonWinNum
            if x > valButtonRect(i,1) && x < valButtonRect(i,3) && y > valButtonRect(i,2) && y < valButtonRect(i,4)
                clickedValButton = i;
            end
        end
    end
    
    if clickedValButton == 1
        Screen('FillRect', MainWindow, black, valButtonRect(2,:));	% Hide button that hasn't been clicked
        Screen('FillRect', MainWindow, black, valButtonRect(3,:));	% Hide button that hasn't been clicked
    elseif clickedValButton == 2
        Screen('FillRect', MainWindow, black, valButtonRect(1,:));
        Screen('FillRect', MainWindow, black, valButtonRect(3,:));
    elseif clickedValButton == 3
        Screen('FillRect', MainWindow, black, valButtonRect(1,:));
        Screen('FillRect', MainWindow, black, valButtonRect(2,:));
    end
    
    
    DrawFormattedText(MainWindow, instructStr3, 'center', confButtonTop - 100, white);
    
    
    Screen('Flip', MainWindow);
    
    clickedConfButton = 0;
    while clickedConfButton == 0
        [~, x, y, ~] = GetClicks(MainWindow, 0);
        for i = 1 : confButtons
            if x > confButtonRect(i,1) && x < confButtonRect(i,3) && y > confButtonRect(i,2) && y < confButtonRect(i,4)
                clickedConfButton = i;
            end
        end
    end
    
    
    DATA.awareTestInfo(trial,:) = [trial, trialOrder(trial), clickedValButton, clickedConfButton];
    
    Screen('Flip', MainWindow);
    
    WaitSecs(awareTest_iti);
end

save(datafilename, 'DATA');

for i = 1:valButtonWinNum
    Screen('Close', valButtonWin(i));
end
for i = 1:confButtons
    Screen('Close', confButtonWin(i));
end

Screen('Close', instructStr4Win);
Screen('Close', instructStr5Win);

end