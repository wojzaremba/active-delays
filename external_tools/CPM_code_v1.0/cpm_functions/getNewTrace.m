%function newTrace =
%        getNewTrace(samples,scaleAndTimes,currentTrace,G)
%
% After Viterbi-alligning all the samples to the currentTrace,
% update the latent trace, by averaging, and smoothing.

function endTrace = getNewTrace(samples,scaleAndTimes,currentTrace,G)

newTrace = zeros(size(currentTrace));
%keep track of how many samples have an entry at each fake time point
traceCounts = newTrace;
numSamples = length(samples);

%% Average
for ii=1:numSamples
  st = scaleAndTimes{ii};
  newTrace(st(:,2)) = newTrace(st(:,2)) +...
      samples{ii}.*2.^(G.scales(st(:,1)));
  traceCounts(st(:,2)) = traceCounts(st(:,2)) + 1;
end

notZero = find(traceCounts);
newTrace(notZero) = newTrace(notZero)./traceCounts(notZero);

% Interpolate for places with zero counts
isZero = setdiff(1:length(traceCounts),notZero);
interpPts = interp1q(notZero',newTrace(notZero)',isZero');
newTrace(isZero)=interpPts;
% interp1q returns NaN for pts that need to be extrapolated
% let's deal with these by setting them to the minimum value
newTrace(isnan(newTrace))=min(newTrace);


% Smooth
myfilt = [1 1 1 1 1];
myfilt = myfilt/sum(myfilt);
smoothTrace = rconv2(newTrace,myfilt);
% figure, subplot(2,1,1),plot(newTrace,'k+'); subplot(2,1,2),plot(smoothTrace,'r*');

endTrace = smoothTrace;
%endTrace = newTrace;

%figure, plot(currentTrace,'k+'); hold on; plot(newTrace,'r^');
%figure, plot(traceCounts,'+');




