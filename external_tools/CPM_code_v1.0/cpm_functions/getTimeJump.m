% function timeJumpMats = getTimeJump(G)
%
% get the two matrixes that are indicator matrixes for
% the transition matrix reflecting pairs of states that
% correspond to jumping ahead 3,2 and 1 time states
% and ignoring the boundary condition states.  
% this is used when updating the transition matrixes in the
% M-Step
%
% This has now been generalized to maxTimeSteps, rather than 3

function timeJumpMats = getTimeJump(G)

steps=1:G.maxTimeSteps;

for tj=steps
  %tempMat=sparse(G.numStates,G.numStates);
  tempMat=logical(sparse(G.numStates,G.numStates));
  for tt=1:G.numStates-G.numScales*G.maxTimeSteps; %or (maxTimeSteps-1)
    % above, because don't want boundary times
    % with different probabilities 

    thisTime = G.stateToScaleTau(tt,2);
    validStates = find((G.stateToScaleTau(:,2)-thisTime)==tj);
    %tempMat(tt,validStates)=1;
    tempMat(tt,validStates)=true;
  end
  timeJumpMats{tj}=tempMat;
end

