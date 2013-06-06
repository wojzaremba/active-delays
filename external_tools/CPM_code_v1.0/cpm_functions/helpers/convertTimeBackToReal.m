function [realTimes avgTime stdTime] = ...
    convertTimeBackToReal(peakTimeCoord, header, stTrain, newBounds);

%% given some 'peakTimeCoord', that is, the intenger coordinate
%% of each peak in the aligned data (after it has been truncated),
%% go backwards to extract the actual time (in minutes) in the original
%% data that this corresponds to for each observed experiment
%%
%% Also calculate the mean of this for each peak, as well as
%% the 'spread' (i.e. std)
%% 
%% 'newBounds' contains the truncation range used on the aligned
%% data in 'upsampled' space.

%% first, reverse the truncation effect:
peakTimeCoord = peakTimeCoord + newBounds(1)-1;

%% now peakTimeCoord lie in upsampled alignment space

%% for each sample, take the nearest mapping (or average
%% (if two are equally close) as the time for that peak

numSamp = length(header);
numPeak = length(peakTimeCoord);

realTimes = zeros(numSamp,numPeak);
allSpaces = zeros(numSamp,numPeak);

for ss=1:numSamp
    timeMaps = stTrain(ss,:,2);
    thisHead = header{ss};
    for pp=1:numPeak
        thisPeak = peakTimeCoord(pp);
        %% find best match(es)
        done=0; space=-1; realInd=[];
        while (~done)
            space = space+1;
            realInd = find(abs(timeMaps-thisPeak)==space);
            if ~isempty(realInd)
                done=1;
            end
        end
        allRealTimes = thisHead(realInd,2);
        realTimes(ss,pp)= mean(allRealTimes);
        allSpaces(ss,pp)=space;
    end
end

avgTime = mean(realTimes,1);
stdTime = std(realTimes);
