% function mat = toMat(msdat)
%
% convert a mass spec cell structure to matrix

function mat = toMat(msdat)

numSamples = length(msdat);
[numBins numTimes] = size(msdat{1});

mat = reshape(cell2mat(msdat),[numBins numTimes numSamples]);
 
    