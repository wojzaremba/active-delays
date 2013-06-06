% function stateTransLog = getStateTransLog(G)
%
% Creates a sparse transition matrix, using the scale
% and time transition matrixes that are provided in G.


function stateTransLog = getStateTransLog(G)

for ss=1:G.numSamples
  %tic
  
  myClass = getClass(G,ss);
  timeTransLog = G.timeTransLog{ss};
  % for each state, find all the states that it can transfer to
  stateTransTemp = sparse(G.numStates,G.numStates);

  %% it is not sparse in log space...
  %stateTransLog = -Inf*ones(G.numStates,G.numStates);

  for st=1:G.numStates
    thisScale=G.stateToScaleTau(st,1);
    thisTau=G.stateToScaleTau(st,2);
    %[precStates, precTaus, precScales] = getStateTransIn(thisScale,thisTau,G);
    tempPrec = G.prec{st};
    precStates = tempPrec(:,1);
    precTaus   = tempPrec(:,2);
    precScales = tempPrec(:,3);
    tempLogStateTrans = G.scaleTransLog(precScales,thisScale,myClass) ...
        + timeTransLog(precTaus,thisTau);
    if (tempLogStateTrans==0)
      %tempLogStateTrans=log(1-eps);%% HERE?! should this be realmin
      tempLogStateTrans=-Inf;%log(1-realmin);
    end
    stateTransTemp(precStates,st)=tempLogStateTrans;
  end

  stateTransLog{ss}=stateTransTemp;
  %toc;
end

return;


