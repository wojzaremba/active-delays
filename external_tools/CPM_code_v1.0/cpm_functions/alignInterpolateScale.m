% function newData = alignInterpolateScale(data,scaleAndTimes,G,scaleType)
%
% given alignments in scaleAndTimes (from Viterbi, or posterior sampling,
% or however else you choose to find an alignment), align and scale
% the data as the trained model dictates, then linearly interpolate to find
% values for the latent time points which have not been mapped to.
%
% NOTE: for data that lies outside of any used latent times, this data
% is not interoplated, and takes on the value NaN
%
% 'data' should be of dimensions [numTimeSeries numRealTimes numBins]
%
% 'scaleAndTimes' should be of dimension [numTimeSeries,numRealTimes,2]
% in the form provide, for example, by viterbiAlign.m
%
% OPTIONS --How to scale or not scale the data:
% if scaleType=0,  the no scaling is done
% if scaleType=1,  then only HMM scale state scaling is done
% if scaleyType=2, then HMM scaling and global scaling is done
% if scaleyType=3, then only global scaling is done 
% (where 'global scaling' refers to the scaling spline, if being used, 
%  otherwise, just to the single global scale factor)

function newData = alignInterpolateScale(data,scaleAndTimes,G,scaleType)

%% each qmzT{1} is numRealTimes x numMZQuantizations

if ~exist('scaleType')
  error('Must provide scaleType, see help alignMS');
end

[numSamples numRealTime numBins]=size(data);
newData = zeros([numSamples G.numTaus numBins]);

%% align,scale and interpolate each sample
for kk=1:numSamples       
    
  % get hidden states which contain alignment/scaling information
  st = squeeze(scaleAndTimes(kk,:,:)); % numSamples x numRealTimes x 2
  origDat = squeeze(data(kk,:,:));     % numRealTimes x numBins
     
  % depending on options, scale appropriately
  
  if scaleType==0
      % no scaling, use origDat as is
  elseif scaleType==1 
      % scale according to the HMM scale states
      repscales = repmat(2.^G.scales(st(:,1)),[numBins 1])';
  elseif scaleType==2  %% HMM AND global scaling
      if ~G.USE_CPM2 %% i.e. if not using a scaling spline
          repscales = G.u(kk)*repmat(2.^G.scales(st(:,1)),[numBins 1])';
      else %% if using a scaling spline
          tmpU = G.uMat(kk,:);
          tmpScales = 2.^G.scales(st(:,1))'.*tmpU(st(:,2));
          repscales = repmat(tmpScales,[numBins 1])';
      end
  elseif scaleType==3 %% only global scaling
      if ~G.USE_CPM2
          repscales = G.u(kk);
      else
          tmpU = G.uMat(kk,:);
          repscales = repmat(tmpU(st(:,2)),[numBins 1])';
      end
  end
  
  if scaleType>0 %make scale corrections
      if numBins==1
          %repscales=repscales';
          origDat=origDat';
      end
      origDat = origDat./repscales;
  end

  %% Now do the interpolation
  tmpDat  = NaN*zeros(G.numTaus,size(origDat,2));
  usedTimes = st(:,2)';
  gapTimes=setdiff(1:G.numTaus,usedTimes);
  tmpDat(usedTimes,:)=origDat;
  
  %% now interpolate (can do it all in one call since we
  %% are using a single alignment for all bins, and thus
  %% the values being interpolated are the same for each
  %% bin.
  interpData = interp1q(usedTimes',origDat,gapTimes');
  tmpDat(gapTimes,:)=interpData;
  newData(kk,:,:)=tmpDat;
end


return;







