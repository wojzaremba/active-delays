% function samplesMat = getSamplesMat(headerAbun,G,oneD)
%
% if oneD is provided and ~=0, overrides whatever number of bins is given in G
% (useful when displaying results from expreiments with numBins>1
% in which we reduce it to 1 so as to be able to visualize

function samplesMat = getSamplesMat(headerAbun,G,oneD)

numBins=G.numBins;

if ~exist('oneD','var') || oneD~=0
    numBins=G.numBins
end

samplesMat = reshape(cell2mat(headerAbun),...
    [numBins G.numRealTimes length(headerAbun)]);
