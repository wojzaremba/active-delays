% function  newG = updateStateTransitions(G)
%
% Updates G.D, G.timeTransLog, G.stateTransLog, G.stateTrans
% using the new values of d_1^k provide from the M-step update
% rule.

% note that the order of these updates is crucial.

function  newG = updateStateTransitions(G)

newG=G;
%% updateTimeConst and updateScaleConst have already
%% updated other relevant parameters
newG.stateTransLog = getStateTransLog(G);
newG.stateTrans = getStateTrans(newG);

return; 

%% WARNING, I HAD IT LIKE THIS BEFORE!!!
%newG.stateTrans = getStateTrans(G);

%warning('MUST FIX THIS FUNCTION!!!');
