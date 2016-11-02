stimLocs = 6;
targetLoc = randi(stimLocs);
distractLoc = targetLoc;

while distractLoc == targetLoc || abs(distractLoc - targetLoc) == 3
distractLoc = randi(stimLocs);
end
secondDistractLoc = targetLoc - (distractLoc - targetLoc);
    if secondDistractLoc < 1
        secondDistractLoc = secondDistractLoc + stimLocs;
    elseif secondDistractLoc > stimLocs
        secondDistractLoc = secondDistractLoc - stimLocs;
    end