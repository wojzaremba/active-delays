%function trainAlignCompare(myHa,myQmz,numBins,...
%    lambda,maxIter,SAVE_FIGURES,MAKE_FIGURES,...
%    nu,myThresh, USE_CPM2,updateT,updateScale,updateSigma...
%    updateZ,updateU,extraPercent,maxTimeSteps,classes,nxtExpName);
%
% Do one class alignment (of two classes) by training CPM2,
% then finding viterbit alignment, then use t-statistics to
% find differences.
%
% NOTE this function generates figures, and hence cannot be run
% on a 'screen'.

function trainAlignCompare(myHA,myQmz,numBins,...
    lambda,maxIter,SAVE_FIGURES,MAKE_FIGURES,...
    nu,myThresh, USE_CPM2,updateT,updateScale,updateSigma,...
    updateZ,updateU,extraPercent,maxTimeSteps,classes,nxtExpName);

HessianOn='off';
LargeScaleOn='on';
useLogZ=1;  % do optimization in logZ space rather than z (for latent trace)


%%% Could make a function from here onwards:

numSamples = length(myHA);
numClass = length(classes);

%% create a multi-D feature vector? (or basepeak)
numRealTimes = size(myQmz{1},1);
myHA = createBins('',myQmz,numBins,numRealTimes,0,myHA,0);

%% number of Control Points
numCtrlPts=ceil(numRealTimes/100*2);
tmpClasses{1}=1:numSamples;

initGTrain = getHMMParams(numSamples,numRealTimes,tmpClasses,...
    extraPercent,1,maxTimeSteps,0,'','',useLogZ,...
    HessianOn,LargeScaleOn,numBins,lambda,nu,updateScale(1),...
    updateT(1),updateSigma(1),updateU(1),updateZ(1),maxIter,...
    myThresh,'',USE_CPM2,numCtrlPts,0,0);

latentTrace = initializeAllLatentTrace(initGTrain,myHA);
initGTrain.z=latentTrace;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageDir = '/u/jenn/phd/MS/matlabCode/workspaces/general/figs/';
savedir = '/u/jenn/phd/MS/matlabCode/workspaces/general/';
savefileBase = [savedir nxtExpName '_S' ...
    num2str(lambda,2) '.' 'B' ...
    num2str(numBins) '.'  filenameStamp];
savefile = ['''' savefileBase '.mat'''];

errorLogFile = savefile(1:(end-4));
errorLogFile = [errorLogFile(2:end) 'LOG'];

cmd1 = ['save ' savefile ';'];
eval(cmd1);
display(['Will save results to: ' savefile]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% train the model
%[errorFlag,newTrace,G,allTraces,tmpLikes1,mainLikes1,lambdaTerm1,...
%    nuTerm1,timePrior1,scalePrior1,gammas1,elapsed,itG]=...
[errorFlag,newTrace,G,allTraces,tmpLikes1,mainLikes1,lambdaTerm1,...
    nuTerm1,timePrior1,scalePrior1,gammas1,elapsed,itG]=...
    trainFBHMM(initGTrain,myHA,errorLogFile,'',0,USE_CPM2);

%% get MAP alignments
stTrain = viterbiAlign(G,myHA);
clear initGTrain gammas1 itG;
eval(cmd1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% align the data
%% 2D alignmetns
scaleType=0;
global dat;
dat = alignMS(myQmz,stTrain,G,scaleType);

%% truncate time so that every trace has non-zero measurements
%% at each remaning time
[dat newBounds] = truncateNAN(dat);

%% now get measure of 2D alignment
% ccc = ['load ' randFileName ];  eval(ccc);
% clear myQmz; clear datB; G=stripG(G); pack()
if 0
    numRemove = [0 0];
    [varScore dotScore] = ...
        scoreMS(dat,numRemove,classes);
    sprintf('%e %e %e %e\n', G.lambda, varScore(1),...
        varScore(2), sum(varScore))
end

G=stripG(G);

if 0
    clear myQmz;
    eval(cmd1);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
if MAKE_FIGURES
    %% take a look at some alignments
    numBinsOld=G.numBins;
    G.numBins=1;
    %% collapse z to take a look
    oldZ = G.z;
    newZ = collapseZ(oldZ); %% in case have more than 1 bin
    G.z = newZ;
    oneDHA = collapseHA(myHA);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot some results from the alignment
    %% aligned traces together
    extraStr = nxtExpName;

    oneD=1;
    samplesMat = getSamplesMat(oneDHA,G,oneD);
    %% get rid of bin dimension
    samplesMat = permute(samplesMat,[2 3 1]);
    %[H,allAxes]=getAxes(2);
    scaleType=0;
    displayMultiAlignment(G,allAxes,stTrain,samplesMat,1,scaleType);
    if SAVE_FIGURES
        savefigures(gcf,1,['alignTog' extraStr],'all',imageDir);
        closefigures
    end

    %% look at the full multi-D latent trace
    figure,plotLatentTrace(oldZ);
    if SAVE_FIGURES
        savefigures(1:gcf,1:gcf,['multiDlatTrace' extraStr],'all',imageDir);
        closefigures
    end

    %% individual aligned traces
    DETAILS=1;
    %% clear; load fig.mat;
    displayAllAlignments(G,stTrain,oneDHA,DETAILS);
    if SAVE_FIGURES
        savefigures(1:gcf,1:gcf,['indivAlign' extraStr],'all',imageDir);
        closefigures;
    end

    clear samplesMat myHA; pack();
    G.numBins=numBinsOld;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save and then clear myQmz, stTrain to free up memory
%randFileNameT = [generateRandomFileName()];
%randDir = '/w/24/jenn/phd/workspaces/temp/';
%randFileName = [randDir randFileNameT '.mat'];
bigFileName = [savefileBase '.BIG.mat'];
cmdQ = ['save ' bigFileName ' myQmz allTraces G'];
eval(cmdQ);
clear myQmz allTraces G;

%% strip down G to save memory
%G=stripG(G);

pack();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% use t-test, etc. to find differences


%% blur the data

%% for debuggin, etc. save workspace here
%save currentWorkspace.mat;

%[timeBlur,mzBlur] = findGoodBlur(ind1,ind2);%% needs global dat defined

if 0
    timeBlur=25; mzBlur=0;
    [blurMat timeVec mzVec] = getBlurMat(timeBlur,mzBlur,0);
    %mzBlur=[1/3 1/3 1/3];

    %% we are blurring inside of the WelchT now!
    global datB;
    datB = blurQmz(dat,timeVec,mzVec);

    cmdD = ['save ' bigFileName ' dat -append'];
    eval(cmdD);
    clear global dat; pack();

    % normalize each experiment to 1
    for jj=1:size(datB,3)
        normFac(jj) = sum(sum(datB(:,:,jj)));
        datB(:,:,jj) = datB(:,:,jj)/normFac(jj);
    end
    %figure,plot(normFac);

    %%%%% t-test stuff
    corrType = 'welchT';
    minStd=0;
    minDiff=0;%1e-7;
    minRelDiff=0.01;

    timeBlur2 = 0%;10;
    mzBlur2 = 0%;3;

    [stat m1 m2] = getClassCorr('datB(:,:,i1)', 'datB(:,:,i2)',...
        classes{1},classes{2},corrType,1,timeBlur2,mzBlur2,minStd,...
        minDiff,minRelDiff);

    %% plot with sliders
    if 0
        testThresh=0;
        displayClassCorr('datB(:,:,i1)', 'datB(:,:,i2)',...
            classes{1},classes{2},corrType,1,timeBlur2,mzBlur2,minStd,...
            minDiff,minRelDiff,testThresh);
    end

    if 0%exist('v1','var')
        percentile=85;
        plotMeansVariances(m1,m2,v1,v2,percentile);
    end

    DO_PERM=0;
    if DO_PERM
        %% again, with some permutations:
        numPerm = 100;%2500%1e3;
        flipSigns=0; exact=1;
        %[ind1R ind2R] = makeRandomPermSplits(classes,numPerm,flipSigns,exact);
        [ind1R ind2R] = makeRandomPermSplits2(classes,numPerm);
        numPermActual = length(ind1R)

        %keepTopFrac = 0.05;  %% keep this fraction from top and bottom
        %allStatR = [];
        pCounts = zeros(size(stat));

        %% count how many permutations have a higher test statistic
        %% than the real thing (higher or equal)
        for jj=1:numPermActual
            disp(['Permutation ' num2str(jj)]);
            tic;
            statR = getClassCorr('datB(:,:,i1)',...
                'datB(:,:,i2)',ind1R{jj},ind2R{jj},corrType,1,...
                timeBlur2,mzBlur2,minStd,minDiff,minRelDiff);
            toc;
            if 0
                %% only keep the top and bottom X%, because don't have
                %% enough memory otherwise, but first we need to blur
                statRvec = statR(:);
                numToKeep = floor(keepTopFrac*length(statRvec)/2);
                sortVals = sort(statRvec);
                if keepTopFrac~=1
                    allStatR = [allStatR; sortVals(1:numToKeep)];
                    allStatR = [allStatR; sortVals((end-numToKeep+1):end)];
                else
                    allStatR = [allStatR; sortVals];
                end
            else
                %% see which ones are at least as big as the real test
                %% statistic
                newCounts = abs(statR)>=abs(stat);
                pCounts = pCounts + newCounts;
            end
        end

        if BLUR_p
            timeBlurP = 10;
            mzBlurP = 3;
            [blurMat timeVecP mzVecP] = getBlurMat(timeBlurP,mzBlurP,0);
            %mzBlur=[1/3 1/3 1/3];
            pCountsB = blurQmz({pCounts},timeVecP,mzVecP);

            length(unique(pCounts))
            length(unique(pCountsB))
            figure,hist(pCountsB(:),1:100);
            thresh=1;
            length(find(pCountsB<thresh))/prod(size(pCountsB))*100
            figure,show(pCountsB<thresh);
        end

        %figure,hist(pCounts(:),1:numPerm);
        %length(find(~pCounts))/prod(size(pCounts))*100
        %figure,show(pCounts==0);

        if 0
            MAKE_FIGURES=1;
            randThresh = plotWelchT(stat,allStatR,keepTopFrac,MAKE_FIGURES);
            closefigures();
        end

        %% matrix coordinates of the peaks
        [peakMap peakMapIntens peakCoord...
            peakMax peakSum peakMean peakMz]=findPeaks(stat,randThresh*8/10);

        useP=1;
        [peakMap peakMapIntens peakCoord...
            peakMax peakSum peakMean peakMz peakMin]=findPeaks(pCountsB,thresh,useP);

        if 0
            whos peakCoord
            figure, show(~(peakMapIntens)); colorbar;
            fixMZaxis(gca);
        end
        %figure, show(-peakMapIntens); colorbar;
        if ~isempty(peakMz)
            pkStr=num2str(sort(unique(peakMz)),4)
        end

        %savefigures(1:gcf,1:gcf,'welchT','all');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% make a density estimate of these values:

if 0
    %% save stats that we need in a file
    denseFile = [randDir bigFileNameT 'density.mat'];
    cmdH = ['save ' denseFile ' allStatR stat'];
    eval(cmdH);

    %% save everything else that we need

    %% erase everything

    %% load what we need

    %% compute
    [realDens binCenters] = ksdensity(stat(:));
    ft = cputime;
    [randDens] = ksdensity(allStatR,binCenters);
    lt = cputime;
    el = (lt-ft)/60;
    disp(['Elapsed time=' num2str(el) '  minutes']);

    %% now calculate the KL divergence
    KLdist = kl(randDens,realDens);

    figure,
    tmpName = extraStr; tmpName(find(tmpName=='_'))='-';
    plot(binCenters,realDens,'r^-');
    title(['Test statistic density estimate, KL=' ...
        num2str(KLdist,3), ' (' tmpName ')']);
    hold on;
    plot(binCenters,randDens,'k+-');
    leg1 = 'Real';
    leg2 = ['Random (' num2str(numPermActual) 'perm.)'];
    legend(leg1,leg2);
    grid on;
    xlabel('Value of test statistic');
    ylabel('Estimated density');
    %% show histogram approximation of the density
    figure,hist(randDens,binCenters);

    if SAVE_FIGURES
        savefigures(1:gcf,1:gcf,'densities','all');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    randThresh = plotWelchT(stat,allStatR,keepTopFrac,MAKE_FIGURES);
    if SAVE_FIGURES
        savefigures(1:gcf,1:gcf,[corrType extraStr],'all',imageDir);
        closefigures(1:gcf);
    end
end

if 0
    %% save here because sometimes the 2D images get messed up
    clear v1 v2 m1 m2 gammas1
    clear global datB;
    %% save before deleting what we don't need right now
    %eval(cmd1);
    clear stat allStatR ;
    pack();
end

if 1
    %clear datB; pack();
    cmdQ = ['load ' bigFileName ];
    eval(cmdQ);
    clear global dat;

    %% look for interesting window
    %figure,showMS(myQmz(1),0,'','',0,2,400,G.timeRatio);
    timeRg = [100 450];
    mzRg =[650 1400];
    showConsecTwoD(mzRg,timeRg,stTrain,myQmz,G,SAVE_FIGURES,extraStr,imageDir);
    closefigures;
end

%% save!!!!!
%% no, don't save again, because we have 'cleared' most everything above
%clear myQmz
%eval(cmd1);

%% CREATE A MARKER FILE WHICH SHOWS THE COMPUTATION IS DONE
savefileFINISHED = savefile(1:(end-4));
savefileFINISHED = [savefileFINISHED 'FINISHED'];
cmd3 = ['save ' savefileFINISHED ''' savefileFINISHED ;'];
eval(cmd3);
display('FINISHED');
