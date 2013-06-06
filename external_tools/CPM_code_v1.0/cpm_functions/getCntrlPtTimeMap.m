% function [timePts sMinus sPlus]= getCntrlPtTimeMap(G)
%
% get the time points that are effected by each cntrlPt
% so that we can do the u updates when USE_CPM2=1.
%
% timePts is 1xnumCtrlPts and each cell entry retursn the list
% of tau which are effected by that control point
%
% sPlus and sMinus correspond to the sets in my latex document,
% where the union of these makes up S==timePts
% (sPlus includes the state=pt.)

function [timePts sMinus sPlus]= getCntrlPtTimeMap(G)

timePts = cell(1,G.numCtrlPts);
sMinus = cell(1,G.numCtrlPts);
sPlus = cell(1,G.numCtrlPts);

%% there is always a control point right at the start, and right
%% at the end, i.e. for tau=1 and tau=numTau
allTau = 1:G.numTaus;

timePts{1} =   allTau(G.cntrlPts(1):(G.cntrlPts(2)-1));
timePts{end} = allTau((G.cntrlPts(end-1)+1):G.cntrlPts(end));

sMinus{1} = [];
sMinus{end} = allTau((G.cntrlPts(end-1)+1):G.cntrlPts(end));

sPlus{1} = timePts{1};
sPlus{end} = [];

for pt = 2:(G.numCtrlPts-1)
    firstInd = G.cntrlPts(pt-1)+1;
    lastInd = G.cntrlPts(pt+1)-1;
    timePts{pt} = allTau(firstInd:lastInd);
    sMinus{pt} = allTau(firstInd:(G.cntrlPts(pt)-1));
    sPlus{pt} = allTau(G.cntrlPts(pt):lastInd);
    if ~isempty(intersect(sMinus{pt},sPlus{pt}))
        keyboard;
    end
end

