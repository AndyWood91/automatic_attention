function [DATA] = update_details(DATA, bonus_session)
% UPDATE_DETAILS:  DATA is a struct created by the get_details() function,
% bonus_session is an optional argument if the task pays a performance
% bonus
    
    if nargin == 2
        bonus = true;
    else
        bonus = false;
    end
    
    % check input types
    if bonus
        if ~isa(bonus_session, 'double')
            error('bonus_session input must be a double')
        end
    end
    
    if ~isa(DATA, 'struct')
        error('experiment input must be struct')
    end
    
    % finish
    DATA.experiment.finish = datestr(now, 0);
    DATA.experiment.duration = DATA.experiment.start - DATA.experiment.finish;
    
    % bonus
    if bonus
        DATA.experiment.bonus_session = bonus_session;
        DATA.experiment.bonus_total = DATA.experiment.bonus_total + bonus_session;
    end
    
    % save
    if exist([DATA.experiment.title, '_data'], 'dir') ~= 7  % check for raw_data directory
        mkdir([DATA.experiment.title, '_data'])  % make it if it doesn't exist
    end
    
    save(DATA.experiment.filename, 'DATA');
    
end