
bgcol = 255;

MainWindow = Screen('OpenWindow', 0, [bgcol bgcol bgcol], [200 200 1600 1000]);

g = bgcol/255;
for i = 1
    [myGrating, myGratingRect] = CreateProceduralGabor(MainWindow, 400, 400, 0, [g g g 0], [], 5);
    angle1 = 2;
    angle2 = 178;
    pos1 = [200 200 600 600];
    pos2 = [800 200 1200 600];
    colour1 = [0 0 1000];
    colour2 = [500 500 500];    
    sc = 50;
    freq = .04;
    tilt = 0;
    contrast = 5;
    aspectratio = 1.0;
    Screen('DrawTexture', MainWindow, myGrating, [], pos1, angle1, [], [], colour1, [], kPsychDontDoRotation, [0, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('DrawTexture', MainWindow, myGrating, [], pos2, angle2, [], [], colour2, [], kPsychDontDoRotation, [0, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('Flip',MainWindow);
    WaitSecs(1);
    imageArray = Screen('GetImage', MainWindow);
    imwrite(imageArray, 'test.png')
    
end
sca;