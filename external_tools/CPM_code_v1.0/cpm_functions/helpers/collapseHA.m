function newHA = collapseHA(ha)

%% collapse headerAbun with more than one bin, to one with just 1 bin
%% (mainly for visualization purpose)

[numBins numSamp]=size(ha);

newHA = cell(1,numSamp);

for hh=1:numSamp
    tmpHA = ha{hh};
    tmpHA = sum(tmpHA,1);
    newHA{hh}=tmpHA;
end

return;
