function [pts, keyPressed] = PlotCalibrationPointsPTB(calibPlot, Calib, mOrder, main_window)


NumCalibPoints = length(calibPlot)/8;
clear OrignalPoints;
clear pts;
j = 1;
for i = 1:NumCalibPoints
    OrignalPoints(i,:) = [calibPlot(j) calibPlot(j+1)];
    j = j+8; 
end
lp = unique(OrignalPoints,'rows');
for i = 1:length(lp)
    pts(i).origs = lp(i,:);
    pts(i).point = [];
end
j = 1;
for i = 1:NumCalibPoints
    for k = 1:length(lp)
        if((calibPlot(j)==pts(k).origs(1)) && (calibPlot(j+1)==pts(k).origs(2)))
            n = size(pts(k).point,2);
            pts(k).point(n+1).validity = [calibPlot(j+4) calibPlot(j+7)];
            pts(k).point(n+1).left= [calibPlot(j+2) calibPlot(j+3)];
            pts(k).point(n+1).right= [calibPlot(j+5) calibPlot(j+6)];
        end
    end
    j = j+8;
end
for i = 1:size(pts,2)
    pts(i).origsPixels = pts(i).origs .* [1920 1080];
end

if (Calib.resize)
		 figloc.x =  Calib.mondims1.x + Calib.mondims1.width/4;
		 figloc.y =  Calib.mondims1.y + Calib.mondims1.height/4;
		 figloc.width =  Calib.mondims1.width/2;
		 figloc.height =  Calib.mondims1.height/2;
else
		figloc  =  Calib.mondims1;
end

Calib.mondims = figloc;

calibPlotWin = Screen('OpenOffscreenWindow', main_window, Calib.bkcolor, [figloc.x, figloc.y, figloc.x+figloc.width, figloc.y+figloc.height]);
Screen('FrameRect', calibPlotWin, Calib.frameColor, [], 2);

Screen('BlendFunction', calibPlotWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %This allows for transparent background on white dot
%Draw small blue circle
SmallMarkerRect = [0 0 Calib.SmallMark Calib.SmallMark];
SmallMarkerCentre = Calib.SmallMark/2;
SmallMarker = Screen('OpenOffscreenWindow', main_window, [0 0 0 0], SmallMarkerRect); %alpha value of zero to allow transparency when drawing dots on top of each other
Screen('FillOval', SmallMarker, [0 0 255 255], [], Calib.SmallMark);
Screen('FrameOval', SmallMarker, [0 0 0 255],[],  1);

%Draw Eye markers
EyeMarkerRect = [0 0 Calib.SmallMark Calib.SmallMark];
EyeMarkerCentre = Calib.SmallMark/2;
GreenMarker = Screen('OpenOffscreenWindow', main_window, [0 0 0 0], EyeMarkerRect); %alpha value of zero to allow transparency when drawing dots on top of each other
Screen('FrameOval', GreenMarker, [0 255 0 255], [], 1);
RedMarker = Screen('OpenOffscreenWindow', main_window, [0 0 0 0], EyeMarkerRect); %alpha value of zero to allow transparency when drawing dots on top of each other
Screen('FrameOval', RedMarker, [255 0 0 255], [], 1);

for i = 1:length(lp)
    Screen('DrawTexture', calibPlotWin, SmallMarker, [Calib.mondims.width*pts(i).origs(1)-Calib.SmallMark/2, Calib.mondims.height*pts(i).origs(2)-Calib.SmallMark/2, Calib.mondims.width*pts(i).origs(1)+Calib.SmallMark/2, Calib.mondims.height*pts(i).origs(2)+Calib.SmallMark/2]);
    
    for j = 1:size(pts(i).point,2)
        if (pts(i).point(j).validity(1) == 1)
            Screen('DrawLine', calibPlotWin, [255 0 0 255], Calib.mondims.width*pts(i).origs(1), Calib.mondims.height*pts(i).origs(2), Calib.mondims.width*pts(i).point(j).left(1), Calib.mondims.height*pts(i).point(j).left(2), 1);
            Screen('DrawTexture', calibPlotWin, RedMarker, [], [(Calib.mondims.width*pts(i).point(j).left(1))-Calib.SmallMark/2, (Calib.mondims.height*pts(i).point(j).left(2))-Calib.SmallMark/2, (Calib.mondims.width*pts(i).point(j).left(1))+Calib.SmallMark/2, (Calib.mondims.height*pts(i).point(j).left(2))+Calib.SmallMark/2]);
        end
        if (pts(i).point(j).validity(2) == 1)
            Screen('DrawLine', calibPlotWin, [0 255 0 255], Calib.mondims.width*pts(i).origs(1), Calib.mondims.height*pts(i).origs(2), Calib.mondims.width*pts(i).point(j).right(1), Calib.mondims.height*pts(i).point(j).right(2), 1);
            Screen('DrawTexture', calibPlotWin, GreenMarker, [], [(Calib.mondims.width*pts(i).point(j).right(1))-Calib.SmallMark/2, (Calib.mondims.height*pts(i).point(j).right(2))-Calib.SmallMark/2, (Calib.mondims.width*pts(i).point(j).right(1))+Calib.SmallMark/2, (Calib.mondims.height*pts(i).point(j).right(2))+Calib.SmallMark/2]);
        end
    end
end

Screen('DrawTexture', main_window, calibPlotWin);
Screen('TextSize', main_window, 36);
Screen('TextFont', main_window, 'Calibri');
Screen('TextStyle', main_window, 1);

DrawFormattedText(main_window, 'Accept Calibration? [y]/n?', 'center', figloc.y+figloc.height+150, [255 255 255], 120, [], [], 1.5);
Screen(main_window, 'Flip');

WaitSecs(0.5);


RestrictKeysForKbCheck([89, 78]);
KbWait([],2);
[~, ~, keyCode] = KbCheck;      % This stores which key is pressed as a keyCode
keyPressed = KbName(keyCode);

Screen(main_window, 'Flip');

Screen('Close', calibPlotWin);
Screen('Close', SmallMarker);
Screen('Close', GreenMarker);
Screen('Close', RedMarker);

end
        
