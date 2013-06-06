% function [scaleAndTimes,newTrace,scores]=trainViterbiHMM(G,samples,initTrace)
%
% Use Viterbi EM-like algorithm to train HMM model using
% initTrace as the initial latent trace guess.


function [scaleAndTimes,newTrace,scores,allTraces]=trainViterbiHMM(G,samples,initTrace)

maxIter = 10;
thresh = 1/1000000; % one part in one million
%thresh = eps;
numSamples = length(samples);
sigmas = getInitSigmas(numSamples,latentTrace);

scores = zeros(1,maxIter);
oldScore=-Inf;
numIt=0; keepGoing=1; 
currentTrace = initTrace;
allTraces = zeros(maxIter, length(currentTrace));

%figure,plot(initTrace,'+'); title(['Iteration ',num2str(numIt)]);

while (keepGoing)
  numIt = numIt+1;
  
  if (mod(numIt,1)==0)
    display(['Iteration: ' num2str(numIt)]);
  end

  tempScore = zeros(1,numSamples);
  for ii=1:numSamples
    [scaleAndTimes{ii},tempScore(ii)]=propagate(G,samples{ii},currentTrace,sigmas(ii));
  end
  
  %% Look at the alignments to make sure they look sane
  if (0)
    for ii=1:numSamples
      theSample = allSamples{ii};
      theSampleUp = resample(theSample,G.timeRatio,1);
      st = scaleAndTimes{ii};
      
      figure,
      subplot(2,1,1),plot(theSampleUp, 'k+'); 
      hold on; plot(currentTrace,'r^');
      legend('Sample Trace', 'Latent Trace');
      title('Before Alignment');
      %bounds = axis;
      axis([0 350 0 12*10^8]);
      
      subplot(2,1,2), plot(st(:,2)',theSample./2.^(G.scales(st(:,1))),'k+');
      hold on; plot(currentTrace,'r^');
      legend('Sample Trace', 'Latent Trace');
      title('After HMM Alignment');
      %axis(bounds);
      axis([0 350 0 12*10^8]);
    end
  end
  
  newTrace = getNewTrace(samples,scaleAndTimes,currentTrace,G);
  allTraces(numIt,:)=newTrace;
  % figure,subplot(2,1,1),plot(newTrace,'k+');title('newTrace'); subplot(2,1,2),plot(currentTrace,'r*'); title('oldTrace');
  currentTrace=newTrace;

  plot(currentTrace,'+'); title(['Iteration ',num2str(numIt)]);
  
  newScore = (sum(tempScore));
  %newScore
  scores(numIt)=newScore;
  if (newScore<oldScore)
    warning('score went down!');
  elseif ((newScore-oldScore)/abs(newScore) < thresh)
    keepGoing=0;
  end
  if (numIt==maxIter)
    warning('Did not converge, max num iterations reached');
    keepGoing=0;
  end
  oldScore=newScore;  
end

display(['FINAL Iteration: ' num2str(numIt)]);

scores = scores(1:numIt);

%whos scores
return;


figure, plot(scores(1:(numIt-1)),'^'); title('scores');

figure,
for ii=1:(numIt-1)
  plot(allTraces(ii,:),'*'); 
  title('Latent Trace');
  pause;
end
