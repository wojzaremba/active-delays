% function scaleTransLogN = getLogScaleTrans(G)
%
% Calculate the log scale transition probabilities,
% using values defined in structure G,
%
% (normalized probabilities)

function scaleTransLogN = getLogScaleTrans(G)

if (G.oneScaleOnly)
  scaleTransLogN=zeros(1,1,G.numClass);
  return;
end

scaleTransLogN = zeros(G.numScales,G.numScales,G.numClass);

for cc=1:G.numClass

  % starts off in non-log space, then log afterards
  scaleTransLog = zeros(G.numScales,G.numScales);
  
  for sc1=2:G.numScales-1
    scaleTransLog(sc1,(sc1-1:sc1+1)) = [(1-G.S(cc))/2 G.S(cc) (1-G.S(cc))/2];
  end
  
  %% boundary conditions that we are not updating - they are 
  %% always the same.
  scaleTransLog(1,1:2) = [0.9 0.1];
  scaleTransLog(end,(end-1:end)) = [0.1 0.9];
  
  warning off;
  scaleTransLog = log(scaleTransLog);
  warning on;
  scaleTransLog(isnan(scaleTransLog))=-Inf;

  scaleTransLogN(:,:,cc) = scaleTransLog;
end

return;


figure, show(scaleTransLogN);
