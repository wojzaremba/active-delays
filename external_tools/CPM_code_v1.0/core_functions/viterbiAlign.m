%function scaleAndTimes =
%  viterbiAlign(G,samples,trace)
%
%
% Do a viterbi alignment for all samples

function [scaleAndTimes, varargout] = viterbiAlign(G,allSamples)

numSamples = size(allSamples,1);
scaleAndTimes = zeros(numSamples,G.numRealTimes,2);

if nargout==2 %calculate residuals as well
  residuals = zeros(1,G.numSamples);
end

for ss=1:numSamples
  display(['Computing viterbi for sample ' num2str(ss)]);
  tic;
  thisSamp=squeeze(allSamples(ss,:,:))';
  if G.numBins==1
      thisSamp=thisSamp';
  end
  scaleAndTimes(ss,:,:) = propagate(G,thisSamp,G.z,ss);
  toc;

  %load /u/jenn/temp/viterbi.mat;
  %warning('h');keyboard;
  
  if (nargout==2) %calculate residuals as well
    if (G.numBins>1)
      error('needs to be modified to handle numBins>1');
    end
    st = squeeze(scaleAndTimes(ss,:,:));
    tempA=allSamples{ss};
    tempB=G.u(ss)*2.^(G.scales(st(:,1)));
    tempC=tempA(:)./tempB(:);
    myClass = getClass(G,ss);
    myMu=G.z(st(:,2),myClass,:)';
    avgSquareResidual = sqrt(mean((tempC'-myMu).^2));
    residuals(ss)=avgSquareResidual;
  end
end %% end over numSamples

if (nargout==2)
  varargout{1}=residuals;
end


