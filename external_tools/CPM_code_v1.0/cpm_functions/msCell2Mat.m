% function msMat = msCell2Mat(ms)
% 
% convert a 1D cell array of ms experiments to a multi-d array

function msMat = msCell2Mat(ms)

numSamples = length(ms);
[numTaus numMZ] = size(ms{1});

%% convert to multiD array
msMat = reshape(cell2mat(ms)',[numMZ numSamples numTaus]);

