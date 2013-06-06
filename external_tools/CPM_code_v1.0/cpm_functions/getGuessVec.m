% function vec = getGuessVec(G)
%
% Given the parameters in G, build a vector of paramters to be
% used as initializating to our minimization routine when doing
% direct gradient ascent rather than EM.
%
% This takes log(G.z) for z so that we can ensure z is positive always

function vec = getGuessVec(G)

vec = [];

if (G.updateZ)
  if (G.useLogZ)
    vec = [vec; log(G.z(:))];
  else
    vec = [vec; G.z(:)];
  end
end

if (G.updateU)
  vec = [vec; G.u(:)];
end

%% we want to restrict sigma so that there is only one per class
if (G.updateSigma)
  tmpSigmas = [];
  for cc=1:G.numClass
    thisInd = G.class{cc};
    thisInd = thisInd(1);
    tmpSigmas = [tmpSigmas; G.sigmas(thisInd)];
  end
  vec = [vec; tmpSigmas];
end

if (G.updateTime)
  vec = [vec; G.d];
end
  
if (G.updateScale)
  vec = [vec; G.S];
end
