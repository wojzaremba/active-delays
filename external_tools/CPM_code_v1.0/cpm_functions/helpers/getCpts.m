%% function [c1s c2s] = getCpts(G)
%
% get c1s and c2s needed for u update equations with CPM2

function [c1s c2s] = getCpts(G)

c1s = NaN*zeros(1,G.numTaus);
c2s = NaN*zeros(1,G.numTaus);

for pt=2:(G.numCtrlPts-1)
    [tempTp sMinus sPlus] = getTimePts(G,pt);
    ptSet = {sMinus,sPlus};

    c1s(sMinus) = G.cntrlPts(pt-1);
    c2s(sMinus) = G.cntrlPts(pt);
    
    c1s(sPlus) = G.cntrlPts(pt);
    c2s(sPlus) = G.cntrlPts(pt+1);

end

%% now do first control pt
pt=1;
[tempTp sMinus sPlus] = getTimePts(G,pt);
ptSet = {sMinus,sPlus};

c1s(sPlus) = G.cntrlPts(pt);
c2s(sPlus) = G.cntrlPts(pt+1);

%% and the last
pt=G.numCtrlPts;
[tempTp sMinus sPlus] = getTimePts(G,pt);
ptSet = {sMinus,sPlus};

c1s(sMinus) = G.cntrlPts(pt-1);
c2s(sMinus) = G.cntrlPts(pt);

