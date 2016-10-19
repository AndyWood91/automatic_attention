function [answer] = participant_input(prompt, type, valid)

    commandwindow;

    while true
        
        try
            answer = input(prompt, 's');
        catch
            % do nothing with errors, loop will repeat
        end
        
        if strcmp(type, 'double')
            
            if str2double(answer) <= max(valid) && str2double(answer) >= min(valid)
                break
            else
                %
            end
            
        elseif strcmp(type, 'char')
            
            %do soemthing else
        else
            error('input variable "type" is invalid');
        end
        
    end

end