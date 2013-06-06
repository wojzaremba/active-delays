% function revivedG = reviveG(G,UPDATE_T,UPDATE_S)
%
% takes a stripped down G, and generates the parts
% that are missing (i.e. the huge matrixes that are
% extremely memory intensive)
%
% If you won't be learning the time and/or scale state
% transitions with this data structure, then set UPDATE_T
% (for time), and UPDATE_S (for scale) to have the value
% 0 so that the huge matrixes associated with these updates
% are not generated
%
% see also stripG

function G = reviveG(oldG,UPDATE_T,UPDATE_S)

G=oldG;

G.stMap=reshape([1:G.numStates]',G.numScales,G.numTaus);

G.stateToScaleTau = zeros(G.numStates,2);
for st=1:G.numStates
  [temp1,temp2]= find(G.stMap==st);
  G.stateToScaleTau(st,:) = [temp1, temp2];
end

if UPDATE_T
  G.timeJump = getTimeJump(G);
end
if UPDATE_S
  G.scaleJump = getScaleJump(G);
end

temp=2.^G.scales(G.stateToScaleTau(:,1));
G.traceLogConstant = repmat(temp(:),[1 G.numBins]);
%oneScaleOnly=(all(G.S==1));

G.stateLogPrior = getStateLogPrior(G,G.oneScaleOnly);
G.statePrior = exp(G.stateLogPrior);

G.scaleTransLog = getLogScaleTrans(G); 
G.timeTransLog  = getLogTimeTrans(G);

G.prec = getAllStateTransIn(G);

G.stateTransLog = getStateTransLog(G);
G.stateTrans = getStateTrans(G);

