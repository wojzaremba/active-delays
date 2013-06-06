% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%% Demonstration of use of the single class EM-CPM %%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all; 
% %dbstop if error; 
% more off;

addpath(genpath('/home/wojto/bio/Dropbox/CPM_code_v1.0/'));
%% check that the CPM matlab path has been added
if ~exist('makeBins','file')
    error('Please make sure that the full CPM directory structure is on your path');
end

%% check that version of minimize is ok
checkMinimizeVersion();

%% check that maxSparseMEX.c has been compiled
checkMaxSparseMEX();

% load the data (here stored in variable called 'data')
%    -here each time series has 400 time points, where each point
%    - is a vector of length 2402, and there are 11 time series
%    - data is of dimensions [numTimeSeries,numTimePoints,numFeatures]
%    - see DATA/README.txt for explanation of the data set

if exist('eColi_singleClass_11perClass.mat','file')
   load eColi_singleClass_11perClass.mat;
else
   error('Please add eColi_singleClass_11perClass.mat to your path');
end

% NOTE: this data has been pre-processed with a single shift and a
% single global scaling factor for each observed time series.  If
% your data has huge variations in these respects, it would be wise
% to do a similar pre-processing -- otherwise you risk bad local minima, 
% and/or slow convergence.

% Choose some reduced dimensionality version of the data, if desired
% This function spreads out the mass of the features evenly across
% a new set of smaller features (i.e. in an LC-MS experiment, it tries
% to distribute the ion abundance evenly).  One could instead use PCA, for
% example.
numBins=1; %i.e. the dimensionality of the vector at each time point 
data= makeBins(data,numBins);

%% WARNING: dimensionality of each time point increases the CPU time 
%%          roughly linearly, and one often need not use the full
%%          dimensionality to get good results.  Furthermore, in my
%%          useage so far, I often get numerical problems for more than
%%          24 dimensions (numBins).

[numTimeSeries,numTimes,numBins]=size(data);

%% sum out the features and take a look if you want
%figure,plot(squeeze(sum(data,3))','-'); title('Reduced Dimensionality Pre-ALigned Data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set EM-CPM options %%
maxIter=10; % max number of iterations allowed (10 might look pretty good, but
            % more is probably better).  Play around with your problem to
            % see what you need, or just set it running for 100 iterations
            % and wait.
myThresh=10^-5; % convergence tolerance on log likelihood 
                % (will pursue this difference until maxIterations is reached)
USE_SPLINE=0; % if set to 1, uses spline scaling rather than HMM scale states
numCtrlPts=10; % if USE_SPLINE=1, then this allows the number of spline control
              % points to be set.  If USE_SPLINE=0, this variable is ignored.
oneScaleOnly=0; % if USE_SPLINE=0, this allows us to use no HMM scale states
                 % in which case only a single global scaling factor is 
                 % applied to each time series.
extraPercent=0.05; % the length of the latent trace(s) will be constructed
                   % so that, for observed time series of length N, it will
                   % have length M = 2*(N+extraPercent);
lambda=0; % smoothing penalty on latent trace (positive only -- higher 
          % is more smooth)
nu=0;     % inter-trace penalty for multi-class version 
          %(ignored if only one class specified; positive only -- higher is
          % tighter correspondance between classes)
learnStateTransitions=0; % whether to learn the HMM state transition probabilities
                         % this is very expensive, and provides little benefit.
learnGlobalScaleFactor=1; % learn the single global scale factor for each time series
learnEmissionNoise=1;     % learn the HMM emission noise for each time series
learnLatentTrace=1;       % learn the latent trace(s)
initLatentTrace=[];       % capability to specify the initial latent trace
                          % if desired -- leave blank for an automatic
                          % initialization.  Should be of same dimensions
                          % as that returned by the training algorithm
                          % (i.e. [numLatentTimes numClass numBins] where,
                          % numLatentTimes =  2*G.numRealTimes + 2*ceil(extraPercent*numRealTimes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Indicate which indexes of the data set are for training, and for hold out
% (test) and which class each belongs to (here we're doing single class)
%%%%%%
%% **IF** YOU DON'T WANT TO RUN TEST data (i.e. if you just want to
%% align all of the data you have) AND you want a SINGLE_CLASS alignment, 
%% then just use these settings, as they are written here (unmodified)
if 0
    trainSetInd=1:numTimeSeries;
    testSetInd=[];
    thisClass=1;
    classesTrain{thisClass}=trainSetInd;
    classesTest{thisClass}=[];
%%%%%%
%% **ELSEIF** you want TRAIN AND TEST, SINGLE-CLASS
%% alignment, TAILOR THIS TO YOUR LIKING,
else 
    trainSetInd = [1 3 5 7 9 11];  %% indexes of 'data' to be used for training
    %testSetInd = [2 4 6 8 10];     %% indexes of 'data' to be used for testing
    testSetInd=[]; %% to make demo faster...don't test at all
    %% now specify the classes of each of these (we're just using one class here)
    %% (this is relative to their ordering in trainSetInd/testSetInd)
    thisClass=1;  %% do it for each class, if more than 1
    classesTrain{thisClass}=1:length(trainSetInd);
    classesTest{thisClass} =1:length(testSetInd);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specify where to dump log files and saved workspaces while training:
%% THREE files will be created: 
%% 1) .mat file containing saved results
%% 2) .LOG file containing printout of stuff during training/testing
%% 3) .FINISHED file which indicates the method trainTestEMCPM has finished
%% Leave empty if don't want to use these
%saveDir=[pwd '/'];   saveName='eColi'; 
saveDir = '';        saveName = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% train/test the EM-CPM
[allGtrain allGtest logLikesTrain logLikesTest]=trainTestEMCPM(...
    data,trainSetInd,testSetInd,classesTrain,classesTest,...
    USE_SPLINE,oneScaleOnly,maxIter,numCtrlPts,extraPercent,...
    lambda,nu,myThresh, learnStateTransitions,learnGlobalScaleFactor,...
    learnEmissionNoise,learnLatentTrace,saveDir,saveName,initLatentTrace);
% %he parameters over iterations are stored in allGtrain, and allGtest,
% with the last item in these cell arrays being the final learned values.
% logLikesTrain/logLikesTest give the log likelhood at each iteration.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Look at the log likelihood over training/testing iterations
%%
%%  (Note that because some parameters are shared between cases,
%%  the test is not directly comparable to the train likelihood,
%%  though it is to a large degree, since the data terms dominante
%%  the calculation).
numTrain = length(trainSetInd);
numTest = length(testSetInd);

figure,semilogy(logLikesTrain/numTrain,'k+-'); 
xlabel('Iteration'); 
ylabel('Log Likelihood Per Time Series');
if numTest>0
    title('Log Likelihood During Training/Testing');
    hold on;
    semilogy(logLikesTest/numTest,'r+-'); 
    legend('Train','Test','Location','SouthEast');
else
    title('Log Likelihood During Training');
    legend('Train','Location','SouthEast');
end
set(gca,'Color','white');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% look at the learned latent trace
figure,plot(squeeze(allGtrain{end}.z),'-+','MarkerSize',3);
set(gca,'Color','white');
title('Learned Latent Trace(s)'); 
xlabel('Latent Time'); ylabel('Signal Magnitude');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Viterbi alignments:

trainData = data(trainSetInd,:,:);
testData = data(testSetInd,:,:);
clear data;

% Get Viterbi alignments of the training data 
Gtrain=reviveG(allGtrain{end},0,0);
scaleAndTimesTrain = viterbiAlign(Gtrain,trainData);

% Alternatively, sample from the posterior 
% (requires a pass of the Forward algorithm inside this, so slow)
% if you want to sample many times, re-use 'alphas' for huge speed-up (then
% only do Forward the first time around)
if 0
    %% WARNING: this requires sample_hist.m from Tom Minka's Lightspeed toolbox
    alphas='';
    [encodedStates alphas]= sampleHMMstatesGivenAlphas(trainData,Gtrain,'',alphas);
    scaleAndTimesTrain=unwrapStates(encodedStates,Gtrain);
    clear alphas; 
end

%%%
% Get Viterbi alignments of the test data, if it exists and you want it
if ~isempty(testData)
    Gtest=reviveG(allGtest{end},0,0);
    scaleAndTimesTest = viterbiAlign(Gtest,testData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Align, interpolate and scale the training data in the ALIGNMENT space
scaleType=2; %% type 'help alignInterpolateScale' to see possible values
newData = alignInterpolateScale(trainData,scaleAndTimesTrain,Gtrain,scaleType);

%% plot it (collapsing it to a single dimension for viewing  purposes)
oneD_alignedData=squeeze(sum(newData,3))';
figure, subplot(2,1,1),
set(gca,'Color','white');
plot(oneD_alignedData,'-');
title('Aligned and Scaled Data'); xlabel('Latent Time');
%% contrast to unalinged/scaled data
subplot(2,1,2)
plot(squeeze(sum(trainData,3))','-');
set(gca,'Color','white');
title('Unaligned and Unscaled Data'); xlabel('Experimental Time');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Align, interpolate and scale the training data in the ORIGINAL space
%% (or really, in whatever space you decide to use here)
%% (need to re-load original data because we overwrote it with the reduced
%%  dimension version)
load eColi_singleClass_11perClass.mat;
trainData = data(trainSetInd,:,:);

scaleType=2; %% type 'help alignInterpolateScale' to see possible values
newData = alignInterpolateScale(trainData,scaleAndTimesTrain,Gtrain,scaleType);

%% plot it (collapsing it to a single dimension for viewing  purposes)

%% NOTE: this figure should look the same as the last one, since we have
%% collapsed it to a 1D space in both instances
if 0
  oneD_alignedData=squeeze(sum(newData,3))';
  figure, subplot(2,1,1),
  plot(oneD_alignedData,'-');
  set(gca,'Color','white');
  title('Aligned and Scaled Data'); xlabel('Latent Time');
  %% contrast to unalinged/scaled data
  subplot(2,1,2)
  plot(squeeze(sum(trainData,3))','-');
  set(gca,'Color','white');
  title('Unaligned and Unscaled Data'); xlabel('Experimental Time');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTES:

%% The figures generated in this script, when run by me, can be
%% found in ./demos/figs/ directory.
%% The figures are called EM_CPM_singleClass_demo_X.jpg, 

%% Each training iteration took just under 1 minute when I ran this with
%% 6 training time series (for all 6 of these), using the HMM scale states
%% (rather than the scaling spline), and not learning the state transition
%% probabilities.


return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% You can plug the code below into the script above if you want to
%% try using a hold out to find a good value of lambda (smoothing penalty
%% on the latent trace) to use, although frequently it turns out that no
%% smoothing is just fine.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Choose what values of lambda you want to try (probably more than this)
%% -lambda is smoothing penalty on latent trace (positive only -- higher
%% is more smooth).  Reasonable values are data set dependent.
tryLambda=[1e-18 1e-16 1e-14 1e-12];

nxt=1;
for lambda=tryLambda
                          
    %% train/test the EM-CPM: only story the test log likelihood each time
    [allGtrain allGtest logLikesTrain logLikesTest]=trainTestEMCPM(...
        data,trainSetInd,testSetInd,classesTrain,classesTest,...
        USE_SPLINE,oneScaleOnly,maxIter,numCtrlPts,extraPercent,...
        lambda,nu,myThresh, learnStateTransitions,learnGlobalScaleFactor,...
        learnEmissionNoise,learnLatentTrace,saveDir,saveName,initLatentTrace);

    holdOutLogLike(nxt)=logLikesTest(end);
    nxt=nxt+1;
end


%% Look at the log likelihood over hold out   
numHoldOut=length(testSetInd);
figure, semilogx(tryLambda,holdOutLogLike/numHoldOut,'-+');
title('Hold Out Log Likelihood');
xlabel('Lambda (smoothing parameter on latent trace)');
ylabel('Hold Out Log Likelihood Per Hold Out Case');
grid on;
set(gca,'Color','white');

%%NOTES:
%% this data set does not appear to require any smoothing of the latent trace


