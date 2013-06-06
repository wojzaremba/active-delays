% function scaleJumpMats = getScaleJump(G)
%
% get the matrix that is an indicator that shows which states
% jump from one scale to a neighbouring scale (ignoring boundary
% states), and stays at the same state
% first matrix is timeJump=0, second is timeJump=1

function scaleJumpMat = getScaleJump(G)

warning('h'); keyboard;

%% sets states that have non-boundary scale states
genericScaleStates = find(G.stateToScaleTau(:,1)~=1 &G.stateToScaleTau(:,1)~=G.numScales);

% For each time state, can move ahead three time
% states, TIME, x scale states
%numberNonZero(1)=length(genericScaleStates)*G.numTaus; %same scale state
%numberNonZero(2)=numberNonZero(1)*2;

scaleDiffs=[0,1];

for sd=1:length(scaleDiffs)
  clear tempMat; 
  tempMat=logical(sparse(G.numStates,G.numStates));
  %tempMat=zeros(G.numStates,G.numStates);
  %mynzmax=numberNonZero(sd);
  %tempMat = sparse(1,1,0,G.numStates,G.numStates,mynzmax);
  for ii=1:length(genericScaleStates)
    ii
    sc=genericScaleStates(ii);
    thisScale = G.stateToScaleTau(sc,1);
    validStates = find(abs(G.stateToScaleTau(:,1)-thisScale)==scaleDiffs(sd));
    tempMat(sc,validStates)=1;
    %if (mod(ii,100)==0)
    %  [ii nnz(tempMat)]
    %end
  end
  scaleJumpMat{sd}=tempMat;
  %scaleJumpMat{sd}=logical(sparse(tempMat));
end

return;

for ii=1:length(scaleDiffs)
  length(find(scaleJumpMat{ii}))
end
