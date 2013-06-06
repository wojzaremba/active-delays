%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [states,taus,scaleInds] = ...
%    scaleTauToState2(scaleInds,times,G)
%
% given a list of scaleInds and times, returns the 
% corresponding state.
%       (this is the inverse of getTauScale(state)

function [states] = scaleTauToState2(st,G)
  
  for j=1:size(st,1)
     states(j) = G.stMap(st(j,1),st(j,2));
  end
  
