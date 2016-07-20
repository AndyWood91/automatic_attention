% what does this do
% add prompt to make folder if it doesn't exist yet

function process_fixations(subjects, exclusions)

res = [1920 1080];
DurThresh = 150;
DispThresh = 75;
GapThresh = 75;

% check number of arguments passed
if nargin == 1
    exclusions = [];
else
end

% remove exclusions
remove = ismember(subjects, exclusions);
subjects(remove) = [];

for s = 1:numel(subjects)
    
    fileName = strcat('raw_data\Sub',int2str(subjects(s)));
    load(fileName, 'DATA');
    
    DATA_EG_PROC = cell(480,3);

        for t = 1:480

            clc; [s t]

            EGdata = cell2mat(DATA.stimEG(t,1));
            ts = cell2mat(DATA.stimEG(t,2));
            TotalTime = (DATA.stimEG{t,2}(end) - DATA.stimEG{t,2}(1))/1000;


            % arrays for fixations
            fixStore = zeros(ceil(TotalTime/DurThresh),3);
            Interval = double(TotalTime)/size(EGdata,1);

            % prepare essential EG data
            EGerr = [mean(EGdata(:,13)==4) mean(EGdata(:,26)==4)]; % calc error on each eye
            if EGerr(1) < EGerr(2)
                EGdata = EGdata(:,[7 8 13]); % use Left eye
            else
                EGdata = EGdata(:,[20 21 26]); % use Right eye
            end
            EGdata(EGdata(:,1)>1,3) = 4;
            EGdata(EGdata(:,2)>1,3) = 4;
            EGdata(EGdata(:,1)<0,3) = 4;
            EGdata(EGdata(:,2)<0,3) = 4;
            EGdata(:,1) = bsxfun(@times,EGdata(:,1),res(1)); % scale to resolution
            EGdata(:,2) = bsxfun(@times,EGdata(:,2),res(2)); % scale to resolution

            EGdata = [EGdata ts];
            EGdata = double(EGdata);
            
            % Interpolation of gaps
            GapsBeforeFill = sum(sum(EGdata(:,1:2),2)==0)/size(EGdata,1);
            if GapsBeforeFill < 1 % valid data exists
                EGdata = fillMissing(EGdata, GapThresh, Interval);
            end
            GapsAfterFill = sum(sum(EGdata(:,1:2),2)==0)/size(EGdata,1);

            curFirst = 1; curLast = ceil(DurThresh/Interval);

            newFix = false; fixCnt = 0;
            while curLast <= size(EGdata,1)

                Win = EGdata(curFirst:curLast,:);

                dsp = [abs(max(Win(:,1)) - min(Win(:,1))) abs(max(Win(:,2)) - min(Win(:,2)))];
                
                if max(Win(:,3)) == 4
                    % missing data detected, start new window
                    curFirst = curLast + 1;
                    curLast = curFirst + ceil(DurThresh/Interval);
                end
                
                if dsp <= DispThresh
                    % increase window
                    curLast = curLast + 1;
                    newFix = true;
                else
                    % not in a fixation
                    if newFix == true % this window defines fixation
                        % record as end of fixation
                        fixCnt = fixCnt + 1;
                        fixStore(fixCnt,1:2) = mean(Win(:,1:2),1); % X&Y
                        fixStore(fixCnt,3) = size(Win,1)*Interval; % duration
                        fixStore(fixCnt,4:5) = [Win(1,4) Win(end,4)]; % start/end timestamps
                        curFirst = curLast + 1;
                        curLast = curFirst + ceil(DurThresh/Interval);
                        newFix = false; % set to start assessment of new fixation
                    else
                        % move window to right and start again
                        curFirst = curFirst + 1;
                        curLast = curLast + 1;
                    end
                end
            end

            fixStore(fixStore(:,3)== 0,:) = [];
            DATA_EG_PROC(t,:) = {fixStore EGdata [GapsBeforeFill GapsAfterFill]}; % store in cell

        end
        
        % TODO: folder check
%         Folder = pwd;
%         [PathStr,FolderName] = fileparts(Folder);
%         processed_fixations = ['DATA-',FolderName];
%         mkdir(processed_fixations);

        fileName = ['processed_fixations\Sub' int2str(subjects(s))];

        DATA_CUES_PROC = DATA_EG_PROC;
        save(fileName,'DATA_CUES_PROC','DATA');
end

end

function dataOut = fillMissing(dataIn, GapThresh, freqMS)
% dataIn = eyeGaze data to process (x,y,validity)
% GapThresh = time window in ms for acceptable gaps
% freqMS = ms value of each timestamp

if sum(dataIn(:,3)<4)>0 % if there is some non-error data
    
    % Interpolation of gaps
    while dataIn(1,3) == 4 % remove gaps at start
        dataIn(1,:) = [];
    end
    while dataIn(end,3) == 4 % remove gaps at end
        dataIn(end,:) = [];
    end

    % this section works out what positions needs to be filled and provides 
    % start and end points for each fill, stored in iFills
    iFills = zeros(size(dataIn,1),2);
    intCnt = 0;
    checkPos = 2;
    while checkPos < size(dataIn,1) % check each position in turn
        endPos = checkPos; % set end to current check
        if dataIn(checkPos,3)==4 % if missing (otherwise increase check position)
            while dataIn(endPos,3)==4 % step through until valid data is found
                endPos = endPos + 1; % increase end position
            end
            if endPos-checkPos < (GapThresh/freqMS) % if that gap is smalle enough
                intCnt = intCnt + 1; % this is a new fill
                iFills(intCnt,:) = [checkPos-1 endPos]; % add details of fill to the array
            end
            checkPos = endPos + 1; % go to next check position beyond the end
        else
            checkPos = checkPos + 1;                
        end
    end
    iFills(intCnt+1:end,:) = []; % remove empty rows of array

    % use values to interpolate
    for r = 1:size(iFills,1)
        intSteps = 0:1/(iFills(r,2)-iFills(r,1)):1; % calculate appropriate distribution across fill range

        x = dataIn(iFills(r,1),1) + (dataIn(iFills(r,2),1)-dataIn(iFills(r,1),1))*intSteps; % interpolation of x
        y = dataIn(iFills(r,1),2) + (dataIn(iFills(r,2),2)-dataIn(iFills(r,1),2))*intSteps; % interpolation of y
        dataIn(iFills(r,1):iFills(r,2),1:3) = [round(x)' round(y)' zeros(size(x,2),1)]; % update array
    end
    
end

dataOut = dataIn;

end