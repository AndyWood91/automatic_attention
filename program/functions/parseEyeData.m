function outData = parseEyeData(TS, left, right, First, Last)

% these commands convert local timestamps to Tobii timestamps
% Tobii is in microseconds, while local is in seconds
% hence the 10^6.
firstTS = tetio_localToRemoteTime(int64(First*10^6));
lastTS = tetio_localToRemoteTime(int64(Last*10^6));

% identifies the valid rows of Tobii data
vr = (TS>firstTS)&(TS<lastTS); 

% selects valid rows from data, combines eyes and returns as 1x2 cell array
outData =  {[left(vr,:) right(vr,:)] TS(vr)}; 

end