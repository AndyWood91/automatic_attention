%% get_details

% identifying information (age, gender, hand) are stored separately from
% experiment information for anonymity.

% TODO: turn inputs into a class and make validation a method.


%% code

function [DATA] = get_details(title, conditions, sessions, bonus)

    % variable declarations
    start = datestr(now, 0);  % get current time
%     global testing;  % turn on if debugging within another script
    testing = 1;  % 0 = experimental version, 1 = test version, turn off if debugging within another script
    
    % set missing inputs
    if nargin <4
        bonus = false;  % default, no bonus
    else
        % user input
    end
    
    if nargin <3
        sessions = 1;  % default, 1 session
    else
        % user input
    end
    
    if nargin <2
        conditions = {};  % default, no conditions
    else
        % user input
    end
    
    if nargin <1
        title = 'experiment_';  % default, no title
    else
        % user input
    end
    
    % check input types
    if ~isa(bonus, 'logical')
        error('input "bonus" must be a logical');
    else
        % is logical
    end
    
    if ~isa(sessions, 'double')
        error('input "sessions" must be a double');
    else
        % is double
    end
    
    if sessions < 1
        error('input "sessions" must be a positive integer');
    else
        % is positive integer
    end
    
    if ~isa(conditions, 'cell')
        error('input "conditions" must be a cell');
    else
        % is cell
    end
    
    if ~isa(title, 'char')
        error('input "title" must be a char');
    else
        % is char
    end
    
    % data check loop
    while true
        
        commandwindow;  % move curor to command window
        
        while true  % number loop
            try
                number = input('Participant number --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
            catch
                % do nothing with errors, number loop will repeat
            end
            
            % validation
            if str2double(number) > 0  % only accept positive integers
                break  % exit number loop
            else
                % do nothing, number loop will repeat
            end
        end  % number loop
        
        if sessions > 1  % more than 1 experimental session
            while true  % session loop
                try
                    session = input('Session number --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
                catch
                    % do nothing with errors, session loop will repeat
                end

                % validation
                if str2double(session) <= sessions
                    break  % exit the session loop
                else
                    % do nothing, session loop will repeat
                end
            end  % session loop
        else  % 1 experimental session
            session = '1';
        end  % if sessions
        
        % filenames
        participant_filename = ['participant_data/participant', number, '.mat'];
        experiment_filename = [title, '_data/', title, '_participant', number, 'session'];  % doesn't include session number yet to make it easier to check for previous session's data
        
        % directories
        if exist('participant_data', 'dir') ~=7  % if participant_details directory doesn't exist
            mkdir('participant_data');  % make it
        else
            % directory already exists
        end
        
        if exist([title, '_data'], 'dir') ~=7  % if raw_data directory doesn't exist
            mkdir([title, '_data']);  % make it
        else
            % directory already exists
        end
        
        % session data
        if exist([experiment_filename, session, '.mat'], 'file') == 2  % check for existing data file
            clc;
            data_exists = 'Session %s data already exists for participant %s.\n\n';
            fprintf(data_exists, session, number);
            % data check loop will repeat
        else  % no existing data file
            if str2double(session) == 1  % first session
                if testing == 1  % test version
                    % it me 
                    age = '25';
                    gender = 'man';
                    hand = 'right';
                elseif testing == 0  % experimental version
                    while true  % age loop
                        try
                            age = input('Participant age --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
                        catch
                            % do nothing with errors, age loop will repeat
                        end
                        
                        % validation
                        if str2double(age) > 0  % only accept positive integers
                            break  % exit age loop
                        else
                            % do nothing, age loop will repeat
                        end
                    end  % age loop
                    
                    while true  % gender loop
                        try
                            gender = input('Participant gender (use first letter): man/other/woman --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
                        catch
                            % do nothing with errors, gender loop will repeat
                        end
                        
                        % validation
                        if strcmpi(gender, 'm')
                            gender = 'man';
                            break  % exit gender loop
                        elseif strcmpi(gender, 'o')
                            gender = 'other';
                            break  % exit gender loop
                        elseif strcmpi(gender, 'w')
                            gender = 'woman';
                            break  % exit gender loop
                        else
                            % do nothing, gender lop will repeat
                        end
                    end  % gender loop
                    
                    while true  % hand loop
                        try
                            hand = input('Participant hand (use first letter): ambidextrous/left/right --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
                        catch
                            % do nothing with errors, hand loop will repeat
                        end
                        
                        % validation
                        if strcmpi(hand, 'a')
                            hand = 'ambidextrous';
                            break  % exit hand loop
                        elseif strcmpi(hand, 'l')
                            hand = 'left';
                            break  % exit hand loop
                        elseif strcmpi(hand, 'r')
                            hand = 'right';
                            break  % exit hand loop
                        else
                            % do nothing, hand loop will repeat
                        end
                    end  % hand loop
                    
                else
                    error('variable "testing" isn''t set properly');
                end  % if test
                
                % save participant data
                DATA.participant.number = number;
                DATA.participant.age = age;
                DATA.participant.experiment = title;
                DATA.participant.gender = gender;
                DATA.participant.hand = hand;
                DATA.participant.filename = participant_filename;
                save(participant_filename, 'DATA');
                clear DATA;

                % store experiment data
                experiment_filename = [experiment_filename, session, '.mat'];
                DATA.experiment.number = number;
                DATA.experiment.session = session;
                DATA.experiment.filename = experiment_filename;
                DATA.experiment.start = start;
                DATA.experiment.title = title;

                % set counterbalance values
                if numel(conditions) > 0
                    counterbalance = zeros(1, numel(conditions));  % blank array to store values
                    % for each condition, number is divided by the number
                    % of possible values for that condition. Then add 1 to
                    % shift floor value up to 1 (would otherwise be 0 if
                    % mod(number, conditions) == 0
                    for a = 1:numel(conditions)  % for each condition,
                        % number is divided by the number of possible
                        % values for that condition. Add 1 to shift floor
                        % up from 0 (if number is perfectly divisible by 1)
                        counterbalance(1, a) = mod(str2double(number), conditions{a}(end)) + 1;
                    end

                    DATA.experiment.counterbalance = counterbalance;
                else
                    % no conditions
                end  % if counterbalance

                if bonus 
                    bonus_session = 0;
                    bonus_total = 0;
                    DATA.experiment.bonus_session = bonus_session;
                    DATA.experiment.bonus_total = bonus_total;
                end

                save(experiment_filename, 'DATA')

                break  % exit the data check loop
                
            elseif str2double(session) > 1  % not the first session
                previous_session = num2str(str2double(session) - 1);  % previous session number as char
                
                if exist([experiment_filename, previous_session, '.mat'], 'file') ~= 2
                    clc;
                    data_missing = 'Session %c data does not exist for participant %c.\n\n';
                    fprintf(data_missing, previous_session, number);
                    % data check loop will repeat
                else
                    load([experiment_filename, previous_session, '.mat'], 'DATA');
                    % TODO: load and display previous data
                end
                
                while true  % confirm loop
                    try
                        confirm = input('Are these details correct (use first letter): yes/no --> ', 's');  % stored as a string to stop Matlab from attempting to execute expressions
                    catch
                        % do nothing with errors, confirm loop will repeat
                    end
                    
                    % validation
                    if strcmpi(confirm, 'y') || strcmpi(confirm, 'n')
                        break  % exit confirm loop
                    else
                        % do nothing, confrim loop will repeat
                    end
                    
                end  % confirm loop
                
                % TODO: no doesn't repeat the loop for some reason
                if strcmpi(confirm, 'y')
                    % TODO: save data here
                    break  % exit data check loop
                elseif strcmpi(confirm, 'n')
                    % do nothing, data check loop will repeat
                end
                
            end  % if session
        
        end  % data check loop
    
    end  % exit data check loop
        
end  % get_details
