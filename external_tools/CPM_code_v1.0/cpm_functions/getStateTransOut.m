%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [succStates  succTaus succScaleInd] = ...
%    getStateTransOut(myScaleInd,myTau,G);
%
% Given a state, returns the list of states that can
% can be transitioned to from this state (and corresponding taus
% and scales, so that we can compute the factored probability.
% 
% G is a structure containing all the global variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [succStates, succTaus, succScaleInd] =  getStateTransOut(myScaleInd,myTau,G)

minTau = min(G.numTaus+1,myTau+1);
maxTau = min(myTau+G.maxTimeSteps,G.numTaus);
allowedTaus = maxTau:-1:minTau;

minScale = max(1,(myScaleInd-G.maxScaleSteps));
maxScale = min(G.numScales,(myScaleInd+G.maxScaleSteps));
allowedScaleInd = minScale:maxScale;
   
succStates = G.stMap(allowedScaleInd,allowedTaus);
succStates = succStates(:);
temp = G.stateToScaleTau(succStates,:);
succScaleInd = temp(:,1);
succTaus = temp(:,2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug

%if (0)
%  state
%  [myTau,myScaleInd]
%  display(['maxTau:' num2str(maxTau), '  minTau:' num2str(minTau)]);
%  allowedTaus
%  allowedScaleInd
%  succStates
%end
