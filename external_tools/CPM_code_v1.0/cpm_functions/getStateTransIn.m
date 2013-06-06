%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [precStates  precTaus precScaleInd] = ...
%    getStateTransIn(myScaleInd,myTau,G);
%
% Given a state, returns the list of states that can
% transition to this state (and corresponding taus
% and scales, so that we can compute the factored probability.
% 
% G is a structure containing all the global variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [precStates, precTaus, precScaleInd] = getStateTransIn(myScaleInd,myTau,G)

  maxTau = myTau-1;
  minTau = max(1,(myTau-G.maxTimeSteps));
  allowedTaus = maxTau:-1:minTau;

  minScale = max(1,(myScaleInd-G.maxScaleSteps));
  maxScale = min(G.numScales,(myScaleInd+G.maxScaleSteps));
  allowedScaleInd = minScale:maxScale;
   
  precStates = G.stMap(allowedScaleInd,allowedTaus);
  precStates = precStates(:);
  temp = G.stateToScaleTau(precStates,:);
  precScaleInd = temp(:,1);
  precTaus = temp(:,2);
  %[precStates,precTaus,precScaleInd] = ...
  %  scaleTauToState(allowedScaleInd,allowedTaus,G);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug

%if (0)
%  state
%  [myTau,myScaleInd]
%  display(['maxTau:' num2str(maxTau), '  minTau:' num2str(minTau)]);
%  allowedTaus
%  allowedScaleInd
%  precStates
%end
