%function  [peakMap peakMapIntens peakCoord peakMax
%           peakSum peakMean peakMZ peakMin] = ...
%    findPeaks2(dat,thresh,useP,datSign)
%
% given a matrix which consists of blurred welch T stats on 
% aligned mass spec data, and a threshold, find all peaks
% which appear after thresholding with that threshold
%
% 'datSign' gives the 'sign' of each pixel.  only pixels
% with the same sign can be assigned to the same peak
%
% 'peakMap' colours each peak a unique colour/integer
% peakMapIntens shows the intensity for each peak
% the integer will be negative if the peak has a neg. sign
    
function  [peakMap peakMapIntens peakCoord...
    peakMax peakSum peakMean peakMZ peakMin peakDir] = ...
    findPeaks2(dat,thresh,useP,datSign)

peakMap=''; peakMapIntens=''; peakCoord=''; peakMax='';
peakSum=''; peakMean=''; peakMZ=''; peakMin='';

%% threshold first:
if ~useP
    tmpW = zeros(size(dat));
    highInd = find(abs(dat)>=thresh);
else
    tmpW = ones(size(dat));
    highInd = find(dat<=thresh);
end
tmpW(highInd)=dat(highInd);
%% figure, show(tmpW); colorbar;

disp(['Length thresholded dat=' num2str(length(highInd),3)]);

%% now find out where the peaks are and what area the cover:

%% create and 'accounted' for mask which says whether each
%% pixels has been assigned to a peak.  Then iterate through
%% each pixel.  If it is on, and not yet part of a peak, then
%% grow a peak around it:
%% keep track of where the maximum value is, this will be it's
%% 'center'.  Also add up the value of all its pixels, this will
%% be its 'importance', and also keep track of where all its pixels
%% are in a the 'accounted' map, which will have 0 for non-peak
%% associated pixels, and otherwise an integer ID indicating which peak
%% the pixel belongs to.

%% the 'accounted' map -- has +1 for positive peaks and -1 for neg.
peakMap = zeros(size(dat));
[numR numC]=size(peakMap);

if ~useP
   [peakR peakC] = find(tmpW);
   peakInd = find(tmpW);
else
   [peakR peakC] = find(tmpW~=1);
   peakInd = find(tmpW~=1);
end

%peakMax=zeros(size(dat));
%peakMax(peakInd)=dat(peakInd);
peakMax=dat(peakInd);
peakSum=peakMax;
tmp1=datSign(peakInd); tmp2=(1:length(peakInd));
peakLabels=tmp1(:).*tmp2(:);
peakMap(peakInd)=peakLabels;
numPeaks = length(peakLabels);
peakMapIntens=zeros(size(dat));
peakMapIntens(peakInd)=dat(peakInd);
peakDir = datSign(peakInd);



peakCoord=[peakR(:) peakC(:)];
% account for qmz quanitzation
peakMZ=coordToMz(peakCoord(:,2));

return;



peakID=1;
for pix=1:length(peakR)
    rr=peakR(pix);
    cc=peakC(pix);    
    thisSign = datSign(rr,cc);    
    peakMap(rr,cc)=peakID*thisSign;
    peakID=peakID+1;
end

%disp(['On pix=' num2str(pix) ' of ' num2str(length(peakR),3)]);


if 0    
    figure,show(peakMap*10); colorbar;
        figure,show(peakMap>0); colorbar;
    for jj=1:numPeaks
        figure,show(peakMap==peakLabels(jj)); colorbar;
        numPixels = length(find(peakMap==peakLabels(jj)));
        title(['Peak ID ' num2str(peakLabels(jj)) ...
            '  # ' num2str(numPixels)]);
    end
    %colmap='jet(15)'; colormap(colmap);
    figure,show(tmpW); colorbar;
end


%% for each peak, get coordinates, and the total itensity
%% max val coordiantes
peakCoord  = zeros(numPeaks,2);
peakMax = zeros(numPeaks,1);
peakMin = zeros(numPeaks,1);
peakSum = zeros(numPeaks,1);
peakMean = zeros(numPeaks,1);
peakMapIntens = zeros(size(peakMap));
peakDir = zeros(numPeaks,1);
for jj=1:numPeaks
    thisPeak = peakLabels(jj);
    theseInd = find(peakMap==thisPeak);
    [thisR thisC] = find(peakMap==thisPeak);
    peakVals = tmpW(theseInd);
    peakSum(jj)=peakVals;
    %peakMax(jj)=max(peakVals);
    %peakMin(jj)=min(peakVals);
    tmpPeakDirs = datSign(theseInd);
    %if length(unique(tmpPeakDirs))>1
    %    error('one peak with 2 different signs');
    %end
    peakDir(jj)=tmpPeakDirs(1);
    peakCoord(jj,1)=thisR;
    peakCoord(jj,2)=thisC;
    %peakMapIntens(find(peakMap==thisPeak)) = peakSum(jj);
    %peakMapIntens(find(peakMap==thisPeak)) = peakMax(jj);
    numPix = length(theseInd);   
    peakMean(jj)=peakSum(jj)/numPix;
    %peakMapIntens(find(peakMap==thisPeak)) = peakMean(jj);
end

%peakMarks = makePeakMarks(peakCoord,peakSum,size(peakMap));    

%% find out which mz each peak corresponds to based on the
%% coordinates:

LOW=400;
numDig=2;
% account for qmz quanitzation
peakMZ=convertIndToMz(peakCoord(:,2));


if 0    
    figure, show(peakMarks); colorbar;
end

disp(['Found ' num2str(length(peakSum)) ' peaks']);

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [neighR,neighC] = getNeighbours(rr,cc,dims);
%% return set of neighbours that have already been analyzed
%% in the loop (and hence may have been assigned a peak

neighR=[]; neighC=[];
nxt=0;
for r=(rr-1):(rr+1)
    for c=(cc-1):(cc+1)
        if r>=1 && c>1
            nxt=nxt+1;
            neighR(nxt)=r;
            neighC(nxt)=c;
        end
    end
end

goodVal = neighR<=dims(1) & neighC<=dims(2);
neighR=neighR(find(goodVal));
neighC=neighC(find(goodVal));

return;