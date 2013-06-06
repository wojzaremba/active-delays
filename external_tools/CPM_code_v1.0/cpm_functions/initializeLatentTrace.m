% function [trace, flatSize] = initializeLatentTrace(G,samples,seed,RANDOMIZE_TRACE)
%
% produce a latent trace which is just the average of
% all traces, oversampled to cover the full range
%
% linear interpolation between the real samples is done.
% and then adds a small flat portion to both ends

function [trace2, flatSize] = initializeLatentTrace(G,samples,mySeed,smoothFrac)

if exist('mySeed') && ~isempty(mySeed)
  rand('seed',mySeed);
end

if G.zInitType==1 %version of one observed times series
    trace1=samples; 
elseif G.zInitType==2 %% use DTW to get an initialization     
    error('this is still expecting a cell array from old version of code');    
    if isempty(smoothFrac)
        smoothFrac=0.01; %% don't smooth it out too much so get use out of DTW!
    end
    K=length(samples); N=G.numRealTimes; B=G.numBins;
    if B==1
        X = reshape(cell2mat(samples),[N,K])';
        datUnroll=[];
    else %not sure if need a special case, but too lazy to check
        datUnroll = reshape(cell2mat(samples),[B,N,K]);
        %% sum out bins and align TIC with DTW
        X=squeeze(sum(datUnroll,1))';
        datUnroll=permute(datUnroll,[2 1 3]);
    end
    clear samples;
    refPos=G.startSamp;    
    halfBandWidth=0.05; maxBlockSize=10; maxSteps=2;
    [Xw,WP,Xw2] = ApplyDMW(X,refPos,datUnroll,[0 0],maxBlockSize,maxSteps,halfBandWidth);
    if B==1
        trace1 = mean(Xw,1);
    else
        trace1 = mean(Xw2,3)';
    end
end

tmp=zeros([G.numBins G.numRealTimes*G.timeRatio]);
if G.numBins>1
    for bb=1:G.numBins
        tmp(bb,:) = oversample(trace1(bb,:),G.timeRatio);
    end
else
    tmp = oversample(trace1,G.timeRatio);
end
trace1=tmp;
%figure, plot(trace1)

%% 'flat' is the slack that goes on either end, in addition to the upsampling

%smallFlat = minx(trace1);
flatSize = ceil(G.extraPercent*G.numRealTimes);
%flat = smallFlat*ones(G.numBins,flatSize);
%trace1 = [flat trace1 flat];

flat1 = trace1(:,1); 
flat1 = repmat(flat1,[1,flatSize]);
flat2 = trace1(:,end);
flat2 = repmat(flat2,[1,flatSize]);

trace1 = [flat1 trace1 flat2];

%% smooth the trace out
numSmoothPts=smoothFrac*length(trace1(1,:));
trace2 = zeros(size(trace1));
for bin=1:G.numBins
    tmp=trace1(bin,:);
    if smoothFrac==1
        trace2(bin,:) = mean(tmp);
    else
        %trace2(bin,:) = smooth(tmp,numSmoothPts); %% from curve Toolbox
        trace2(bin,:) = movingAverageFilter(tmp,numSmoothPts);
    end
    %figure,plot(trace2(bin,:));
    %keyboard;
end

if size(trace2,2)~=G.numTaus
  size(trace2,2)
  G.numTaus
  error('lengths dont match up');
end

%% we also need to adjust the G global variables to account
%% for the elongated trace


% figure, plot(trace2','+-','MarkerSize',1); title('Latent Trace');

