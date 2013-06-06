% function newSt = getLinearWarp(allSamp,scaleAndTimes,newGKeep)
%
% Does a simple linear warping as follows:
%
% Uniformly sample the latent trace between the first point and
% the last point.

function newD = getLinearWarp(allSamp,scaleAndTimes,newGKeep)

M=newGKeep.numTaus;
N=length(allSamp{1});
myRange = 1:N;

for kk=1:newGKeep.numSamples
  start=scaleAndTimes(kk,1,2);
  stop=scaleAndTimes(kk,end,2);
  myLen = stop-start+1;
  myInterval = myLen/N;
  tmpDat = start:myInterval:stop;
  if (0)
    [start stop]
    [tmpDat(1),tmpDat(end)]
    [tmpDat' scaleAndTimes(kk,:,2)']
    figure, plot(tmpDat,scaleAndTimes(kk,:,2),'+-');
  end
  newD{kk}=tmpDat;
end
