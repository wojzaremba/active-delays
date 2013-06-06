%function [newGKeep,sampInd,newTrace,likes,allTraces,gammas,alphas,rhos,scaleAndTimes,twoDTrace]=trainModel(smooth,nu,ALL_UPDATES,ONE_CLASS,numBins,useG,startTrace,sigmas)
%
% Load up the spiked data set, and train the model
% using expSet \in [1 2 3 4 5], each of which consists
% of 4 repeats.  
%
% setSize is the number of replicates to train at at time
% (perahps less than numReplicates if corss-validating)
% expSet is which experiment to work on
%
% initTrace tells you which trace to initialize to
%
% default for setSize is number of replicates (eg 4)
%
% 'sigmas' should be given in a vector, with one per class.


function [newGKeep,sampInd,newTrace,likes,allTraces,gammas,...
    alphas,rhos,scaleAndTimes,twoDTrace]=...
    trainModel(smooth,nu,ALL_UPDATES,ONE_CLASS,numBins,useG,startTrace,sigmas)

if (nargin<5)
  txt= 'Putting in default settings of:';
  txt=[txt 'ALL_UPDATES=1 '];
  txt=[txt 'HessianOn=off '];
  txt=[txt 'LargeScaleOn=on '];
  txt=[txt 'ONE_CLASS=0 '];
  display(txt);
  display('Type return to continue')
  keyboard;
  ALL_UPDATES=1;
  ONE_CLASS=0;
end

HessianOn='off';
LargeScaleOn='on';

USE_EM=1;
TEST=0; USE_PROFILE=0;
ONE_SCALE_ONLY=0;

useLogZ=1;
myThresh=1e-5;
if (TEST)
  maxIter=2;
else
  maxIter=50; %HERE
end

if (ALL_UPDATES)
  updateSigma=1;
  updateT=1;
  if (~ONE_SCALE_ONLY)
    updateScale=1;
  else
    updateScale=0;
  end
  updateU=1;
  updateZ=1;
else %% just some updates
  updateT=0;
  updateScale=0;
  updateSigma=1;
  updateU=1;
  updateZ=1;
end

startSamp=1; 
traceNoise=0.15;%0.25;%1;%0.5;

%DAT=2; 
%DAT=5;
DAT=7;
%DAT=1;
if (DAT==1)
  dataDir = 'cocktail16'; numRep=6; %numRep=13;
  extraPercent=0.1;
  classes{1} = 1:numRep;
  maxTimeSteps=3;
elseif (DAT==2)
  extraPercent=0.2;
  %dataDir = 'spikedInData'; numRep=4; numExp=5;
  dataDir = 'spikedInDataTwoClass'; numRep=4; numExp=2;
  if (0)
    classes{1} = 1:numExp*numRep;
  else
    for cc=1:numExp
      classes{cc} = (1:numRep) + (cc-1)*numRep;
    end
  end
  maxTimeSteps=3;
elseif (DAT==3)
  extraPercent=0.2; maxTimeSteps=3;
  %extraPercent=0.5; maxTimeSteps=5;
  %extraPercent=0.5; maxTimeSteps=10;
  %dataDir = 'speech1'; numRep=4;
  dataDir = 'speech2'; numRep=10;
  classes{1} = 1:numRep;
elseif (DAT==4)
  dataDir='spikedInMZ1296';
elseif (DAT==5)
  dataDir='test1';
elseif (DAT==6)
  dataDir='spikedInMZ1296TwoClass';
elseif (DAT==7)
  dataDir='serum2class';
end

display(['dataDir=' dataDir]);
myDir = ['/u/jenn/phd/MS/data/' dataDir '/'];
eval(['load ' '''' myDir 'data.mat''']); 


%% not whole data set?
if (DAT==5)
  classes{1}=[2:4]; classes{2}=[6:8];
  sampInd = cell2mat(classes);
  allSamp = headerAbun(sampInd);
  classes{1}=[1:3]; classes{2}=[4:6];
end

if (ONE_CLASS)
  tmp= cell2mat(classes);
  clear classes;
  classes{1}=tmp;  
end


%figure, showHeaderAbun(headerAbun);

sampInd = cell2mat(classes);


%%For quick testing%%%%%%%%%%%%%%%%%%%%%%%
if (TEST & DAT~=5)%HERE
  display('TESTING!!!!!!!!!!!!!!!!!!!!!!!');
  %keepMe=55:75;
  keepMe=215:220;
  %keepMe=100:150;
  for ii=1:length(headerAbun)
    temp=headerAbun{ii};
    headerAbun{ii}=temp(keepMe);
    temp=qmz{ii};
    qmz{ii}=temp(keepMe,:);
  end
  %clear classes; classes{1}=1:5;
  sampInd = cell2mat(classes);
end

if (length(headerAbun{1})>300)
  ITER_SAVE=1;
else
  ITER_SAVE=0;
end

%% create a multi-D feature vector?
if (numBins>1)
  headerAbun = getMZFeatures(qmz,numBins);
  clear qmz;
end

allSamp = headerAbun(sampInd);
setSize=length(allSamp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% log files, etc.
if (TEST)
  savedir = '/u/jenn/phd/MS/matlabCode/workspaces/test/';
else
  savedir = ['/u/jenn/phd/MS/matlabCode/workspaces/trainModel/'];
end
      
basename = [savedir dataDir '.size' num2str(setSize) '.S' num2str(smooth,3) '.N' num2str(nu)  '.'  filenameStamp];

profFILE = [basename '.PROFILE'];
logfile = [basename '.LOG'];
savefile = [basename '.mat'];
savefileFINISHED = [basename '.FINISHED'];

if (ITER_SAVE) %save after every iteration of trainFBHMM
  saveIterFile=savefile;
else
  saveIterFile='';
end


global LOGSQRT2PI;
LOGSQRT2PI=getLOGSQRT2PI;

allG=''; latentTrace=''; smoothLikes=''; mainLikes='';
newGKeep=''; newTrace=''; likes=''; scaleAndTimes='';
twoDTrace=''; allTraces='';

savevars = 'elapsed allG latentTrace smoothLikes mainLikes newGKeep sampInd newTrace likes scaleAndTimes twoDTrace allTraces';

cmd1 = ['save ''' savefile ''' smooth;'];
cmd2 = ['save ''' savefile ''' ' savevars ];
cmd3 = ['save ''' savefileFINISHED ''' savefileFINISHED ;'];

eval(cmd1);

display(['Will save results to: ' savefile]);


if (USE_PROFILE)
  profile on -detail operator on;
end


%% Some constants needed for the HMM
randomInit=0; %i.e. COMPLETELY random, not just noise added
if (TEST)
  randomInit=0;
end

if (~exist('useG'))
  G = getHMMParams(length(sampInd),size(allSamp{1},2),classes,extraPercent,startSamp,maxTimeSteps,ONE_SCALE_ONLY,traceNoise,randomInit,useLogZ,HessianOn,LargeScaleOn,numBins,smooth,nu,updateScale,updateT,updateSigma,updateU,updateZ,maxIter,myThresh,ITER_SAVE);
else
  G=useG;
end

if (~exist('useG') & exist('sigmas'))
  %% one per class
  for cc=1:G.numClass
    G.sigmas(G.class{cc})=sigmas(cc);
  end
  G.varsigma = mean(G.sigmas)^2;
end

if (~exist('numBins'))
  numBins=1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~exist('useG'))
  if (~exist('startTrace') | isempty(startTrace))
    if (TEST & ~randomInit)
      %% so that always get the exact same starting position
      randSeed = 931316785;
      display('Using TEST randomSeed');
      latentTrace = initializeAllLatentTrace(G,allSamp,randSeed);
    else
      latentTrace = initializeAllLatentTrace(G,allSamp);
    end
  else
    display(['Using startTrace']);
    latentTrace=startTrace;
  end
  G.z=latentTrace;
else
  latentTrace=G.z;
end

%% initialize to only ONE of the traces (plus noise so no
%degeneracy)
%figure, plot(latentTrace,'+-'); return;

%% train model

if (USE_EM)
  [errorFlag,newTrace,newG,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG] = trainFBHMM(G,allSamp,logfile,saveIterFile);
else
  [errorFlag,newTrace,G,newG,likes,elapsed] = trainDirect(G,allSamp,logfile,saveIterFile);
end

display(['Elapsed ' num2str(sum(elapsed))]);


if (errorFlag)
  display('trainFBHMM returned erroFlag=1');
  keyboard;
end

newGKeep=stripG(newG);

eval(cmd2);

%%debug: reinstate newG so that can continue
%newG=reviseG(G,newGKeep{1}.S,newGKeep{1}.D); newG.sigmas=newGKeep{1}.sigmas;

%% get alignment
%load /w/27/jenn/phd/MS/matlabCode/workspaces/spiked/final.Long.March21.2004/problems/debut.mat;

if (0)
  display('Getting alignments');
  scaleAndTimes = viterbiAlign(newG,allSamp);
  warning('viterbi'); keyboard;
end
    
eval(cmd2);
  
%% get twoD trace
if (0) %HERE
  display('Getting 2D trace');
  thisSmooth=0;
  twoDTrace=getTwoDLatentTrace(qmz(sampInd),gammas,newG,thisSmooth);
else
  display('NOT getting 2D trace');
end

eval(cmd2);
eval(cmd3);

if (USE_PROFILE)
  profile off;
  profile report;
  p = profile('info');
  save profFILE p
end

myLikes = likes;
mydiff = [0 diff(myLikes)];
badInds = find(mydiff<0);
if (length(badInds)>0)
  display('At least one drop in likelihood');
  keyboard;
end

if (0)%(TEST)
  %% likelhoods
  myLikes = likes;
  figure,plot(myLikes,'-+');
  title('Log likelihood during training');
  xlabel('Iteration');
  ylabel('Log likelihood');
  mydiff = [0 diff(myLikes)];
  badInds = find(mydiff<0);
  hold on;
  plot(badInds,myLikes(badInds),'ro','MarkerFaceColor','r');
  legend('Likelihood','Decreased Likelihood',3);
  maxDiff = max(abs(mydiff(badInds)));
  meanDiff = mean(abs(mydiff(badInds)));
  mytxt = ['Maximum drop in log likelihood=' sprintf('%.3e',maxDiff)];
  text(0.3, 0.5, mytxt, 'Units', 'Normalized','FontSize',11);
  mytxt = ['Mean drop in log likelihood=' num2str(meanDiff)];
  text(0.3, 0.45, mytxt, 'Units', 'Normalized','FontSize',11);
  %mytxt = ['Xtol=' num2str(mytolx)];
  %text(0.3, 0.4, mytxt, 'Units', 'Normalized','FontSize',11);
  %mytxt = ['mean fval=' num2str(mean2(abs(myfval)))];
  %text(0.3, 0.35, mytxt, 'Units', 'Normalized','FontSize',11);
  %mytxt = ['max fval=' num2str(max2(abs(myfval)))];
  %text(0.3, 0.3, mytxt, 'Units', 'Normalized','FontSize',11);
  mytxt=['Number of drops = ' num2str(length(badInds))];
  text(0.3, 0.25, mytxt, 'Units', 'Normalized','FontSize',11);
  %savefigures(1,1,'trainingLikelihood');
end

%% Look at traces
if (TEST)
  %initTrace=squeeze(allTraces(1,:,:));
  %figure,plot(initTrace,'+-'); title('Initial Traces');
  
  figure,plot(newG.z,'+-'); 
  tmpStr = ['Final Traces, \nu=' num2str(G.nu,3) ' \lambda=' num2str(G.lambda,3) ' ' 'logLike=' num2str(myLikes(end),10)];
  title(tmpStr);
  keyboard;
end
if (0)
  figure,showHeaderAbun(allSamp);
  
  mydiff=abs(initTrace-newTrace);
  imstats(mydiff);
  figure, plot(mydiff,'+-'); title('diff');
  maxx(mydiff)/mean(mean(newTrace))*100
  
  tempSamp = reshape(cell2mat(allSamp),[G.numRealTimes,G.numSamples]);
  figure, plot(tempSamp, '+-'); title('Experimental Data');
end

display('Finished trainModel'); %keyboard;

return;














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Look at the results


numIt=size(allTraces,1)
filename = '/u/jenn/temp/matlabFigures/';

%% traces
figure,
for ii=1:numIt
  plot(squeeze(allTraces(ii,:,:)),'+-');
  title(['It ' num2str(ii)]);
  if (ii==1)
    ax=axis;
  else
    axis(ax);
  end
  pause;
end

figure, plot(allTraces(end,:),'+-');
title('Final Trace');

numPlots=3;
%% Display all before alignments
figure,subplot(numPlots,1,1),showHeaderAbun(allSamp);
%title('Replicate Total Ion Counts, Uncallibrated and Callibrated');
title('Unaligned Replicate Audio Amplitude Time Signals');
xlabel('');

% display all after alignments, with the latent trace
subplot(numPlots,1,2),showAlignedAll(newGKeep,allSamp,scaleAndTimes,newTrace);
%title('Aligned Experimental TICs');
title('Aligned and Scaled Replicate Audio Amplitude Time Signals');
ylabel(''); 
xlabel('');

% display time correction    
if (numPlots==3)
  subplot(numPlots,1,3,'replace'),
  showScale=0;
  showAlignedAll(newGKeep,allSamp,scaleAndTimes,newTrace,showScale);
  mytitle= 'Time Corrected';
  title(mytitle);
end

if (0)
  base='speech2FourSamples';
  saveas(H,[filename base '.eps'],'psc2');
  saveas(H,[filename base '.jpg']);
  saveas(H,[filename base '.fig']);
end

%% Display the alignment with final trace:
for ii=1:newGKeep.numSamples
  st = squeeze(scaleAndTimes(ii,:,:));
  mytitle=['Replicate ' num2str(ii)];
  [H,allAxes]=getAxes(5);
  displayAlignment(newGKeep,allAxes,newTrace,st,allSamp{ii},mytitle,newGKeep.sigmas(ii),ii);
  %base = 'viterbiAlignment';
  %base = 'speechIndividualAlignment';
  %saveas(H,[filename base num2str(ii) '.eps'],'psc2');
  %saveas(H,[filename base num2str(ii) '.jpg']);
  %saveas(H,[filename base num2str(ii) '.fig']);
  %pause;
  %close(H);
end

%%% display the time states verus sequential time labels.
numRealTimes = size(scaleAndTimes,2);
timesFixOffset = scaleAndTimes(:,:,2)';
timesFixOffset = timesFixOffset - repmat(timesFixOffset(1,:),[numRealTimes,1]);

%% normally
H=figure, plot(scaleAndTimes(:,:,2)','+-','MarkerSize',2);
title('Movement Through Latent Time');
xlabel('Sequential Time Label');
ylabel('Hidden Time State');
axis([200 250 300 600]);


[H,allAxes]=getAxes(2);
%% correcting for offset
axes(allAxes(1));
plot(timesFixOffset,'+-','MarkerSize',2);
title('Movement Through Latent Time Space');
xlabel('Sequential Time Label');
ylabel('Hidden Time State');

%% ZOOM-IN, correcting for offset
axes(allAxes(2));
plot(timesFixOffset,'-','MarkerSize',2);
%title('Movement Through Latent Time');
%xlabel('Sequential Time Label');
%ylabel('Hidden Time State');
axis([200 250 300 550]);



base = 'speechTimeScales';
saveas(H,[filename base '.eps'],'psc2');
saveas(H,[filename base '.jpg']);
saveas(H,[filename base '.fig']);
