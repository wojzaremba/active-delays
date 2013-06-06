
%function [ll,alpha,beta,rho,flag] = 
%               FB(G,oneSample,sampleNum,latentTrace,doBackward)
%
% Do forward-backwards for one sample, and latent trace

function [ll,alpha,beta,rho,flag,transTerm] = ...
    FB(G,oneSample,sampleNum,latentTrace,doBackward);

%clear; load jenn.mat; [ll,alpha,beta,rho,flag] = FB(G,oneSample,sampleNum,latentTrace,doBackward);

flag=0; %in case rho goes to zero due to vanishingly small probabilties

if ~exist('doBackward','var')
  doBackward=1;
end

emProbs = zeros(G.numStates,G.numRealTimes);

%LOGSQRT2PI=G.numBins/2*log(2*pi); 	% generalized to multiD gaussian
%% NOTE: det(diagMat)=prod(diagElements), thus det(inv(a))=prod(1./diag(a))
%logSigma = log(G.sigmas(:,sampleNum));
%twoSigma2Inv = (2*G.sigmas(:,sampleNum).^2).^(-1);

[LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,sampleNum);
%[LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G.sigmas(:,sampleNum));

if G.USE_CPM2
	uMatRep = repmat(G.uMat(sampleNum,:),[G.numBins 1])';	    
end

thisTrans = G.stateTrans{sampleNum};
thisTrans2 = thisTrans';

myMuTemp = getMyMuTemp(G,sampleNum,latentTrace);

if G.USE_CPM2
    %% first time point, all bins
    emProbs(:,1) = traceProbU(G,oneSample(:,1),latentTrace,...
        1:G.numStates,sampleNum,logSigma,twoSigma2Inv,...
        LOGSQRT2PI,myMuTemp,uMatRep);
else
    emProbs(:,1) = traceProb(G,oneSample(:,1),latentTrace,...
        1:G.numStates,sampleNum,logSigma,twoSigma2Inv,...
        LOGSQRT2PI,myMuTemp);
end

%figure, plot(abs(log(emProbsP)-emProbsLogP'));
%imstats(abs(log(emProbsP)-emProbsLogP'))

%alpha = zeros(G.numStates,G.numRealTimes);
alpha = sparse(G.numStates,G.numRealTimes);
%alpha(:,1) = (G.statePrior' .* emProbsP);
alpha(:,1) = (G.statePrior' .* emProbs(:,1));
%alphaN = alpha;

rho = zeros(G.numRealTimes,1);
rho(1) = sum(alpha(:,1));
%display(['rho(1)=' num2str(rho(1))]);
alpha(:,1)=alpha(:,1)/rho(1);

if doBackward
  beta = zeros(G.numStates,G.numRealTimes);
  beta = sparse(G.numStates,G.numRealTimes);
  beta(:,end) = 1;
  %betaN=beta;
else
    beta='';
end

%tic
%profile 
%profile -detail operator on;
for t=2:G.numRealTimes
  %% FORWARD
  % emission probability for all states, with observed value, oneSample(t)
  
  if G.USE_CPM2
      emProbs(:,t) = traceProbU(G,oneSample(:,t),latentTrace,...
          1:G.numStates,sampleNum,logSigma,twoSigma2Inv,...
          LOGSQRT2PI,myMuTemp,uMatRep);
  else
      emProbs(:,t) = traceProb(G,oneSample(:,t),latentTrace,...
          1:G.numStates,sampleNum,logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp);
  end

  alpha(:,t) = thisTrans2*alpha(:,t-1).*emProbs(:,t);

  rho(t) = sum(alpha(:,t));
  
  %% this will kill on cputime
  if rho(t)<1e-300 || isnan(rho(t))
      display(['-------------' num2str(t) '---------']);
      sum(alpha(:,t))
      %load bug.mat;
      keyboard;
  end
  

  
%   %% HERE
%   if rho(t)<1e-300
%       figure,plot(rho(1:t)); title('rho(1:t)');
%       figure,plot(emProbs(:,t)); title('emProbs(:,t)');
%       figure,plot(alpha(:,t-1).*emProbs(:,t));title('alpha.*emProbs');
%       keyboard;
%   end
%   
  alpha(:,t) = alpha(:,t)/rho(t);
end

if any(isnan(alpha(:)))
    keyboard;
end
if any(isnan(rho)) || any(rho<1e-300)
    error('some rho isnan');
end

%%HERE
%figure,plot(rho); min(rho)
%keyboard;

if doBackward
  for tt=(G.numRealTimes-1):-1:1
    %% BACWARD
    beta(:,tt)= thisTrans*(beta(:,tt+1).*emProbs(:,tt+1));
    oldBeta = beta(:,tt); %% for debugging
    beta(:,tt) = beta(:,tt)/rho(tt+1);    
    %% slows it down to have in loop
%     if any(isnan(beta(:,tt))) || any(isinf(beta(:,tt)))
%         disp('found bad beta');
%         any(isinf(beta(:,tt)))
%         imstats(alpha);
%         imstats(beta(:,tt+1))
%         imstats(oldBeta)
%         imstats(emProbs(:,tt+1))
%         imstats(beta(:,tt+1).*emProbs(:,tt+1));
%         keyboard;
%     end
  end
end

if any(isnan(beta(:))) || any(isinf(beta(:)))
    disp('found bad beta');
    any(isinf(beta(:,:)))
    imstats(alpha);
    imstats(beta(:,:))
    imstats(oldBeta)
    imstats(emProbs(:,:))
    imstats(beta(:,:).*emProbs(:,:));
    keyboard;
end

%toc
%profile off; profile report;
%gamma = full(alpha.*beta);

%%% debug stuff %%%%%%%%%%%%
if (0)
  badRho = find(rho==0);
  badRho2 = find(rho<1e-200);
  if (length(badRho)>0)
    display(['length(badRho)=' num2str(length(badRho))]);
    flag=1;
    badRho
    warning('WARNING: one of rho=0'); 
  elseif (length(badRho2)>0)
    display(['length(badRho2)=' num2str(length(badRho2))]);
    badRho2
    warning('WARNING: some rho<1e-200, but trying to continue');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doBackward
    badBeta = find(isnan(beta)|isinf(beta));
    if length(badBeta)>0
        %length(badBeta)
        warning('WARNING: some isnan(beta)');
        flag=1;
        keyboard;
    end
end

if (0)%(flag)
  warning('h'); keyboard;
end

if any(isnan(alpha(:)) | isinf(alpha(:)))
  warning('WARNING:some isnan(alpha)');
  keyboard;
end

ll = sum(log(rho)); %equals the log likelihood


return;


%%% double check for sanity

alphaN=full(alphaN);
betaN=full(betaN);
ll1 = (log(sum(alphaN(:,end),1)));
[ll ll1]
ll-ll1

gamma = (alphaN.*betaN)/exp(ll1);
max(abs(gamma(:,end)-alphaN(:,end)))
ll3 = (sum(gamma,1));
unique(ll3)'
max(abs(diff(ans)))

gamma2 = full(alpha.*beta);
ll4 = sum(gamma2,1);
unique(ll4)'
max(abs(diff(ans)))

imstats(gamma,gamma2);

keyboard



figure, show(alpha);
figure, show(beta);

figure, show(log(alpha));
figure, show(log(beta));

figure, show(log(gamma));
lkOS = sum(gamma,1);
seqProb=lkOS(1);  %may have more than one from rounding errors.

temp=unique(lkOS)';
whos temp;
temp
figure, plot(lkOS,'+');


%gammas = alphaslog.*betaslog;
%check = sum(gammas,1);
%temp=unique(check(1:(end-1)));
%whos temp
%figure, plot(temp,'+');
