% function [f d] = objective(input,G,samples)
%
% This function computes the function log p(x) for our CPM model, and
% also the derivative of this function.
%
% G contains all of the parameters in the CPM
%
% samples should be a matrix, not a cell array

function [f, d] = objective(input,G,samplesMat,allValidStates,scaleFacs,scaleFacsSq,scalesExp,scalesExp2);

global FUNCTION_COUNTS; 
if (nargout==1)
  FUNCTION_COUNTS(1) = FUNCTION_COUNTS(1) +1;
elseif (nargout==2)
  FUNCTION_COUNTS(2) = FUNCTION_COUNTS(2) +1;
else
  nargout
  error('nargout=?');
end
%FUNCTION_COUNTS

%if (any(input<0))
%  warning('Some input<0'); keyboard;
%end

verbose=0;
if (verbose)
  display(['objective.m, nargout=' num2str(nargout)]);
  tic;
end

%warning('Calling objective.m'); keyboard;

%% NEED TO UPDATE G TO REFLECT input values of parameters
G=reviseAllG(G,input);
M = G.numTaus;
C = G.numClass;

if (any(isinf(G.z)))
  f=realmax;
  d=realmax*zeros(size(input));
  return;
end

ubar2 = getUbar2(G);

%% Set up derivatives.  We will accumulate over each sample, so
%% that we don't have to store the gammas.
derivZ = zeros(size(G.z));
derivU = zeros(size(G.u));
derivSigma = zeros(G.numClass,1);

if (G.updateZ)
  gammaSum1= cell(G.numSamples,M);
  gammaSum2= cell(G.numBins,G.numSamples,M);
  gammaSum5= sparse(G.numSamples,G.numStates);
  gammaSum6 = cell(1,G.numBins);
  for bb=1:G.numBins
    gammaSum6{bb}=sparse(G.numSamples,G.numStates);
  end
end

%% For updateScale
newScaleCounts = zeros(2,C);

%% For updateU
gammaSum3 = zeros(G.numBins,G.numSamples,G.numStates);
gammaSum4 = zeros(G.numBins,G.numSamples,G.numStates);

%% precompute this
tempSigs = G.sigmas.^(-2);

smoothLikes= getSmoothLike(G);
[timePriorTerm, scalePriorTerm] = getDirichletLike(G);

nuTerm = getNuTerm(G);  
scaleCenterPriorTerm = getScaleLike(G);

%tmp = ['nuTerm=' num2str(nuTerm(numIt),3)];
%tmp = [tmp '   ' 'lambdaTerm=' num2str(sum(smoothLikes(numIt,:)),3)];
%display(tmp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over samples, doing FB to get posterios, and accumulating 
%% the derivative information:
for kk=1:G.numSamples
  myClass = getClass(G,kk);
  clear alphas betas gammas rhos;
  [mainLikes(kk),alphas,betas,rhos,FBerrorFlag]=FB(G,samplesMat(:,:,kk),kk,squeeze(G.z(:,myClass,:)));
  
  if (FBerrorFlag==1)
    myStr=sprintf('ERROR: FBerrorFlag==1, means some rho==0, probably due to fixed, small sigma during cross validation on the hold out set calculations')
    sprintf('%s\n',myStr);
    keyboard;
    return;
  end
  
  gammas = alphas.*betas;
  %allGammas{kk}=gammas;
  
  maxDiff(kk)=max(abs(sum(full(gammas),1)-1));
  if (max(abs(sum(full(gammas),1)-1))>1e-11)
    warning('objective: gammas not exactly equal to 1');
    display('probably lambda is too small');
    errorFlag=1;
    keyboard;
    return;
  end

  if (nargout==2)
  
    if (G.updateSigma | G.updateZ | G.updateU)
      repdata = repmat(samplesMat(:,:,kk)',[1 1 G.numStates]);
    end
  
    %% update sigma right here using gammas
    if (G.updateSigma) 
      %% iterate over bins because repmat doesn't work with
      %%sparse matrixes
      %newSigmas = G.sigmas;
      for bb=1:G.numBins
	augmentZ = G.u(kk)*G.z(G.stateToScaleTau(:,2),myClass,bb)'; 
	augmentZ = augmentZ.*scalesExp;
	augmentZ = repmat(augmentZ,[G.numRealTimes 1])';
	tmpDat = squeeze(repdata(:,bb,:))';
	sigmaDeriv(bb,kk) = sum(sum(gammas.*((tmpDat-augmentZ).^2)))/G.sigmas(kk).^3 - G.numRealTimes/G.sigmas(kk);
      end
    end
      
    %% gather data we will need to update z
    if (G.updateZ)
      %% iterate over bins because repmat doesn't work with
      %%sparse matrixes, and sparse matrixes can't be multiDim
      gammaSum5(kk,:) = sum(gammas,2)'; % same over all bb
      for bb=1:G.numBins
	tmpGS6 = gammaSum6{bb};
	tmpGS6(kk,:) = sum(gammas.*squeeze(repdata(:,bb,:))',2)';
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
    end %% end G.updateZ
    
    tmpTrace = squeeze(G.z(:,myClass,:));
    
    if (G.updateTime)
      newD(kk,:) = updateTimeConst(G,alphas,betas,rhos,samplesMat(:,:,kk),tmpTrace,kk);
    end
    
    if (G.updateScale)
      newScaleCounts(:,myClass) = newScaleCounts(:,myClass) + updateScaleConst(G,alphas,betas,rhos,samplesMat(:,:,kk),tmpTrace,kk)';
    end 
    
    if (G.updateU)
      % size(gammas)= numStates x numRealTimes
      for dd=1:G.numBins
	repsamp = squeeze(repdata(:,dd,:))';
	%repsamp = repmat(squeeze(samplesMat(dd,:,kk)),[G.numStates,1]);
	gammaSum3(dd,kk,:)=sum(gammas.*repsamp,2)';
	gammaSum4(dd,kk,:)=sum(gammas,2)';
      end
    end

  end %% if (nargout==2)
end %%END ITERATING OVER INDIVIDUAL SAMPLES, kk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
if (nargout==2)
  if (G.updateSigma) 
    %% add the derivative over each class
    %warning('sigmas');keyboard;
    for cc=1:G.numClass
      newVals = sum(sigmaDeriv(1:G.numBins,G.class{cc}));
      derivSigma(cc) = newVals;
    end
    %derivSigma = sigmaDeriv;
  end %% end G.updateSigma
  
  if (G.updateZ)
    for bb=1:G.numBins
      derivZ = zHelper(G,ubar2,samplesMat,allValidStates,scaleFacs,scaleFacsSq,gammaSum1,squeeze(gammaSum2(bb,:,:)),gammaSum5,gammaSum6{bb},scalesExp,scalesExp2,bb);
    end
    if (G.useLogZ)
      derivZ = derivZ.*G.z(:);
    end
  end %%end G.updateZ   
  
  if (G.updateU)
    derivU = uHelper(G,gammaSum3,gammaSum4,scalesExp);
  end %% end G.updateZ

  
  if (G.updateTime)
    myStr=sprintf('TimeTrans prob')
    tmpStr = '';
    for jj=1:G.maxTimeSteps
      tmpStr = [tmpStr '%.4f '];
    end
    tmpStr = [tmpStr '\n'];
    myStr=sprintf(tmpStr,newD')
    fprintf(fidErr,'TimeTrans prob\n %s\n',myStr);
  end
  
  if (G.updateScale)
    newS = getNewS(G,newScaleCounts);	
    myStr=sprintf('ScaleTrans prob:%.4f\n',newS)
    myStr=[myStr sprintf('\n')];
    fprintf(fidErr,' %s\n',myStr);
  end
    
  %% propagate the state transition updates to our data
  %% structure, G
  if (G.updateTime)
    if (G.updateScale)
      G = reviseG(G,newS,newD);
    else
      G = reviseG(G,G.S,newD);
    end
  elseif (G.updateScale)
    G = reviseG(G,newS,G.D);
  end
  
end %% if nargout==2
 
newLike = sum(mainLikes);
newLike = newLike + scalePriorTerm + sum(timePriorTerm);
newLike = newLike + nuTerm + sum(smoothLikes) + scaleCenterPriorTerm;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% function values
f = newLike;

if (nargout==2)

  %% function derivative
  d=[];
  if (G.updateZ)
    d=[d;derivZ];
  end
  if (G.updateU)
    d=[d;derivU];
  end
  if (G.updateSigma)
    d=[d;derivSigma];
  end
end

%% we are going to use a minimization routine, so we actually
% want the negative of these:
f=-f;
if (nargout==2)
  d=-d;
end

%display('----------------now----------------');
%whos f d

if (verbose)
  toc;
end

return;
  
