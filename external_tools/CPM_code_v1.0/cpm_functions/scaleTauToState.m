%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [states,taus,scaleInds] = ...
%    scaleTauToState(scaleInds,times,G)
%
% given a list of scaleInds and times, returns the 
% corresponding state.
%       (this is the inverse of getTauScale(state)

function [states] = ...
    scaleTauToState(scaleInds,times,G)

if (isempty(scaleInds) | isempty(times))
  myTimes=[];
  myScaleInds=[];
  states=[];
else
  
  %myTimes = fastrepmat(times(:),[length(scaleInds),1]);
  %myScaleInds = fastrepmat(scaleInds(:),[1,length(times)])';  
  %myScaleInds=myScaleInds(:);

  %states = (myTimes-1)*numScales + myScaleInds;  
  states = G.stMap(scaleInds,times);
  
end
