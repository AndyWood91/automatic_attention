function [keyCode, rt, timeout] = accKbWait(startTime, waitTime)
% This function checks the keyboard for a response and spits out the
% keyCode, the rt (i.e., the time at which a response was made) and whether 
% a timeout has occured. If you want to wait for a fixed amount of time - 
% e.g., 2 secs after the start time - include an input variable containing 
% the start time, followed by an input variable containing the length of time 
% (in secs) before a timeout occurs and the trial moves on.

while KbCheck; end %this should catch anybody holding down the button, essentially waits until all keys are released

switch nargin
    case 2
        st = startTime;
        timeoutDuration = waitTime;
    otherwise
        st = 0;
        timeoutDuration = inf;
end



keyIsDown = 0;
timeout = 0;
    
    while keyIsDown == 0
        timeoutCheck = GetSecs;
        [keyIsDown, rt, keyCode, deltasecs] = KbCheck; %replaced KbWait with this, as KbWait checks the keyboard every 5 ms - not great for RT differences
        if timeoutCheck - st > timeoutDuration
            timeout = 1;
            break;
        end
        
    end