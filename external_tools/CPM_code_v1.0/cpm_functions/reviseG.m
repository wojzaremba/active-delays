% function newG = reviseG(G,S,D,forceIt)
%
% If HMM scale and/or time transition probs have been altered,
% this updates the larger data structures involved.
%
% if 'forceIt'=1, does the S update no matter what


function newG = reviseG(G,S,D,forceIt)

if ~exist('forceIt')
  forceIt=0;
end

newG=G;

if exist('S') && ~isempty(S)
  %if (newG.S~=S) %check that it is different
  if forceIt | any(abs(newG.S-S>0))
    newG.S=S;
    newG.scaleTransLog = getLogScaleTrans(newG);   
  end
end

if exist('D')
    if ~forceIt
        notSame = length(find(G.D(:)-D(:)))>0;
    else
        notSame=1;
    end
    if notSame %check that it is different
        newG.D=D;
        newG.timeTransLog  = getLogTimeTrans(newG);
    end
end

newG.stateTransLog = getStateTransLog(newG);
newG.stateTrans = getStateTrans(newG);

return;
