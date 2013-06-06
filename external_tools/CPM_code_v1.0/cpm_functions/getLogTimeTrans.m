% function timeTransLogN = getLogTimeTrans(G)
%
% Calculate the log time transition probabilities,
% using values defined in structure G, and an
% normal distribution.
%
% (normalized probabilities)

function timeTransAll = getLogTimeTrans(G)

for ss=1:G.numSamples
  % starts off in non-log space, then log afterards
  timeTransLog = zeros(G.numTaus,G.numTaus);

  for tm1=1:G.numTaus-G.maxTimeSteps%4 %should have been 3?
    timeTransLog(tm1,(tm1+1:tm1+G.maxTimeSteps)) = G.D(ss,:);
  end
  %% always force the last G.maxTimeSteps time states to have the same
  %% transition probabilties, regardless of the value of G.D
  %% since these have fewer legal transitions, and hence would
  %% have to be updated seperately, and there are too few data
  %% to do this
  
  for lt=(G.maxTimeSteps-1):-1:1 %-1 because last one should be zero
    timeState = G.numTaus-lt;
    toStates = (timeState+1):G.numTaus;
    fixedProb = 1/length(toStates);
    timeTransLog(timeState,toStates) = fixedProb;    
  end

  %% the above is a generalization of what we had for 3 states:
  %timeTransLog(end-2,(end-1:end)) = [0.5 0.5];
  %timeTransLog(end-1,end) = [1];    

  warning off;
  timeTransLog = log(timeTransLog);
  warning on;
  timeTransLog(isnan(timeTransLog))=-Inf;
  timeTransAll{ss}=timeTransLog;
end

if ~exist('timeTransAll')
    keyboard;
end

return;



show(exp(timeTransLogN),'Normalized Time Transitions');

a=sum(exp(timeTransLogN),2);
figure, plot(a,'+');
unique(a)

b=exp(timeTransLogN);
b(1,1:5)
b(2,1:5)
