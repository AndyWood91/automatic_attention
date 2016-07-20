% changed EG on stim to half screen

function finalResults = saccade_analysis(subjects, exclusions)

% check number of arguments passed
if nargin == 1
    exclusions = [];
else
end

% remove exclusions
remove = ismember(subjects, exclusions);
subjects(remove) = [];

% EXCLUSIONS
% No data: 29
% Error rate above .2: 3 16 17 19 21 25 30 39 41 42
% No valid trials for reversal: 10 13 32 43

basic = zeros(numel(subjects),1);

missEG = zeros(numel(subjects),1);
stage1Res = zeros(numel(subjects),6);
stage2ResN = zeros(numel(subjects),6);
stage2ResR = zeros(numel(subjects),6);

for s = 1:numel(subjects) % loops around the P numbers
    
    clc; int2str(subjects(s))
    
    load(['raw_data\Sub',int2str(subjects(s))]); % loads basic data
    load(['processed_saccades\SummarySaccadeDataP',int2str(subjects(s))]); % loads saccade summary
    load(['processed_fixations\Sub', int2str(subjects(s))]); % loads fixations
    dR = [DATA.results summarySaccadeData(:,3:9)]; % combine Data; % now includes discard_anticipatory & discard_unfixated

    % find last fixation position and last entries and add to data
    lastFixEntry = nan(480,5);
    for f = 1:480
        % find last fixation position
        dFix = cell2mat(DATA_CUES_PROC(f,1));
        if size(dFix,1) > 0
            lastFixEntry(f,1:3) = dFix(end,1:3);
        end
        % find last entry
        dLE = cell2mat(DATA_CUES_PROC(f,2));
        for e = 1:size(dLE,1)
           onStim = check_EG_on_stimulus(dLE(e,1),dLE(e,2),[0, 0, 900, 1080; 1020, 0, 1920, 1080]);
           if onStim > 0
               lastFixEntry(f,5) = onStim-1;
           end
        end
        
    end
    lastFixEntry(:,4) = lastFixEntry(:,1)<960;
    dR = [dR lastFixEntry];
    
    % removes rests
    rests = 1:80:size(dR,1);
    dR(rests,:) = [];
    % removes timeouts & errors
    dR = dR(dR(:,8)==1,:); % remove timeouts and errors
    missEG(s) = mean(dR(:,14)); % prop of missing data
    dR = dR(dR(:,14)==0,:); % remove disgarded EG data (non-fixated, anticipations)
    
    
    % work out missing data % and remove
    basic(s,1) = sum(isnan(dR(:,10)))/size(dR,1);
    dR = dR(isfinite(dR(:,10)),:); % remove no saccade
    dR = dR(isfinite(dR(:,19)),:); % remove no entry on either stimulus.
    
    % flip for left / right (P cue always on left)
    rowSwitch = dR(:,2)>=5;
    dR(rowSwitch,[11 12]) = dR(rowSwitch,[12 11]);  
    dR(rowSwitch,15) = 960-(dR(rowSwitch,15)-960); % switch x of fixation for flipped trials
%     switchFinite = rowSwitch.*isfinite(dR(:,18));
    dR(rowSwitch,18:19) = ~dR(rowSwitch,18:19); % switch side of last fixation and last entry
    
    % stage 1
    tempDR = dR(ismember(dR(:,1),1:40),:);
    stage1Res(s,1) = mean(tempDR(:,19)==0,1); % mean correct last entries
    tempDR = tempDR(tempDR(:,19)==0,:); % select just last correct entries
    stage1Res(s,2) = size(tempDR,1);
    stage1Res(s,3:4) = mean(tempDR(:,11:12),1);
    stage1Res(s,5) = mean(tempDR(tempDR(:,11)==1,10),1);
    stage1Res(s,6) = mean(tempDR(tempDR(:,12)==1,10),1);
    
    % stage 2 Normal
    tempDR = dR(ismember(dR(:,1),41:60),:);
    tempDR = tempDR(tempDR(:,6)==0,:);
    stage2ResN(s,1) = mean(tempDR(:,19)==0,1); % mean correct last entries
    tempDR = tempDR(tempDR(:,19)==0,:); % select just last correct entries
    stage2ResN(s,2) = size(tempDR,1);
    stage2ResN(s,3:4) = mean(tempDR(:,11:12),1);
    stage2ResN(s,5) = mean(tempDR(tempDR(:,11)==1,10),1);
    stage2ResN(s,6) = mean(tempDR(tempDR(:,12)==1,10),1);
    
    % stage 2 Reversed
    tempDR = dR(ismember(dR(:,1),41:60),:);
    tempDR = tempDR(tempDR(:,6)==1,:);
    stage2ResR(s,1) = mean(tempDR(:,19)==1,1); % mean correct last entries
    tempDR = tempDR(tempDR(:,19)==1,:); % select just last correct entries
    stage2ResR(s,2) = size(tempDR,1);
    stage2ResR(s,3:4) = mean(tempDR(:,11:12),1);
    stage2ResR(s,5) = mean(tempDR(tempDR(:,11)==1,10),1);
    stage2ResR(s,6) = mean(tempDR(tempDR(:,12)==1,10),1);
    
end

finalResults = [subjects' missEG stage1Res stage2ResN stage2ResR];

end