% function drawOrigAndAlignedData(data,scaleAndTimes,useScaling);
%
% Draw the unaligned data, and the aligned data.  If useScaling=1
% then also include the scaling in the alignment.
%
% If the data is not scalar time series, then the dimensions are
% collapsed to make it scalar.

function drawOrigAndAlignedData(data,scaleAndTimes,useScaling);

[numSamples numRealTime numBins]=size(data);

data=sum(data,3);

% split the axes up
allAx = splitAxes(2,1,'',[0.04 0.02]);

%% raw unaligned data
axes(allAx{1}),
plot(data(),'-+','MarkerSize',2);
xlabel('Experimental Time Points');
ylabel('Signal Intensity');

keyboard;

%% aligned data
showAlignedAll(G,data,scaleAndTimes,useScaling)
