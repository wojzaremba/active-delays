% function nothing = showTwoDPairs(usePairs,st,qmz,useWin,G,scaleType,...
%    thisWin,xp,saveFigs,imType,showAlignedOnly) 
%
% shows all pairs of aligned traces
% usePairs specifies pairs to use
% saveFigs=0/1 to save figures
% thisWin is a label for the Window that is used in saving file
% useWin is the actual window specification
% imType='jpg', or 'psc2', etc.
% xp is the experiment number fo the title
% if showAlignedOnly then only shows the aligned version
% if SHOW_DIFF, also shows difference between spectra

function nothing = showTwoDPairs(usePairs,st,qmz,useWin,G,scaleType,...
    thisWin,xp,saveFigs,imType,showAlignedOnly,SHOW_DIFF,extraStr,saveDir)

if (~exist('saveFigs'))
  saveFigs=0;
end

if ~exist('saveDir')
    saveDir='';
end

% if ~exist('useWin')==1 || isempty(useWin)    
%     [numTime, numMZ]=size(qmz{1});
%     useWin = [1 numTime 1 numMZ];
% end

numPairs=size(usePairs,1);
for pairs=1:numPairs
  display(['Working on pair ' num2str(pairs) ' of ' num2str(numPairs)]);
  useThese=usePairs(pairs,:);
  
  %qmzD=qmz(useThese);
  numSample=length(useThese);
  numRealTime=size(qmz{1},1);
  numMZ=size(qmz{1},2);

  exptxt = ['Replicates ' num2str(useThese(1)) ' and ' ...
      num2str(useThese(2))];
 
  showOverlayMS(qmz(useThese),st(useThese,:,:),useWin,G,scaleType,exptxt,...
      showAlignedOnly,SHOW_DIFF);
  
  if saveFigs
    numFigs=1;
    if ~showAlignedOnly
        numFigs=numFigs+1;
    end
    if SHOW_DIFF
        numFigs=numFigs+1;
    end
    filename = ['Window' num2str(thisWin) 'E_' num2str(xp) '_R' num2str(useThese(1)) '_' ...
        num2str(useThese(2)) '.' extraStr];
    theseInd = ((gcf-numFigs+1):gcf);
    savefigures(theseInd,1:length(theseInd),filename,imType,saveDir);
    %closefigures(1:numFigs);
  else
    %pause;
  end
end

