%function nothing=trainAndCV(lambda)
%
% Validate, keeping track of likelihood over each iteration

function nothing=trainAndCV(lambdas)

TEST=0;

%% number of iterations of EM on training set
maxIter=100;
if (TEST)
  lambdas=0;
  maxIter=10;
end

%%%%% Set up files, etc.
clear myhost;
[garb,myhost]=system('hostname'); 
myhost=myhost(1:(end-4));
dateCode = datestr(datevec(now),31);
dateCode(11)='.';

savevars = ['numTrain numTest testSetInd trainSetInd trainLL maxIter* testNumIt keepScans numLam lambdas allGtest allGtrain finalTraces holdOutLL myThresh updateScale updateSigma updateT updateZ'];

savedir = '/u/jenn/phd/MS/matlabCode/workspaces/cvLambda/';
if (TEST)
  savefile=['''' savedir 'test.mat'''];
  errorLogFile = [savedir 'test.LOG'];
  system(['\rm ' errorLogFile]);
else
  savefile = ['''' savedir 'cvLambdaIter.' num2str(lambdas,2) '.' dateCode '.' myhost '.mat'''];
  errorLogFile = savefile(1:(end-4));
  errorLogFile = [errorLogFile(2:end) 'LOG'];
end
  
cmd1 = ['save ' savefile ';'];
cmd2 = ['save ' savefile ' ' savevars ];
eval(cmd1);
display(['Will save results to: ' savefile]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% LOAD THE DATA
myDir = '/u/jenn/phd/MS/data/cocktail16/';
eval(['load ' '''' myDir 'data.mat''']); 
clear header qmz;

%%%%% SET UP THE DATA
dd=headerAbun;
headerAbun'
if (TEST)
  dd=getFakeSinCurves(20);
end
%showHeaderAbun(dd);

%%%%%% SET UP EXPERIMENT PARAMS
numLam = length(lambdas);
numRealTimes = length(dd{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Just hard code the test and training sets:

trainSetInd = [1 3 5 7 9]; 
if (TEST)
  trainSetInd = [1 3 5]; 
end
numTrain=length(trainSetInd);
%testSetInd  = [2 4 6 9 10];
testSetInd  = [2 4 6];
if (TEST)
  testSetInd  = [2];
end
numTest=length(testSetInd);

extraPercent=0.1;
initGTrain = getHMMParams(numTrain,numRealTimes);
initGTest = getHMMParams(1,numRealTimes);

traceLength = initGTest.numTaus;

%% Params we want to keep for every iteration of trained model
%% final trace
finalTraces = zeros(maxIter,traceLength);
%% likekihood of trained model
trainLL = zeros(1,maxIter);
%% likelihood of the hold out traces
holdOutLL = zeros(maxIter,numTest);
%% recovered transition parameters from training set
allGtrain = cell(maxIter);
%% recovered transition parameters from hold out case
allGtest = cell(maxIter,numTest);
%% number of iterations of EM in test set
testNumIt = zeros(maxIter,numTest);

%% EM options for both training and testing
updateSigma=1; updateT=1; myThresh=5*10^-4; 

trainSet = dd(trainSetInd);
testSet = dd(testSetInd);
latentTrace = initializeLatentTrace(initGTrain,trainSet);
oldTrace=latentTrace;

%% Fit the model
smooth=lambdas(1); 
tmp = ['smooth=' num2str(smooth,3)];
display(tmp);

for thisIt=1:maxIter;
  msg=sprintf('%s\n',['Train Iteration ' num2str(thisIt)])
  FPT=fopen(errorLogFile,'a');
  fprintf(FPT,msg);
  fclose(FPT);
  maxIterNow=1; %Only do one at a time so we can calculate hold out

  updateZ=1; updateScale=1;
  if (thisIt>1)
    oldTrace=newTrace;
    oldTmpLikes=tmpLikes1;        

    trainG = reviseG(initGTrain,G.S,G.D);

    [newTrace,G,tmpLikes1]=trainFBHMM(trainG,trainSet,oldTrace,smooth,updateSigma,updateT,updateScale,myThresh,updateZ,errorLogFile,maxIterNow,G.sigmas);
  else
    trainG=initGTrain;
    [newTrace,G,tmpLikes1]=trainFBHMM(trainG,trainSet,oldTrace,smooth,updateSigma,updateT,updateScale,myThresh,updateZ,errorLogFile,maxIterNow);

    %imstats(newTrace-oldTrace)
    %return;
  end
  

  finalTraces(thisIt,:)=newTrace;
  clear tempG;
  tempG.D=G.D;
  tempG.S=G.S;
  tempG.sigmas=G.sigmas;
  allGtrain{thisIt}=tempG;
  trainLL(thisIt)=tmpLikes1(end);

  %% check that likelhood matches up
  if ((thisIt>1) & (oldTmpLikes(end)~=tmpLikes1(1)))
    [oldTmpLikes(end)-tmpLikes1(1), oldTmpLikes(end), tmpLikes1(1)] 
    error(['Likelihoods dont match']);
  end

  %% Calculate likelihood of the hold-out samples
  for thisHold=1:numTest
    msg=sprintf('%s\n',['Hold Out Set ' num2str(thisHold)])
    FPT=fopen(errorLogFile,'a');
    fprintf(FPT,msg);
    fclose(FPT);

    %% these changes were not being passed on!!
    %initGTest.S=tempG.S;
    testG = reviseG(initGTest,G.S);
    
    if (TEST)
      maxIterTest=3;
    else
      maxIterTest=30;	  
    end
      
    if (0)
      display('NOW');
      imstats(oldTrace-newTrace)
      return;
    end
    display('NOW');
    imstats(newTrace)

    updateZ=0; updateScale=0;    
    [newTrace2,G2,tmpLikes]=trainFBHMM(testG,testSet(thisHold),newTrace,smooth,updateSigma,updateT,updateScale,myThresh,updateZ,errorLogFile,maxIterTest);
    clear tempG;
    tempG.D=G2.D;
    tempG.S=G2.S;
    tempG.sigmas=G2.sigmas;
    allGtest{thisIt,thisHold}=tempG;
    holdOutLL(thisIt,thisHold)=tmpLikes(end) - getSmoothLike(smooth,newTrace2);
    testNumIt(thisIt,thisHold)=length(tmpLikes);
  end
  display(['Saving results to: ' savefile]);
  eval(cmd2);
end
    


%% CREATE A MARKER FILE WHICH SHOWS THE COMPUTATION IS DONE
savefileFINISHED = savefile(1:(end-4));
savefileFINISHED = [savefileFINISHED 'FINISHED'];
cmd3 = ['save ' savefileFINISHED ''' savefileFINISHED ;'];
cmd3
eval(cmd3);

return;

