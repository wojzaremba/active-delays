% function [pts numCtrlPt] = getControlPtLoc(G,minNum,numCtrlPts)
%
% get location (in 'hidden' time) of control points
% that we will use in the spline modelling of u_kt
% for CPM2

function [pts numCtrlPt] = getControlPtLoc(G,minNum,numCtrlPt)

if ~exist('numCtrlPt')
    %% roughly how many we will have
    numCtrlPt=floor(G.numTaus*G.controlPointProp);
    %% sometimes for test data this will be too small
    numCtrlPt = max(numCtrlPt,minNum);
end

numCtrlPt = max(numCtrlPt,minNum);

%% want one at the first and last time point, and 
%% then evenly distributed in between:
timeChunkSize = floor(G.numTaus/(numCtrlPt-1));

pts = 1:timeChunkSize:G.numTaus;

if pts(end)~=G.numTaus
    if G.numTaus-pts(end) >= timeChunkSize/2
        pts = [pts G.numTaus];
    else
        pts = [pts(1:(end-1)) G.numTaus];
    end
end