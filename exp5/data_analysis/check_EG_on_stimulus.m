% checks to see if a point falls within a specified area(s)
% x,y are coordinates (from EG data)
% stimulus_array is an array of PTB coordinates for rectangles
% (i.e. distance from the left/top screen edge of the left, top, right, &
% bottom borders of the rectangle)

% would be interested in a version of this using a circle around x,y
% specifying the radius as a parameter

function detected = check_EG_on_stimulus(x,y,stimulus_array)

detected = 0;

    % loops through each rectangle in the stimulus_array
    for s = 1:size(stimulus_array,1)

        % compares the x,y coordinates to the boundaries of the rectangle
        checks = [x>stimulus_array(s,1) y>stimulus_array(s,2) x<stimulus_array(s,3) y<stimulus_array(s,4)];

        if sum(checks) == 4 % if all points are within boundaries

            detected = s; % the specified rectangle
            return

        end

    end

end