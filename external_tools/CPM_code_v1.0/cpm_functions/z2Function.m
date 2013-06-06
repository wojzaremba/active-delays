% function [l,f,d] = z2Function(z,G,offDiag,diagX,b,lambda,nu,allGammas,samples,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,gammaSum5,gammaSum6,tempSigs,u2);
%
% calculates the vector function, f, for fsolve in order to solve
% the non-linear system of equations
% 
% In terms of our specific problem, this function is computing
% the expected complete log likelhiood during the M step, as well 
% as the partial derivative and the Hessian of the expected
% complete log likelihood.
% 
% l is the expected complete log likelihood during M-Step
% f are the partial derivatives of l
% d is the jacobian of f,(hessian of l)
%
% l has dimensions [1,1]
% f has dimensions [1,M]
% d has dimensions [M,M]

% allGammas is a [1 x numSample] cell array of sparse gamma matrices,
% each of dimension [numStates x numRealTimes]

function [l,f,d] = z2Function(z,G,offDiag,diagX,b,samplesMat,...
    gammaSum1,gammaSum2,gammaSum5,gammaSum6,tempSigs,...
    u,u2,scalesExpRep,scalesExp2Rep,ubar2,binNum);

%display(['Calling z2Function with ' num2str(nargout) ' arguments']); keyboard;

lambda=G.lambda;
nu=G.nu;
%scaleEffect = 1;%1e-08;

%index goes c1m1, c1m2, ..., c1mM, ..., cCm1, ..., cCmM
C=G.numClass;
M=G.numTaus;

%if ~(G.useLogZ)
%  z=reshape(z,[M,C]); 
%else
  oldZ=z;
  q=reshape(z,[M,C]);
  z=exp(q);
%end

if any(isinf(z(:)))  || any(z(:)<0)
  l=realmax;
  f=realmax*zeros(1,M*C);
  d=realmax*zeros(M*C,M*C);
  return;
end


  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% this is theexpected complete log likelihood (remember, in LOG space)
%% (note it ignores the normalization part of the gaussian since this
%% drops out of the calculations, also when you multiply out the squared
%% brackets, the x terms drop out as well because they have no
%% z-dependency)!!! So only left with two terms, term1 and term2

%clear; load bug.mat;

hmmLikeForZU = getHMMlikeForZ(z,G,scalesExpRep,...
    gammaSum5,gammaSum6,u,u2,tempSigs,binNum);
l = hmmLikeForZU;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% now add in the regularization terms:
tmpTerm = getNuTermInd(G,z,binNum);
l = l + tmpTerm;

%tmpTerm=getSmoothLikeInd(G,z,binNum);
tmpTerm=getSmoothLikeZ(G,z,ubar2);
l = l + sum(tmpTerm);

%%% NO!  because I have removed terms not involving z!!! in the gaussian
% if l>=0 %% not possible since means p=1
%     warning('here');
%     %keyboard;
% end

%% want negative here because we are using fminunc rather than max
l=-l;%/scaleEffect;
%ubar2=getUbar2(G);
[f]=zFunction(z(:),G,offDiag,diagX,b,lambda,nu,ubar2,binNum);
f=-f;%./scaleEffect;


return;










%imstats(l)

%if (nargout==3) %compute partial derivatives and hessian
%  [f,d]=zFunction(z(:),G,offDiag,diagX,b,lambda,nu,binNum);
%  d=-d./scaleEffect;
%  if (any(~isfinite(d)))
    %display('z2Function not returning all finite values for d');
%    d(~isfinite(d))=realmax;
    %keyboard;
%  end
%elseif (nargout==2)
  [f]=zFunction(z(:),G,offDiag,diagX,b,lambda,nu,binNum);
%end

%if (nargout>=2)
  f=-f./scaleEffect;
%  if (any(~isfinite(f)))
    %display('z2Function not returning all finite values for f');
%    f(~isfinite(f))=realmax;
      %keyboard;
%  end
%end

%if (~isfinite(l))
  %display('z2Function not returning all finite values for l');
%  l(~isfinite(l))=realmax;
  %keyboard;  
  %length(~isfinite(oldZ))
%end

return;
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (1) %original way, slower
  LOGSQRT2PI=log(sqrt(2*pi));
  l=zeros(1,G.numSamples);
  for kk=1:G.numSamples
    tmpGammas = allGammas{kk};
    tmpSamp = samplesMat(kk,:);
    tmpClass = getClass(G,kk);
    logSigma = log(G.sigmas(kk));
    twoSigma2Inv = (2*G.sigmas(kk)^2)^(-1);
    for ii=1:G.numRealTimes
      [nonZeroStates,garb,nonZeroGammas] = find(tmpGammas(:,ii));
      emProbs = traceLogProb(G,tmpSamp(ii),z(:,tmpClass)',nonZeroStates,kk,logSigma,twoSigma2Inv,LOGSQRT2PI)';
      l(kk)=l(kk) + sum(nonZeroGammas.*emProbs);
    end
  end
  l=sum(l);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
