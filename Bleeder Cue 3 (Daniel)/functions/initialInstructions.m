
function initialInstructions()

global MainWindow white

instructStr1 = 'On each trial a cross will appear inside a circle, and a yellow spot will show you where the computer thinks your eyes are looking. You should fix your eyes on the cross. After a short time the cross will turn yellow and the spot will disappear - this shows that the trial is about to start. You should keep your eyes fixed in the middle of the screen until the trial starts.';
instructStr2 = 'Then a set of shapes will appear; an example is shown below. Your task is to move your eyes to look at the DIAMOND shape as quickly and as directly as possible.';

show_Instructions(1, instructStr1);
show_Instructions(2, instructStr2);

Screen('TextSize', MainWindow, 32);
Screen('TextStyle', MainWindow, 1);
Screen('TextFont', MainWindow, 'Courier');

DrawFormattedText(MainWindow, 'Tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('c'));   % Only accept c key
KbWait([], 2);
Screen(MainWindow, 'Flip');
RestrictKeysForKbCheck([]); % Re-enable all keys

end

function show_Instructions(instrTrial, insStr)

global MainWindow scr_centre black white

x = 649;
y = 547;

exImageRect = [scr_centre(1) - x/2    scr_centre(2)-50    scr_centre(1) + x/2   scr_centre(2) + y - 50];

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar


instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instrWin, 32);
Screen('TextStyle', instrWin, 1);

[~, ~, instrBox] = DrawFormattedText(instrWin, insStr, 'centerblock', 'center' , white, 60, [], [], 1.5);
instrBox_width = instrBox(3) - instrBox(1);
instrBox_height = instrBox(4) - instrBox(2);
textTop = 100;
destInstrBox = [scr_centre(1) - instrBox_width / 2   textTop   scr_centre(1) + instrBox_width / 2   textTop +  instrBox_height];
Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);

if instrTrial == 1
    ima1=imread('image1.jpg', 'jpg');
    ima2=imread('image2.jpg', 'jpg');
    Screen('PutImage', MainWindow, ima1, exImageRect); % put image on screen
    Screen(MainWindow, 'Flip');
    KbWait([], 2);
    Screen('DrawTexture', MainWindow, instrWin, instrBox, destInstrBox);
    Screen('PutImage', MainWindow, ima2, exImageRect); % put image on screen
    
elseif instrTrial == 2
    ima1=imread('image3.jpg', 'jpg');
    Screen('PutImage', MainWindow, ima1, exImageRect); % put image on screen
    
end


Screen(MainWindow, 'Flip');

KbWait([], 2);

Screen('Close', instrWin);

end