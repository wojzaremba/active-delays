% function strippedG = stripG(G,justParams)
% 
% takes a structure G, and removes the bulky matrices which
% we don't need (because they can easily be recreated).
% in this way, it is feasible to save this stripped down G to
% a workspace file

function strippedG = stripG(G,justParams)

%if (~exist('justParams'))
  justParams=0;
%end

if (justParams)
  strippedG.S=G.S;
  strippedG.D=G.D;
  strippedG.u=G.u;
  strippedG.z=G.z;
  strippedG.z=G.z;
  strippedG.sigmas=G.sigmas;
else
  strippedG = G;
  strippedG.stMap='';
  %strippedG.stateToScaleTau='';
  strippedG.timeJump='';
  strippedG.scaleJump='';
  %strippedG.traceLogConstant='';
  strippedG.stateLogPrior='';
  strippedG.statePrior='';
  strippedG.scaleTransLog='';
  strippedG.timeTransLog='';
  strippedG.scaleTrans='';
  strippedG.stateTransLog='';
  strippedG.stateTrans='';
  strippedG.prec='';
end

