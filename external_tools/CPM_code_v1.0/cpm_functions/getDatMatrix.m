% function samplesMat = getDatMatrix(headerAbun,G);
%
% from cell data structure, get matrix data structure

function samplesMat = getDatMatrix(headerAbun,G);
samplesMat = reshape(cell2mat(headerAbun),...
    [G.numBins G.numRealTimes G.numSamples]);