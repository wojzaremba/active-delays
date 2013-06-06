function [LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,sampleNum)

%function [LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(sigmas)

%LOGSQRT2PI=G.numBins/2*log(2*pi); % generalized to multiD gaussian
%LOGSQRT2PI=2*log(2*pi); % generalized to multiD gaussian
LOGSQRT2PI = log(sqrt(2*pi));

%% NOTE: det(diagMat)=prod(diagElements), thus det(inv(a))=prod(1./diag(a))
%detCov = prod(G.sigmas(:,sampleNum).^2);
%logSigma = 1/2*log(detCov);


logSigma = log(G.sigmas(:,sampleNum));
twoSigma2Inv = (1/2)*(1./(G.sigmas(:,sampleNum).^2));


