% function newG = reviseAllG(G,input)
%
% Given G, and an input vector 'input', constructed by
% getGuessVec(G), adjust G so as to reflect these parameters


function newG = reviseAllG(G,input)

%% 'last' and 'ind' are for indexing into input to get the
%% parameters out in the same way we put them in

newG = G;
ind=1;

if (G.updateZ)
  last = length(G.z(:)) + ind -1;
  tmpZ = reshape(input(ind:last),size(G.z));
  if (G.useLogZ)
    tmpZ = exp(tmpZ);
  end
  newG.z = tmpZ;
  ind = last+1;
end

if (G.updateU)
  last = length(G.u(:)) + ind -1;
  newG.u = reshape(input(ind:last),size(G.u));
  ind = last+1;
end

if (G.updateSigma)
  last = ind;
  %% have to be careful here, only have one sigma per class in 'input'
  for cc=1:G.numClass
    newG.sigmas(G.class{cc}) = input(ind:last);
    ind = last+1;
    last = ind;
  end
end

if (G.updateTime)
  last = length(G.D(:)) + ind -1;
  newD = reshape(input(ind:last),size(G.D));
  ind = last+1;
end
  
if (G.updateScale)
  last = length(G.S(:)) + ind -1;
  newS = reshape(input(ind:last),size(G.S));
  ind = last+1;
end

if (G.updateTime | G.updateScale)
  newG = reviseG(G,newS,newD);
end
