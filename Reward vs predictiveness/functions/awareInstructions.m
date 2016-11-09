
function awareInstructions()

global awareInstrPause

instructStr1 = 'The eye tracking task is now finished - it''s fine to take your chin out of the chin rest.\n\nDuring this task, the amount that you could win on each trial was determined by the colour of the coloured circle that appeared on that trial. \n\nIn the final phase we will test what you have learned about the relationship between the colour of the circle in the display and the amount that you could win for moving your eyes quickly and accurately to the diamond.';

show_Instructions(1, instructStr1, awareInstrPause);

end


function show_Instructions(~, insStr, instrPause)

global MainWindow scr_centre white gray

oldTextSize = Screen('TextSize', MainWindow, 46);
oldTextStyle = Screen('TextStyle', MainWindow, 1);

textTop = 150;
characterWrap = 60;
DrawFormattedText(MainWindow, insStr, 120, textTop, white, characterWrap, [], [], 1.2);

Screen('Flip', MainWindow, [], 1);

contButtonWidth = 1000;
contButtonHeight = 100;
contButtonTop = 880;

contButtonWin = Screen('OpenOffscreenWindow', MainWindow, gray, [0 0 contButtonWidth contButtonHeight]);
Screen('TextSize', contButtonWin, 38);
Screen('TextFont', contButtonWin, 'Arial');
DrawFormattedText(contButtonWin, 'Click here using the mouse to continue', 'center', 'center', white);

contButtonRect = [scr_centre(1) - contButtonWidth/2   contButtonTop  scr_centre(1) + contButtonWidth/2  contButtonTop + contButtonHeight];
Screen('DrawTexture', MainWindow, contButtonWin, [], contButtonRect);


WaitSecs(instrPause);

Screen('Flip', MainWindow);
ShowCursor('Arrow');


clickedContButton = 0;
while clickedContButton == 0
    [~, x, y, ~] = GetClicks(MainWindow, 0);

    if x > contButtonRect(1) && x < contButtonRect(3) && y > contButtonRect(2) && y < contButtonRect(4)
        clickedContButton = 1;
    end

end

Screen('TextSize', MainWindow, oldTextSize);
Screen('TextStyle', MainWindow, oldTextStyle);

Screen('Close', contButtonWin);

end