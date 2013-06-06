function [TP FP FN precision recall foundStren fdInd] = ...
    compWithGroundTruth(foundPeaks,foundPeaksDir,...
        realPeaks,strengths,mzTol,expDir)     
    
%% get prec/recall
%% 'foundPeaks' has the m/z values for each peak
%% 'foundPeaksDir' has the direction (+/-) that they are in
%% 'expDir' has the expected direction of the 'realPeaks'
%%
%% makes sure not to double count TP or FP twice
        
TP=0;
FP=0;
FN=0;

foundPeaksAccountedFor=zeros(1,length(foundPeaks));
realPeaksFoundFlag = zeros(1,length(realPeaks));
foundStren=[]; fdInd=[];
dup=0;

for fp=1:length(foundPeaks)
    thisPk = foundPeaks(fp);
    thisSign = foundPeaksDir(fp);
    matchedToRealPeak=0;
    for rp=1:length(realPeaks)
        thatPk = realPeaks(rp);
        thisStren=strengths(rp);
        signCheck = (thisSign==expDir);
        matchedToRealPeak = (abs(thatPk-thisPk)<=mzTol) && signCheck;
        if matchedToRealPeak
            found = realPeaksFoundFlag(rp);
            foundPeaksAccountedFor(fp)=1;
            if ~found  %% ignore if already matched this one
                TP=TP+1;
                realPeaksFoundFlag(rp)=1;
                foundStren=[foundStren; thisStren];
                fdInd = [fdInd rp];
                break;
            else
                dup=dup+1;
            end
        end
    end    
end

%% cluster the remaining false positives
remFP=foundPeaks(find(~foundPeaksAccountedFor));
if length(remFP)>2
    fpClust = clusterdata(remFP(:),'distance','euclid',...
        'linkage','complete','cutoff',mzTol,...
        'criterion','distance');
    %% find cluster centers
    clustInd = unique(fpClust);
    FP=length(clustInd);
elseif length(remFP)==2
    if abs(diff(remFP))<mzTol
        FP=1;
    else
        FP=2;
    end
elseif length(remFP)==1
    FP=1;
else
    FP=0;
end

FN=length(find(~realPeaksFoundFlag));

precision=TP/(TP+FP);
recall=TP/length(realPeaks);

if recall>1 || recall<0 || precision<0 || precision>1
    disp('how can that be?!');
    keyboard;
end

disp(['Precision=' num2str(precision,3) ...
    ', Recall=' num2str(recall)]);
