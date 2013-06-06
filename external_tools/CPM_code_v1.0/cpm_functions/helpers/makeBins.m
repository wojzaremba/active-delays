% function reducedDimData =  makeBins(data,numBins)
% 
% reduce the dimensionality of each time series by
% evenly spreading out the feature mass into 'numBins'
% new features.

function newD =  makeBins(data,numBins)

if numBins==1
    newD=squeeze(sum(data,3));
    return;
end

%% for historical reasons, this expects data with
%% different dimensions, so permute to regain this
%% structure
data = permute(data,[2 3 1]);
[numT numMZ numE]=size(data);
% data should now be of dimensions [numTimePoints,numFeatures,numTimeSeries]
tmp=data;

totalPerMZ = sum(sum(tmp,1),3);
totalCount = sum(totalPerMZ);
massPerBin = totalCount/numBins;

%% find bins to use
binStarts = zeros(1,numBins);
binMass = zeros(1,numBins);
binStarts(1)=1;
mz=1;
nxtMZslice = totalPerMZ(mz);
REDUCE_MASS_PER_BIN=0; 
%for b=1:(numBins-1)
b=0;
restart=0; %% just to keep track, not necesesary

reduceFac=0.99;
binTolFrac=0.95;

%keyboard;
DONE=0;
while ~DONE %% for each bin
    b=b+1;
    binWeight=0;
    if REDUCE_MASS_PER_BIN
        %% have encountered a problem, so reduce the bin mass and
        %% try again
        restart=restart+1;
        if restart>50
            error('better look at whats going on');
        end
        massPerBin=massPerBin*reduceFac;
        disp('Reducing mass per bin');
        %% restart, but with less 'stuff' per bin
        b=1;
        binStarts = zeros(1,numBins);
        binMass = zeros(1,numBins);
        binStarts(1)=1;
        mz=1;
        nxtMZslice = totalPerMZ(mz);
        REDUCE_MASS_PER_BIN=0;
    end
    %disp(['working on bin=' num2str(b)]);

    %% add consecutive mz ions counts until have enough for this bin
    LAST_FLAG=0;
    while ~LAST_FLAG
        %% add this slice to the bin
        binWeight = nxtMZslice + binWeight;
        %% if it is over the amount, then no more
        %% (if we stop before adding this one, get more imbalance
        %%  of mass across bins)

        %% want it sometimes to be able to be larger, sometimes
        %% smaller, so as not to bias it.  
        randFlip=randn;
        if randFlip<=0
           leewayFrac=binTolFrac;
        else
           leewayFrac=1/binTolFrac;
        end
        if binWeight>=massPerBin*leewayFrac %% give it some leeway
                                  %% so that get more even distribution
                                  %% later
            LAST_FLAG=1;
        end
        %% set up next mz slice values for use
        mz = mz +1;
        if mz>=numMZ
            REDUCE_MASS_PER_BIN=1;
        else
            %disp(['adding mz=' num2str(mz)]);
            nxtMZslice = totalPerMZ(mz);
            if b==numBins-1 && LAST_FLAG
                DONE=1;
                break; % we're done
            end
        end
    end
  
  %% don't use next slice for this bin
  binStarts(b+1)=mz;
  binMass(b)=binWeight; %% original way
end
binMass(numBins)=sum(totalPerMZ(binStarts(end):end));

%figure,plot(binMass,'k-^'); keyboard;

tempDiff=sum(binMass)-totalCount;
if tempDiff/totalCount>1e-3
  error('Doesnt add up here.');
end

%% bin the data
newD = zeros([numT,numBins,numE]);
for b=1:numBins
  if (b~=numBins)
    theseBins=binStarts(b):(binStarts(b+1)-1); % original way    
  else
    theseBins=binStarts(b):numMZ;
  end
  %theseBins([1,end])
  newD(:,b,:) = sum(tmp(:,theseBins,:),2);
end

%% double check that sums are the same as they were
tmpSum = sum(sum(sum(newD)));
tmpDiff=tmpSum-totalCount;
if tmpDiff/tmpSum>1e-3
  error('Doesnt add up in getMZFeatures');
end

%% bin the data
newD = zeros([numT,numBins,numE]);
for b=1:numBins
  if (b~=numBins)
    theseBins=binStarts(b):(binStarts(b+1)-1); % original way    
  else
    theseBins=binStarts(b):numMZ;
  end
  %theseBins([1,end])
  newD(:,b,:) = sum(data(:,theseBins,:),2);
end

%% ERROR CHECKING:
%% double check that sums are the same as they were
tmpSum = sum(sum(sum(newD)));
tmpDiff=tmpSum-totalCount;
if tmpDiff/tmpSum>1e-3
  error('Doesnt add up in getMZFeatures');
end

newD=permute(newD,[3 1 2]);

return;

   