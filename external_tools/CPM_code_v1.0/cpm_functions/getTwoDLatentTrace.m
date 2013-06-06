% function trace = getTwoDLatentTrace(qmzD,gammas,G,lambda)
%
% Given the posterior over states (gammas), and the model
% parameters, do a single 'MStep' per M/Z slice to find the
% latent trace.
% NOTE: lambda here will need to be much less than with the
% 1D latent trace since it should be proportional to the magnitude
% of the trace, which should be much less here, on a M/Z by M/Z basis.
% In fact, in an ideal world, we would have a different lambdas for
% different M/Z slices.

function trace = getTwoDLatentTrace(qmzD,gammas,G,lambda)
% qmzD=qmz(1:5); lambda=10^7/2000; G=newG; gammas=alphas.*betas;

%% M-step-like update likelihood, with a smoothing prior
%% on the latent trace.

K=G.numSamples;
M=G.numTaus;
N=G.numRealTimes;
numMZ = size(qmzD{1},2);

trace = zeros(G.numTaus,numMZ);
X = zeros(M,M+1);

%% Now do update as in 1D training, but do for each M/Z

%% However, a large part of the required matrix is the same
%% for each M/Z slice.  We do this first, then loop over M/Z

for jj=1:M
    validStates=find(G.stateToScaleTau(:,2)==jj);          
    vs{jj}=validStates;
    %%%% X(j,j)
    %%sum over gammas
    gammaSum1=zeros(length(validStates),G.numSamples);
    for xp=1:K
      tempGam = gammas{xp}; %numStates x numRealTimes
      %a=sum(tempGam(validStates,:),2); whos a; clear a;
      %whos gammaSum1 validStates
      gammaSum1(:,xp) = sum(tempGam(validStates,:),2);
    end
    %gammaSum = squeeze(sum(gammas(validStates,:,:),2));
    repSigs  = repmat(G.sigmas,[length(validStates),1]);
    sumSigs  = sum(repSigs.*gammaSum1,2)';
    tempScales = 2.^(G.scales(G.stateToScaleTau(validStates,1)));
    termJJ   = sum(tempScales.*tempScales.*sumSigs);
    X(jj,jj) = 4*-lambda - termJJ;
    if (jj~=M)
      X(jj,jj+1) = -2*-lambda;
    end
    if (jj~=1)
      X(jj,jj-1) = -2*-lambda;
    end
end        
%% correct the boundary conditions
X(1,1) = X(1,1) - 2*-lambda;
X(M,M) = X(M,M) - 2*-lambda;

%samples=reshape(cell2mat(qmzD'),G.numRealTimes,G.numSamples,numMZ);
%whos samples
%a=squeeze(samples(:,3,:)); imstats(a-qmz{3})


%%%% X(j,M+1)  
tic;
for mz=1:numMZ    
  %% in trainFBHMM, samples2 = (numSamples,numRealTimes)
  %samples2=samples(:,:,mz);
  if (mod(mz,50)==0)
    display(['On ' num2str(mz)]);
    toc;tic;
  end  
  for jj=1:M
    validStates=vs{jj};
    %repsamples = repmat(samples2,[1,1,length(validStates)]);
    %repsamples = permute(repsamples,[3,1,2]);
    %gammaSum   = squeeze(sum(gammas(validStates,:,:).*repsamples,2));

    gammaSum2=zeros(length(validStates),G.numSamples);
    for xp=1:K
      samples=qmzD{xp}; %numRealTimes x numMZ
      samples2=samples(:,mz);
      repsamples = repmat(samples2,[length(validStates),1]);
      tempGam = gammas{xp}; %numStates x numRealTimes
      gammaSum2(:,xp) = sum(tempGam(validStates,:),2);
    end
    
    sumSigs    = sum(repSigs.*gammaSum2,2)';
    X(jj,M+1) = sum(tempScales.*sumSigs); 
    
    %mzTrace = C'/XX; %B/A ~ B*inv(A)  I have ZX=C, Z=C*inv(X)
  end
  mzTrace = -X(:,M+1)'/X(:,1:M);
  trace(:,mz)=mzTrace';
end
