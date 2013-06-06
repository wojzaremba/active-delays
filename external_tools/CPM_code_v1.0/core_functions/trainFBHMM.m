%function [logLikes,allG,didConvergeL,errorFlag]=...
%    trainFBHMM(G,samplesMat,errorLogFile,saveFile,HOLD_OUT,USE_CPM2)
%
% Use EM/forward-backward algorithm to train HMM model using
% initTrace 
%
% if HOLD_OUT==1, then sigmas are not constrained by each others
% values (as is the case for training)
%
% 'logLikes' contains the log likelihood over training iterations
% 'allG' contains the learned parameters at every iterations in
%        a cell array (plus a bit of other junk)
% 'didConvergeL' specifies whether the convergen threshold was met
%                (not a big deal if it isn't, since this is a bit
%                 arbitrary).
%
% if 'errorFlag' =1, then there was a problem of some sort (possibly
% related to using too many 'numBins', or not enough 'lambda')

function [logLikes,allG,didConvergeL,errorFlag]=...
    trainFBHMM(G,samplesMat,errorLogFile,saveFile,HOLD_OUT,USE_CPM2)

if G.numBins>24
     warnStr=sprintf(...
         ['****************************************************************\n'...
         'You have chosen to use more than 24 features for each time point.'...
         '\n\nDimensionality of each time point increases the CPU time \n'...
         'roughly linearly, and one often need not use the full\n'...
         'dimensionality to get good results.  Furthermore, in my\n'...
         'useage so far, I have had numerical problems for more than\n'...
         '24 dimensions (numBins), but this is problem-specific.'...
         '\n\nChange this to a warning if you want to try more.\n'...
         '****************************************************************'...
         ]);
     error(warnStr);
end

if exist('saveFile') & ~isempty(saveFile)    
    % save work after each iteration
    saveWork=1;
    %savevars = 'elapsed allG smoothLikes mainLikes likes numIt initTrace';
    %saveCmd = ['save ' saveFile ' ' savevars];
    saveCmd = ['save ' saveFile];
    saveFreq=50;
else
    saveWork=0;
end

errorFlag=0;
lambda=G.lambda; nu=G.nu; 
initTrace=G.z;
samplesMat=permute(samplesMat,[3,2,1]);
%samplesMat = reshape(cell2mat(samples),[G.numBins G.numRealTimes G.numSamples]);
%clear samples;

if any(samplesMat(:))<0
    error('CPM code does not handle negative values, please shift values upward and start again.');
end

currentTrace=initTrace;
allTraces='';
gammas='';
alphas='';
rhos='';
smoothLikes='';
mainLikes='';
mytolx = '';

% if isempty(errorLogFile)
%     errorLogFile=['/u/jenn/phd/MS/matlabCode/workspaces/trainFBHMM_' filenameStamp '.LOG'];
% end

if ~isfield(G,'class')
    error('G does not have the class variable in it');
end

errorFound=0;

%% file to log errors and messages
if ~isempty(errorLogFile)
    cmd=['[fidErr,message]=fopen(errorLogFile,' '''a''' ');']
    eval(cmd);
    if (fidErr==-1)
        error(['Unable to open file: ' errorLogFile]);
    end
else
    fidErr=0;
end

if ~isfield(G,'sigmas')    
    %disp('calling getInitSigmas');
    [G.sigmas,G.varsigma,G.minSigma] = ...
        getInitSigmas(G,samplesMat);
end
%figure,show(G.sigmas); colorbar; keyboard;

printRunInfo(G,fidErr);

%minSigmaUpdateIt=G.minSigmaUpdateIt;

elapsed = zeros(1,G.maxIter);
likes = zeros(1,G.maxIter);
smoothLikes=zeros(G.maxIter,G.numClass);
nuTerm=zeros(1,G.maxIter);
timePriorTerm=zeros(G.maxIter,G.numSamples);
scalePriorTerm=zeros(1,G.maxIter);
mainLikes=zeros(G.maxIter,G.numSamples);
oldLike=-Inf;
numIt=0; keepGoing=1;

M=G.numTaus;
C = G.numClass;

allTraces = zeros(G.maxIter, G.numTaus,G.numClass,G.numBins);
%% scale vealue in real space corresponding to each state
scalesExp=(2.^G.scales((G.stateToScaleTau(:,1))));
scalesExp=scalesExp(:)';
scalesExp2=(2.^G.scales((G.stateToScaleTau(:,1))));
scalesExp2=scalesExp2(:)';

oldU = G.u;

%uCoeff = zeros(G.maxIter,G.numSamples,4);
%myfval = zeros(G.maxIter,G.numSamples);

%% precompute valid states for each time step (for updating Z)
%% this never changes
[allValidStates,scaleFacs,scaleFacsSq] = getValidStates(G);
G.Jsparse = getJacobPattern(G);

%keepGoing=(numIt<G.maxIter);
keepGoing=1;

if any(G.sigmas(:)==0)
    warning('some sigmas=0');
    keyboard;
end

while keepGoing
    %tic;
    firstTime = cputime;
    if ~(exist('lastTime','var'))
        lastTime=firstTime;
    end
    numIt = numIt+1;
    
    if (mod(numIt,1)==0)
        tmpStr=['\nIteration: ' num2str(numIt)];
        myPrint(fidErr,tmpStr);
    end

    %% this is to keep track of old parameter values so that
    %% we can check convergence based on changing parameters
    oldG.sigmas = G.sigmas;
    oldG.D = G.D;
    oldG.S = G.S;
    oldG.u = G.u;
    oldG.z = currentTrace;
    G.z=currentTrace;

    ubar2 = getUbar2(G,G.u);

    %% (RE-)INITIALIZE M-Step stuff
    if G.updateZ || G.updateU
        gammaSum1= cell(G.numSamples,M);
        gammaSum2= cell(G.numBins,G.numSamples,M);
        gammaSum5= sparse(G.numSamples,G.numStates);
        %gammaSum6= sparse(G.numSamples,G.numStates);
        gammaSum6 = cell(1,G.numBins);
        for bb=1:G.numBins
            gammaSum6{bb}=sparse(G.numSamples,G.numStates);
        end
    end

    %% For updateSigma
    newSigmas=zeros(size(G.sigmas));

    %% For updateT
    newD = zeros(G.numSamples,G.maxTimeSteps);

    %% For updateScale
    newScaleCounts = zeros(2,C);

    %% For updateU    
    gammaSum3 = zeros(G.numBins,G.numSamples,G.numStates);
    gammaSum4 = zeros(G.numBins,G.numSamples,G.numStates);
    
    %% precompute this
    %tempSigs = G.sigmas.^(-2);

    %% The penalty terms of the likelihood should be computed
    %% before we update the parameters.  Then, after iterating
    %% through all of the samples and doing forward-backward,
    %% we will have the 'normal' part of the likelihood to add to
    %% these term.

    smoothLikes(numIt,:) = getSmoothLike(G,G.z,G.u);
    [timePriorTerm(numIt,:), scalePriorTerm(numIt)] = ...
        getDirichletLike(G);

    nuTerm(numIt) = getNuTerm(G);
    scaleCenterPriorTerm = getScaleLike(G,G.u);

    %tmp = ['nuTerm=' num2str(nuTerm(numIt),3)];
    %tmp = [tmp '   ' 'lambdaTerm=' num2str(sum(smoothLikes(numIt,:)),3)];
    %disp(tmp);


    %% Now iterate through the samples, calculating the posterior
    %% over hidden states and using these posteriors
    %% in whatever computations we need, before throwing them out
    %% to do the next sample.
    %allGammas= cell(1,G.numSamples);% each G.numStates x G.numRealTimes
    for kk=1:G.numSamples
        %% E-step (obtaining gammas), using forward-backward in
        %% standard way, with scaling tricks (not in log space)
        myClass = getClass(G,kk);
        clear alphas betas gammas rhos;
        doback=1;  %% do backward pass        
        tmpZ = permute(G.z(:,myClass,:),[1 3 2]);
        
        [mainLikes(numIt,kk),alphas,betas,rhos,FBerrorFlag]=...
            FB(G,samplesMat(:,:,kk),kk,tmpZ,doback);

        lastTimeLast = lastTime;
        lastTime=cputime;
        totalElapsed(numIt)=(lastTime-firstTime)/60;
        elapsed(numIt)=(lastTime-lastTimeLast)/60;
       
        msg=sprintf(['   Time series %d) E-step CPU Time: %.2f minutes'],...
            kk,elapsed(numIt));
        myPrint(fidErr,msg);
       
        if FBerrorFlag==1
            myStr=sprintf('ERROR: FBerrorFlag==1, means some rho==0, probably due to fixed, small sigma during cross validation on the hold out set calculations')
            if fidErr fprintf(fidErr,'%s\n',myStr); end;
            keyboard;
            %return;
        end

        gammas = alphas.*betas;
        %max(abs(sum(full(gammas),1)-1))
        %allGammas{kk}=gammas;

        %if (any(gammas(:)==0))
        %  disp('some gammas=0');
        %  [length(find(gammas(:)==0)) prod(size(gammas))]
        %keyboard;
        %end

        %maxDiff(kk,numIt)=max(abs(sum(full(gammas),1)-1));
        if max(abs(sum(full(gammas),1)-1))>1e-4%100*eps)
            disp('trainFBHMM: gammas not exactly equal to 1');
            disp('probably lambda is too small');
            %maxDiff(kk,numIt)
            errorFlag=1;
            save gammaBug.mat
            max(abs(sum(full(gammas),1)-1))
            length(find(isinf(gammas)))
            length(find(isinf(alphas)))
            length(find(isinf(betas)))            
            %return;
            keyboard;
        end

        %% now use alphas, betas, gammas and rhos for this sample
        %%and then throw them out to keep memory usage manageable.

        %%Also, be careful to do updates in the right order.
        %%update rules that are co-dependent need to be done in
        %%order, with later ones using the latest updates.
        %
        %%Current order is:
        %%sigma, z, u  (the others don't matter - they are independent)

        if G.updateSigma | G.updateZ | G.updateU
            clear tmpDat repdata;
            repdata = repmat(samplesMat(:,:,kk)',[1 1 G.numStates]);
        end

        %% update sigma right here using gammas, since we use the
        %% current value of u_k and z, this needs to be done before updating
        %% u_k's, and z
        if G.updateSigma 
            %% iterate over bins because repmat doesn't work with
            %%sparse matrixes
            %newSigmas = G.sigmas;
            for bb=1:G.numBins               
                if ~G.USE_CPM2
                    augmentZ = G.u(kk)*G.z(G.stateToScaleTau(:,2),myClass,bb)';
                else                   
                    uMat = G.uMat(kk,:);
                    augmentZ = uMat.*G.z(G.stateToScaleTau(:,2),myClass,bb)';
                end
                augmentZ = augmentZ.*scalesExp;
                augmentZ = repmat(augmentZ,[G.numRealTimes 1])';                
                tmpDat = permute(repdata(:,bb,:),[3 1 2]);                
                newSigmas(bb,kk) = sum(sum(full(gammas).*((tmpDat-augmentZ).^2)));              
            end            
            
            if isnan(newSigmas(kk))
                error(['ERROR: newSigmas(' num2str(kk) ')' '=nan']);
                numIt=numIt+1;% bit of a hack to keep results even if
                %keepGoing=0;
                keyboard;
            end
        end

        %% gather data we will need to update z
        if G.updateZ || G.updateU
            %% iterate over bins because repmat doesn't work with
            %%sparse matrixes, and sparse matrixes can't be multiDim            
            gammaSum5(kk,:) = sum(gammas,2)'; % same for each bb
            for bb=1:G.numBins
                tmpGS6 = gammaSum6{bb};
                tmpDat = permute(repdata(:,bb,:),[3 1 2]);                
                tmpGS6(kk,:) = sum(full(gammas).*tmpDat,2)';
                gammaSum6{bb}=tmpGS6;
            end
            for jj=1:M               
                validStates=allValidStates{jj};
                numVal=length(validStates);

                %%%% X(j,j)
                gammaSum1{kk,jj}=gammaSum5(kk,validStates)';

                %%%% b
                for bb=1:G.numBins
                    tmpGS6 = gammaSum6{bb};
                    gammaSum2{bb,kk,jj}=tmpGS6(kk,validStates)';
                end
            end
        end
        
        if G.updateTime
            newD(kk,:) = updateTimeConst(G,alphas,betas,rhos,samplesMat(:,:,kk),tmpZ,kk);            
        end

        if G.updateScale
            newScaleCounts(:,myClass) = newScaleCounts(:,myClass) + updateScaleConst(G,alphas,betas,rhos,samplesMat(:,:,kk),tmpZ,kk)';
        end
        
        if G.updateU
            % size(gammas)= numStates x numRealTimes

            for dd=1:G.numBins
                tmpDat = permute(repdata(:,dd,:),[3 1 2]);                                                
                gammaSum3(dd,kk,:)=sum(full(gammas).*tmpDat,2)';
                %% this one could just be independent of the bin...
                gammaSum4(dd,kk,:)=sum(full(gammas),2)';
            end

        end
        
    end %%END ITERATING OVER INDIVIDUAL SAMPLES, kk
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    msg=sprintf('Iteration %d E-step CPU time for all time series %.2f min.',...
        numIt,totalElapsed(numIt));
    myPrint(fidErr,msg);
    
    if G.updateSigma% & (numIt>minSigmaUpdateIt))              
        
        %% NO, NO, this can really mess things up!!!
        if 0
            %% force the sigmas to be the same across all bins:
            %% (they aren't because z changes from bin to bin
            newSigmas = mean(newSigmas,1);
            newSigmas = repmat(newSigmas, [G.numBins 1]);
        end
        
        %% force sigmas to be shared in each class
        if 1%G.SHARE
            for cc=1:C                
                newVals = mean(newSigmas(1:G.numBins,G.class{cc})');
                newValsRep = repmat(newVals,[G.numPerClass(cc) 1])';
                newSigmas(:,G.class{cc}) = newValsRep;
            end
            newSigmas = sqrt(newSigmas/G.numRealTimes);
        elseif ~HOLD_OUT %% enforce factor by which they must agree
            %% but if it is hold out, then don't need to enforce
            newSigmas = sqrt(newSigmas/G.numRealTimes);
            
            %newSigmas2=newSigmas;
            for b=1:G.numBins
               newSigmas2(b,:) = constrainSigmasIterate(...
                   G,newSigmas(b,:),G.sigmas(b,:));
            end
            
            %newSigmas-newSigmas2
            %keyboard;
            
            newSigmas = newSigmas2;           
        elseif HOLD_OUT
            %% don't enforce the constraint between sigmas, just use
            %% their raw updates
            newSigmas = sqrt(newSigmas/G.numRealTimes);
        else
            error('case doesnt exist');
        end

        %temp=[G.sigmas' newSigmas' (G.sigmas'-newSigmas')];

        temp=[newSigmas];
        % disp the new sigmas
        %disp('Sigmas Updates');
        %num2str(newSigmas',5)
        
        formatStr = getFormatStr(G.numSamples,2);
        myStr=sprintf(formatStr,newSigmas');
        if fidErr fprintf(fidErr,'Sigma Updates\n%s\n',myStr); end

        %oldSigmas = G.sigmas;   
        G.sigmas = newSigmas;
        %tempSigs = G.sigmas.^(-2);
        %figure,show(oldSigmas-G.sigmas);
        %imstats(oldSigmas-G.sigmas);
        %keyboard;
    end

    if G.updateZ
        for bb=1:G.numBins
            sqGamSum2 = permute(gammaSum2(bb,:,:),[2 3 1]);            
            
            [currentTrace(:,:,bb),output,options,changeFlag] = ...
                getNewZ(G,samplesMat,allValidStates,...
                scaleFacs,scaleFacsSq,gammaSum1,...
                sqGamSum2,gammaSum5,...
                gammaSum6{bb},scalesExp,scalesExp2,bb);
                
            if numIt==1
                myStr=printStruct(options);
                if fidErr fprintf(fidErr,'%s\n',myStr); end
            end

            myStr=printStruct(output);
            if fidErr fprintf(fidErr,'%s\n',myStr); end
        end

        G.z=currentTrace;
        allTraces(numIt,:,:,:)=G.z;
        if ~changeFlag
            myStr=sprintf('newZ same as oldZ');
            if fidErr fprintf(fidErr,'%s\n',myStr); end
        end
    end %%end G.updateZ

    if G.updateU        
        newU= getNewU(G,gammaSum3,gammaSum4,gammaSum5,...
            gammaSum6,scalesExp);
        G.u=newU;

        if G.USE_CPM2
            %oldUmat = G.uMat;
            G.uMat = getUMat(G,G.u);
            %figure,show(G.uMat-oldUmat); colorbar;
        end
        
        %myStr=sprintf('myfval:%.4f\n',myfval(numIt,:));
        %fprintf(fidErr,'%s\n',myStr);

        %myStr=sprintf('u: %.4f\n',G.u');
        %myPrint(fidErr,myStr);        
    end
    oldU=G.u;
    

    if G.updateTime
        if G.SHARE_TRANS
            tmpD = mean(newD,1);
            newD = repmat(tmpD,[G.numSamples 1]);
        end

        myStr=sprintf('TimeTrans prob')
        tmpStr = '';
        for jj=1:G.maxTimeSteps
            tmpStr = [tmpStr '%.4f '];
        end
        tmpStr = [tmpStr '\n'];
        myStr=sprintf(tmpStr,newD');
        if fidErr fprintf(fidErr,'TimeTrans prob\n %s\n',myStr); end
    end

    if G.updateScale
        newS = getNewS(G,newScaleCounts);
        myStr=sprintf('ScaleTrans prob: %.4f\n',newS)
        myStr=[myStr sprintf('\n')];
        if fidErr fprintf(fidErr,'%s\n',myStr); end
    end

    %% propagate the state transition updates to our data
    %% structure, G
    if G.updateTime
        if G.updateScale
            G = reviseG(G,newS,newD);
        else
            G = reviseG(G,G.S,newD);
        end
    elseif G.updateScale
        G = reviseG(G,newS,G.D);
    end

    %% these were computed at top of loop, before FB algorithm,
    %% since the state posteriors and hence mainLikes come from
    %% previous model, not updates just performed.

    newLike = sum(mainLikes(numIt,:));
    newLike = newLike + scalePriorTerm(numIt) + ...
        sum(timePriorTerm(numIt,:));
    newLike = newLike + nuTerm(numIt) + ...
        sum(smoothLikes(numIt,:)) + scaleCenterPriorTerm;

    %% This newLike is the likelihood
    likes(numIt) = newLike;

    %% check if parameters have converged
    didConvergeP = checkConverge(oldG,G);
    %didConvergeL = (newLike-oldLike)/abs(newLike) < G.thresh;
    didConvergeL = (newLike-oldLike) < G.thresh;
%     G.badThresh=1e-8;
%     if 1%~(HOLD_OUT && numIt==2)
%         %badLikelihood = (oldLike-newLike)>1e-12;%eps;
%         badLikelihood = (oldLike-newLike)>G.badThresh;%1e-8;%1e-12;%eps;
%     else
%         badLikelihood=0;
%     end
    %%% if you want to check for parameter convergence:
    %didConverge = didConvergeP;% & didConvergeL;
    %%% if you want to check for parameter and likelihood convergence:
    %didConverge = didConvergeP && didConvergeL;
    %%% if you want to check for just likelihood convergence:
    didConverge = didConvergeL;
    
    msg=sprintf(  'log likelihood for all data:      %.8e',likes(numIt));
    myPrint(fidErr,msg);

    if numIt>1
        msg=sprintf('  (difference from last iteration: %.8e)',diff(likes((numIt-1):numIt)));
        myPrint(fidErr,msg);
    end

    if 0%badLikelihood 
        msg1 = 'LIKELIHOOD went down more than threshold!'
        msg2 = ['Change: ' num2str((oldLike-newLike),2)];
        diffLike = sprintf('%.2e',(oldLike-newLike));
        msg2 = [msg2 '  Difference in likelihood: ' diffLike]
        errorFound=1;
        disp('Likelihood went down... waiting');
        figure,semilogy(likes(1:numIt))
        keyboard;
    elseif didConverge
        keepGoing=0;
        msg1 = 'CONVERGED Likelihood';
        if (didConvergeP)
            msg1 = [msg1 ' P'];
        end
        if (didConvergeL)
            msg1 = [msg1 ' L'];
        end
        disp(msg1);
        msg2=['Change: ' num2str((newLike-oldLike),2)]
        errorFound=1; %bit of a misnomer...
    end

    if errorFound
        if fidErr fprintf(fidErr,'WARNING: %s  %s\n\n',msg1,msg2); end
        errorFound=0;
    end

    if numIt==G.maxIter & ~errorFound
        msg1=['Did not converge, max num iterations reached: ' num2str(G.maxIter)];
        myPrint(fidErr,msg1);
        if G.maxIter>1
            msg2=['Last change in likelihood=', num2str((newLike-oldLike),2)];    
            disp(msg2);
        else
            msg2='';
        end
        keepGoing=0;
        errorFound=1;
    end

    if errorFound
        if fidErr fprintf(fidErr,'WARNING: %s  %s\n\n',msg1,msg2); end
        errorFound=0;
    end

    %% stripG gets rid of huge redundant parts of the data structure
    %% which can easily be regenerated from the remaining bits
    allG{numIt}=stripG(G,1);

    oldLike=newLike;
    lastTime=cputime;
    elapsed(numIt)=(lastTime-firstTime)/60;
    sprintf('Iteration %.2f full EM step, CPU time: %.2f minutes\n',numIt,elapsed(numIt));
    if fidErr fprintf(fidErr,'Iteration %.2f CPU Time: %.2f minutes\n',numIt,elapsed(numIt)); end

    if saveWork && mod(numIt,saveFreq)==0        
        eval(saveCmd);
    end
end

%% Some computation of the log likelihood is at the beginning of the
%% loop, so we need to do it once more here to get the final value.
lastLogLike = EMCPM_logLike(G,samplesMat)
likes(numIt+1)=lastLogLike;
       

msg1 = ['FINAL EM Iteration: ' num2str(numIt), ...
    ',  log likelihood=' printSci(likes(numIt),6) ' TOTAL CPU TIME=' num2str(sum(elapsed))];

myPrint(fidErr,msg1);

elapsed = elapsed(1:numIt);
logLikes = likes(1:(numIt+1));
smoothLikes=smoothLikes(1:numIt,:);
scalePriorTerm=scalePriorTerm(1:numIt);
timePriorTerm=timePriorTerm(1:numIt,:);
nuTerm = nuTerm(1:numIt);
mainLikes=mainLikes(1:numIt,:);
allTraces = allTraces(1:numIt,:,:);

if fidErr fclose(fidErr); end

return;






