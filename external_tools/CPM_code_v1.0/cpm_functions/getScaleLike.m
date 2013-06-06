% function scaleLik = getScaleLike(G,u)
%
% Computes the log likelihood resulting from the log
% prior on u_k's, which have a log-normal distribution.

function scaleLik = getScaleLike(G,u)

scaleLik=0;

if G.uType==1
    scaleLik=0;
elseif G.uType==2
    LOGSQRT2PI = log(sqrt(2*pi));
    logSigma = log(G.w);
    twoSigma2Inv = (1/2)*(1./(G.w.^2));
    u=u(:); %% in case using CPM2
    
    for jj=1:length(u)
        newTerm = lognormpdf(log(u(jj)),0,logSigma,...
            twoSigma2Inv,LOGSQRT2PI,G.numBins);
        scaleLik = scaleLik + newTerm;       
    end
    %% this is the other term I forgot from the log normal!!! (Aug 21,2006)
    scaleLik = scaleLik -sum(log(u));
end

return;

