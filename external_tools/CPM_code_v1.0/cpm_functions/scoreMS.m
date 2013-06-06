% function [SEScore dotScore totVarScore] = 
%    scoreMS(newMSTrain,numRemove,classes)
%
%% Score an MS alignment on the basis of variance (or MAD)
%%
%% Assumes that all spectra are the same length.
%% Removes 'numRemove' times from the end and beginning, since these
%% are often NaN from the interpolation (because they lie outside
%% the boundary points of known values).
%%
%% if classes is provided, then it does it seperately for each
%% class and then averages the results
%%
%% returns the AVERAGE scores (i.e takes in to account
%% how many m/z and time points were used
%%
%% SEScore is the average standard error


function [stdScore dotScore normFac SEScore] = ...
    scoreMS(ms,numRemove,classes)

if ~exist('numRemove','var'); 
    numRemove=[0 0];
end

if iscell(ms)
    msMat = msCell2Mat(ms);
    numSamples = length(ms);
    [numTaus numMZ] = size(ms{1});
    keepRange = (1+numRemove(1)):(numTaus-numRemove(2));
    msSmall = msMat(:,:,keepRange);
elseif 0%length(size(ms))==2
    [numSamples,numTaus]=size(ms);
    msMat=ms;
    keepRange = (1+numRemove(1)):(numTaus-numRemove(2));
    msSmall = msMat(:,keepRange);
else
    error('cant handle this case now');
end

if ~exist('classes','var');
    classes{1} = 1:numSamples;
end
numClass=length(classes);

%% sanity check
if 0
    tmp3 = squeeze(msMat(:,3,:))';    
    figure,show(isnan(tmp3)); colorbar;
    
    tt3 = ms{3};
    figure,show(isnan(tt3));
    
    a=find((tt3~=tmp3));
    whos a
    if any(tt3~=tmp3)
        keyboard;
    end
end

%% but remove the trailing and leading X time points which
%% likely have NaNs due to the interpolation

if any(isnan(msSmall(:)))
    warning('some nan values');
    keyboard;
end

%% calculate the entropy at each location
%scorePerPos=getEntropyScore(msSmall);

%% force the mean to be one over the entire set of samples
%msSmall = msSmall/(sum(sum(sum(msSmall))));

msSmall = permute(msSmall,[2 1 3]);

outlierFrac=0; % fraction to remove from top and bottom

stdScore=zeros(1,numClass);
dotScore=zeros(1,numClass);
%totVarScore=zeros(1,numClass);

for cc=1:numClass
    tmpInd = classes{cc};
    if length(tmpInd)<2
        error('need at least 2 from each class');
    end
    tmpDat = msSmall(tmpInd,:,:);
    msVar  = varonline(tmpDat);

    if outlierFrac~=0
        msVar = removeOutliers(msVar,outlierFrac);
    end
    varScore(cc) = sum(msVar(:));
    %stdScore(cc)=sqrt(varScore(cc)); %%WRONG!
    stdScore(cc)=sum(sqrt(msVar(:)));

    msDot = squeeze(prod(tmpDat));
    msDot = removeOutliers(msDot,outlierFrac);
    dotScore(cc) = sum(msDot);
    
    %for jj=1:
    %totVarScore(cc) = 
end

%% normalize to account for different truncations on time
%% (and just throw in numMZ for the hell of it, though I 
%% expect this to be constant when comparing sets of
%% experiments)
normFac = length(keepRange)*numMZ;
dotScore=dotScore/normFac;
varScore=varScore/normFac;
stdScore=stdScore/normFac;
SEScore=stdScore/sqrt(numSamples);

return;






% msMean  =   squeeze(mad(msSmall,0));
% msMean = removeOutliers(msMean,outlierFrac);
% meanScore = sum(msMean);
% 
% msMedian  = squeeze(mad(msSmall,1));
% msMedian = removeOutliers(msMedian,outlierFrac);
% medianScore = sum(msMedian);