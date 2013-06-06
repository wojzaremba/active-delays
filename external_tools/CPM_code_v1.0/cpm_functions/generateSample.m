function [samples, states]= generateSample(G,numSamples)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% generate a random number
setRandomSeed;
kk=1;
while (kk<=numSamples)
  tmpStates=zeros(G.numRealTimes,2);
  %display(['Working on k=' num2str(kk)]);
  startOver=0;
  tmpSamp = zeros(1,G.numRealTimes);
  %% stochastically pick a start state
  startState = sampleDiscreteDistribution(G.statePrior);
  %% emit a symbol
  tmpSamp(1)=emitSymbol(G,startState,kk);
  tmpStates(1,:)=G.stateToScaleTau(startState,:);	
  lastState=startState;
  for ii=2:G.numRealTimes
    if (~startOver)
      tmpTrans = G.stateTrans{kk};
      nxtState = sampleDiscreteDistribution(tmpTrans(lastState,:));
      timeState=G.stateToScaleTau(nxtState,2);
      %[ii nxtState timeState]
      if (ii~=G.numRealTimes) & (timeState==G.numTaus)
	startOver=1;
	display('Starting over');
	break;
      end
      lastState=nxtState;
      tmpSamp(ii)=emitSymbol(G,nxtState,kk);
      tmpStates(ii,:)=G.stateToScaleTau(nxtState,:);	
    end
  end  
  if (~startOver)
    samples{kk}=tmpSamp;
    states{kk}=tmpStates;
    kk=kk+1;
    %kk
  end
end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given a state, emit a symbol

function symbol = emitSymbol(G,state,sampleNum)

z = G.z(G.stateToScaleTau(state,2));
phi = 2.^G.scales(G.stateToScaleTau(state,1));
u = G.u(sampleNum);

%if (isempty(phi))
%  keyboard;
%end

myMu = z*phi*u;
sigma = G.sigmas(sampleNum);

symbol = randn*sigma + myMu;

