
function exptInstructions

global MainWindow white
global bigMultiplier smallMultiplier medMultiplier
global centOrCents
global instrCondition
global softTimeoutDuration

instructStr1 = 'The rest of this experiment is similar to the trials you have just completed. On each trial, you should move your eyes to the DIAMOND shape as quickly and directly as possible.';

instructStr2 = 'From now on, you will be able to earn points for correct responses. This is important, because the number of points that you earn will determine how much you get paid as a bonus at the end of the experiment.\n\nDepending on how many points you earn, your bonus will typically be between $10 and $15.';

if smallMultiplier == 0
    instructStr2a = ['On each trial you will earn either 0 points, ', num2str(medMultiplier), ' points, or ', num2str(bigMultiplier), ' points. The amount that you earn will depend on how fast and accurately you move your eyes to the diamond shape.'];
else
    instructStr2a = ['On each trial you will earn either 0 points, ', num2str(smallMultiplier), ' ', centOrCents, ', ', num2str(medMultiplier), ' points, or ', num2str(bigMultiplier), ' points. The amount that you earn will depend on how fast and accurately you move your eyes to the diamond shape.'];
end  
    
instructStr3 = ['If you take longer than ', num2str(round(softTimeoutDuration * 1000)), ' milliseconds to move your eyes to the diamond, you will win no points. So you will need to move your eyes quickly!'];
instructStr4 = 'After each trial you will be told how many points you won, and your total points earned so far in this session.';

instructStr5 = 'On most trials, one of the circles will be coloured. If you accidentally look at this circle before you look at the diamond, you will receive no points. So you should try to move your eyes straight to the diamond.';
instructStr6 = 'You will not be told immediately if you looked at the coloured circle. Instead, at the end of each block of trials, you will be told how many times you looked at the coloured circle during that block. We will then subtract the amount that you won on those trials from your total.';

instructStr7 = 'At the end of the experiment, the total number of points that you have earned will be used to calculate your reward payment.\n\nMost participants are able to earn between $10 and $15 in this experiment.';

show_Instructions(1, instructStr1, .1);
show_Instructions(2, instructStr2, .1);
show_Instructions(2, instructStr2a, .1);
show_Instructions(3, instructStr3, .1);
show_Instructions(4, instructStr4, .1);

if instrCondition == 2
    show_Instructions(5, instructStr5, .1);
    show_Instructions(6, instructStr6, .1);
end

show_Instructions(7, instructStr7, .1);

DrawFormattedText(MainWindow, 'Please tell the experimenter when you are ready to begin', 'center', 'center' , white);
DrawFormattedText(MainWindow, 'EXPERIMENTER: Press C to recalibrate, T to continue with test', 'center', 800, white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck([]); % Re-enable all keys


end


function show_Instructions(instrTrial, insStr, instrPause)

global MainWindow scr_centre white


oldTextSize = Screen('TextSize', MainWindow, 46);
oldTextStyle = Screen('TextStyle', MainWindow, 1);

textTop = 150;
characterWrap = 60;
DrawFormattedText(MainWindow, insStr, 120, textTop, white, characterWrap, [], [], 1.2);


if instrTrial == 5
    ima1=imread('image3.jpg', 'jpg');
    y = size(ima1,1);
    x = size(ima1,2);
    exImageRect = [scr_centre(1) - x/2    scr_centre(2)-50    scr_centre(1) + x/2   scr_centre(2) + y - 50];
    Screen('PutImage', MainWindow, ima1, exImageRect); % put image on screen
elseif instrTrial == 6
    ima1=imread('fbScreenshot.jpg', 'jpg');
    y = size(ima1,1);
    x = size(ima1,2);
    exImageRect = CenterRectOnPoint([0, 0, x, y], scr_centre(1), scr_centre(2) + 200);
    Screen('PutImage', MainWindow, ima1, exImageRect); % put image on screen
end



Screen('Flip', MainWindow, []);


Screen('TextSize', MainWindow, oldTextSize);
Screen('TextStyle', MainWindow, oldTextStyle);

Screen('TextSize', MainWindow, 46);

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);


end