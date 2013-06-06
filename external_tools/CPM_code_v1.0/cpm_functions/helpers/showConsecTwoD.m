function showConsecTwoD(mzRg,timeRg,stTrain,qmz,G,SAVE_FIGURES,extraStr,imageDir);

%% Interesting windows to zoom in on.
clear myWin; nxt=1;

%% time, m/z
myWin{nxt} = [timeRg mzRg]; nxt=nxt+1;
% myWin{nxt}=[150,350,700,1200]; nxt=nxt+1; %1
% myWin{nxt}=[300,450,900,1200]; nxt=nxt+1; %1
% myWin{nxt}=[150,450,600,1200]; nxt=nxt+1; %1
% myWin{nxt}=[50,450,400,1200]; nxt=nxt+1; %1

thisWin=1;

%allPairs = getAllPairs(1:Gtrain.numSamples);
%usePairs=allPairs;
usePairs =[];
for jj=2:length(qmz)
    usePairs = [usePairs; [jj-1 jj]];
end

scaleType = 3;  %% see alignMS for help on this
showAlignedOnly=0; SHOW_DIFF=0;

showTwoDPairs(usePairs,stTrain,qmz,...
    myWin{thisWin},G,scaleType,...
    thisWin,1,SAVE_FIGURES,'all',showAlignedOnly,SHOW_DIFF,extraStr,imageDir);

