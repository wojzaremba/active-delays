function derivU = uHelper(G,gammaSum3,gammaSum4,scalesExp)

derivU = zeros(1,G.numSamples);
C=G.numClass;

scalesExpRep = repmat(scalesExp,[G.numSamples 1 G.numBins]);
scalesExpRep = permute(scalesExpRep,[2 1 3]);

theseClasses = getAllClass(G);
zPhi = G.z(G.stateToScaleTau(:,2),theseClasses,:).*scalesExpRep;
gammaSum3=permute(gammaSum3,[3 2 1]);
gammaSum4=permute(gammaSum4,[3 2 1]);

sig2inv = 1./G.sigmas.^2';

if (G.numBins>1)
  numerator =   sum(squeeze(sum(zPhi.*gammaSum3,1)),2);
  denominator = sum(squeeze(sum(zPhi.^2.*gammaSum4,1)),2);
else
  numerator =   sum(sum(zPhi.*gammaSum3,1),1)';
  denominator = sum(sum(zPhi.^2.*gammaSum4,1),1)';
end

traceDiffs = squeeze(sum(diff(G.z,1,1).^2));
if (G.numBins>1)
  traceDiffs = sum(traceDiffs,1);
end
traceDiffs = traceDiffs(:,theseClasses);

extraTerm = -2*G.lambda*traceDiffs./G.numPerClass(theseClasses).*G.u;

derivU = (numerator - G.u'.*denominator).*sig2inv + extraTerm';

if (any(isinf(derivU)) | any(isnan(derivU)))
  warning('derivU is screwed up, look at sum(gammaX,1) ');
  keyboard;
end
