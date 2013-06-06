% function newMS = alignMS_MCMC(qmzT,scaleAndTimes,G)
%
% given a bunch of scaleAndTimes from MCMC, in space even
% denser than the 


function newMS = alignMS_MCMC(qmzT,scaleAndTimes,G,scaleType)

if scaleType~=0
    error('does not yet handle scaling');
end

%% each qmzT{1} is numRealTimes x numMZQuantizations

if ~exist('scaleType')
  error('Must provide scaleType, see help alignMS');
end

K = length(qmzT);
numQuant = size(qmzT{1},2);
newMS = cell(size(qmzT));

numMCMC=size(scaleAndTimes,1);

%% now find out how many latent times we need

numHiddenTime=maxx(scaleAndTimes(:,:,:,2));
%minHiddenTime=minx(scaleAndTimes(:,:,:,2));

%% for each sample, merge all the MCMC alignments
for k=1:K
    disp(['Aligning using MCMC on k=' num2str(k) ' of ' num2str(K)]);
    origDat = qmzT{k};  % eg. 401 x 2402 (time,M/Z)
    newDatMean = NaN*zeros(numHiddenTime,numQuant);
    t=cputime;
    for mc=1:numMCMC  
        if mod(mc,50)==0 || mc==1
            disp(['Merging state ' num2str(mc) ' of ' num2str(numMCMC) ' for sample ' num2str(k)]);
        end
        %disp(['Aligning using MCMC # ' num2str(mc)]);
        newDat = NaN*zeros(numHiddenTime,numQuant);

        usedTimes = squeeze(scaleAndTimes(mc,k,:,2))';       
        gapTimes=setdiff(1:numHiddenTime,usedTimes);
        newDat(usedTimes,:)=origDat;

        %%now interpolate (can do it all in one call since we
        %% are using the results of a 1D alignment, and thus
        %% the values being interpolated are the same for each
        %% M/Z slide.  For a general, 2D alignment, we cannot do this

        interpData = interp1q(usedTimes',origDat,gapTimes');
        %interpData = interp1q(usedTimes',origDat(:,1000)',gapTimes');
        newDat(gapTimes,:)=interpData;
        newDatMean=newDatMean+newDat;
    end
    newMS{k}=newDat/numMCMC;
    tt=cputime;
    disp(['Elapsed time is ' num2str(tt-t) ' seconds']);
end



