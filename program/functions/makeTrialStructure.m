function finalTS = makeTrialStructure

% this array describes the structure/proportion of basic and reverse across the stages
% of the experiment. By using 8 to 2 ratio, we control where the reversal
% trials pop up. They occur 8 times in every 40.

% TODO: the comments don't like up with the code, definitely needs to be
% cleaned up and take the format as an input.

stg2 = repmat([5 5],2,1); % rather than type 8 2 lots of times!
BlockStruc = [40 0; stg2];

standardTS = zeros(8,5);
standardTS(1,:) = [1 6 1 2 0];
standardTS(2,:) = [2 5 2 1 0];
standardTS(3,:) = [6 1 1 2 0];
standardTS(4,:) = [5 2 2 1 0];
standardTS(5,:) = [3 8 1 2 0];
standardTS(6,:) = [4 7 2 1 0];
standardTS(7,:) = [8 3 1 2 0];
standardTS(8,:) = [7 4 2 1 0];

reverseTS = zeros(8,5);
reverseTS(1,:)=[1 6 2 1 1];
reverseTS(2,:)=[2 5 1 2 1];
reverseTS(3,:)=[6 1 2 1 1];
reverseTS(4,:)=[5 2 1 2 1];
reverseTS(5,:)=[3 8 2 1 1];
reverseTS(6,:)=[4 7 1 2 1];
reverseTS(7,:)=[8 3 2 1 1];
reverseTS(8,:)=[7 4 1 2 1];

finalTS = zeros(8*sum(sum(BlockStruc)),5); % sets size of final array
step = 0; % used in writing to finalTS later in code

% this loop is used to generate a random arrangement of trials for each
% stage and check for excessive repetition or consecutive reversal trials

for b = 1:size(BlockStruc,1)
    
    randCheck = false; % set to false to enter loop
    while randCheck == false 
        randCheck = true;
        
        % creates larger trial structure using the above BlockStruc array
        tempTS_S = repmat(standardTS,BlockStruc(b,1),1);
        tempTS_R = repmat(reverseTS,BlockStruc(b,2),1);
        tempTS = [tempTS_S ; tempTS_R];
        
        order = randperm(size(tempTS,1))'; % starting random order
        tempTS = tempTS(order,:); % shuffle rows to that order
        
        if sum(tempTS(:,5)) > 0 % a block with reversal trials
            repCount = 0;
            for r = 1:size(tempTS,1)-1
                if tempTS(r,5) == tempTS(r+1,5)
                    repCount = repCount + 1;
                    if repCount > 2
                        randCheck = false; 
                        break;
                    end
                else
                    repCount = 0;
                end
            end
        end    
    end
    
    
    % add that smaller array to the larger final one in the right place.
    % if the following checks are not accepted, this get overwritten
    % next time around the while loop.
    finalTS(step+1:step+size(tempTS,1),:) = tempTS;
    step = step + size(tempTS,1); % update step for next loop
    
end


% this last bit just adds the block numbers on to the TS (e.g., 1 1 1 1 2 2 2 2 etc)
% which will be useful for later analysis.
bs = size(finalTS,1)/8;
blockNums = reshape(repmat(1:bs,8,1),bs*8,1);
finalTS = [blockNums finalTS];

end
