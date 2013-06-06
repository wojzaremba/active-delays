%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tmpSig = makePeak(position,width,height,signalLength,noise,baseValue,dataScale)

numPeaks=length(position);

tmpSignal = makeFlat(signalLength,noise,baseValue);
tmpSig = tmpSignal;

for pk=1:numPeaks
  ht = dataScale*height(pk);
  tmpPeak = mkGaussian([1,width(pk)],sqrt(width(pk)));
  tmpPeak = tmpPeak*ht/max(tmpPeak);
  left = round(position(pk) - (length(tmpPeak)/2));
  right = round(left + length(tmpPeak)-1);
  tmpSig(left:right)=tmpPeak + tmpSig(left:right);
end
% figure, plot(tmpSig,'+-');

%% now add noise
tmpSig = tmpSig + randn(size(tmpSig))*noise;
tmpSig(tmpSig<0)=baseValue;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tmpSignal = makeFlat(signalLength,noise,baseValue)

%% make flat bit:
tmpSignal = randn(1,signalLength);
tmpSignal = tmpSignal*noise + baseValue;

