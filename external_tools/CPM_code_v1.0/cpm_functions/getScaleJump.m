% function scaleJumpMats = getScaleJump(G)
%
% get the matrix that is an indicator that shows which states
% jump from one scale to a neighbouring scale (ignoring boundary
% states), and stays at the same state
% first matrix is timeJump=0, second is timeJump=1

function scaleJumpMat = getScaleJump(G)

%dbstop

%% sets of states that have non-boundary scale states, grouped by 
%% scale
scaleRange=2:(G.numScales-1);

for ii=scaleRange
  scaleStateSets{ii}=find(G.stateToScaleTau(:,1)==ii);
end

scaleDiffs=[0,1]; %permissible scale transitions
nzmax = (G.numScales-2)*G.numTaus*2;

for sd=1:length(scaleDiffs)
  clear tempMat; 
  %tempMat=logical(sparse([],[],[],G.numStates,G.numStates,nzmax));
  %tempMat=logical(sparse(G.numStates,G.numStates));
  tempMat=logical(zeros(G.numStates,G.numStates));
  %tempMat=zeros(G.numStates,G.numStates);
  %tempMat=logical(zeros(G.numStates,G.numStates));
  %for ii=1:length(genericScaleStates)
  for thisScale=scaleRange
    sc=scaleStateSets{ii};
    validStates = find(abs(G.stateToScaleTau(:,1)-thisScale)==scaleDiffs(sd));
    %tic;
    tempMat(sc,validStates)=1;
    %toc;
  end
  scaleJumpMat{sd}=sparse(tempMat);;
  %scaleJumpMat{sd}=logical(sparse(tempMat));
end

return;

for ii=1:length(scaleDiffs)
  length(find(scaleJumpMat{ii}))
end
