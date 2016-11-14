function pts = HandleCalibWorkflowPsychToolBox(Calib, main_window)
while (1)
    
    try
        
        mOrder = randperm(Calib.points.n);
        calibplot = CalibratePTB(Calib, mOrder, 0, [], main_window);
        [pts, keyPressed] = PlotCalibrationPointsPTB(calibplot, Calib, mOrder, main_window);
        while(1)
            if strcmp(keyPressed, 'y')
                tetio_stopCalib;
                return;
            elseif strcmp(keyPressed, 'n')
                tetio_stopCalib;
                break;
            end
        end
    catch ME
        tetio_stopCalib;
        Screen('TextSize', main_window, 36);
        Screen('TextFont', main_window, 'Calibri');
        Screen('TextStyle', main_window, 1);
        DrawFormattedText(main_window, 'NOT ENOUGH CALIBRATION DATA. Do you want to try again? ([y]/n)', 'center', 'center', [255 255 255],120,[],[],1.5);
        Screen(main_window, 'Flip');
        RestrictKeysForKbCheck([89,78]);
        KbWait([],2);
        [~, ~, keyCode] = KbCheck;      % This stores which key is pressed as a keyCode
        keyPressed = KbName(keyCode);
        if strcmp(keyPressed, 'y')
            Screen(main_window, 'Flip');
            continue;
        elseif strcmp(keyPressed, 'n');
            sca;
            ShowCursor;
            return;
        end
    end
end