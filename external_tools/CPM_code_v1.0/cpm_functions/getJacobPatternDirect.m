function pattern = getJacobPatternDirect(G,input)

L=0;
if (G.updateZ)
  L=L+length(G.z(:));
end
if (G.updateU)
  L=L+length(G.u(:));
end
if (G.updateSigma)
  L=L+length(G.sigmas(:));
end

pattern = ones(L,L);

ind1 = 1;

% z wrt z
if (G.updateZ)
  ind2 = G.numTaus*G.numClass + ind1 -1;
  zInd = ind1:ind2;
  pattern(zInd,zInd)=getJacobPattern(G);
  ind1 = ind2 +1;
end

if (G.updateU)
  % u wrt u
  ind2 = ind1 + G.numSamples -1;
  uInd = ind1:ind2;
  pattern(uInd,uInd)=diag(ones(1,G.numSamples));
  ind1 = ind2 +1;
end

if (G.updateSigma)
  % wrt sigma
  ind2 = ind1 + G.numSamples -1;
  sigInd = ind1:ind2;
  pattern(sigInd,sigInd)=diag(ones(1,G.numSamples));
  ind1 = ind2 +1;
end


%if (G.updateTime)
%end
  
%if (G.updateScale)
%end

%if (G.updateTime | G.updateScale)
%end

return;

spy(pattern);
