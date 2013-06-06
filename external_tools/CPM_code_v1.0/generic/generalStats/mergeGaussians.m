%function [newMean,newVar,logconst]=...
%                mergeGaussians(theseMeans,theseVar)
%
% Merge together many scalar gaussians, obtaining the
% new mean/variance, and the constant (log of) that comes out.
%
% This uses the 'mixing' identity and is used throughout 
% Kalman Filtering, for example

function [newMean,newVar,logconst]=...
                mergeGaussians(theseMean,theseVar)
                      
N=length(theseMean);

newVar = theseVar(1);
newMean = theseMean(1);
logconst=zeros(1,N);

% then recurse
for j=2:N
    [newMean, newVar, newlogconst]  = mergeHelper(...
        newMean,newVar,theseMean(j),theseVar(j));
    logconst(j) = newlogconst;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% merges just 2 gaussians together
function [newMean newVar newLogConst] = ...
    mergeHelper(mmean1,vvar1,mmean2,vvar2)

newVar  = (1/vvar1 + 1/vvar2)^(-1);
newMean = newVar*(mmean1/vvar1 + mmean2/vvar2);
newLogConst = lognormpdfVar(mmean1,mmean2,vvar1+vvar2);

%older, slower way
%newLogConst = normpdfln(mmean1,mmean2,[],vvar1+vvar2);