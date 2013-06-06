function G = getGhelper(G)

G.numStates  = G.numScales*G.numTaus;

if (G.oneScaleOnly)
  S=1;
else
  S = 0.90;  % percent probability of staying in the same scale state
end
for cc=1:G.numClass
  G.S(cc)=S;
end

G.stMap = reshape([1:G.numStates]',G.numScales,G.numTaus);

%% Mapping from state to tau and scale
G.stateToScaleTau = zeros(G.numStates,2);
for st=1:G.numStates
  [temp1,temp2]= find(G.stMap==st);
  G.stateToScaleTau(st,:) = [temp1, temp2];
end

G.prec = getAllStateTransIn(G);

G.pseudoT = 5*ones(1,G.maxTimeSteps);
if (G.oneScaleOnly)
  G.pseudoS = zeros(1,2);
else
  G.pseudoS = 5*ones(1,2);
end

G.timeJump = getTimeJump(G);
G.scaleJump = getScaleJump(G);

temp=2.^G.scales(G.stateToScaleTau(:,1));
G.traceLogConstant = repmat(temp(:),[1 G.numBins]);

G.stateLogPrior = getStateLogPrior(G);
G.statePrior = exp(G.stateLogPrior);

