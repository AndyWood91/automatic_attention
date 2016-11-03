%% update_details

% input arguments

    % experiment: Map container created by the get_details function
    
    % bonus_session: optional float for performance bonus. Default is 0.
    
% outputs

    % saves experiment Map to raw_data directory

%% code

function [] = update_details(experiment, bonus_session)
    

    % variable declarations
    global testing;
    

    % set  missing inputs
    if nargin < 2
        bonus_session = 0;  % default, no bonus
    end
    
    
    % check input types
    if ~isa(bonus_session, 'double')
        error('bonus_session input must be a double')
    end
    
    if ~isa(experiment, 'containers.Map')
        error('experiment input must be containers.Map')
    end
    
    
    % finish
    experiment('finish') = datestr(now, 0);
    
    
    % bonus
    if isKey(experiment, 'bonus_session')
        experiment('bonus_session') = bonus_session;  % store session bonus
    end
    
    if isKey(experiment, 'bonus_total')
        experiment('bonus_total') = experiment('bonus_total') + bonus_session;  % add session bonus to total
    end
    
    
    % save
    if exist('raw_data', 'dir') ~= 7  % check for raw_data directory
        mkdir('raw_data')  % make it if it doesn't exist
    end
    
    
    save(experiment('data_filename'), 'experiment');
    
    
end