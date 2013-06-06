% function [currentTrace,G,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG]=trainDirect(G,samples,errorLogFile,saveFile)
%
% Use direct gradient ascent to minmize our CPM objective
% function (log p(x)) 
%
% lambda should be input as a positive value

function [errorFlag,currentTrace,G,newG,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,elapsed,it]=trainDirect(G,samples,errorLogFile,saveFile)

%array, with first position counting
% [nargout==1, nargout==2]
global FUNCTION_COUNTS; 
FUNCTION_COUNTS = zeros(1,2);

errorFlag=0;
currentTrace='';

tic;

if (G.numBins>1)
  error('Only works for numBins=1 now');
end

if (exist('saveFile') & ~isempty(saveFile))
  % save work after each iteration
  saveWork=1;
  savevars = 'elapsed allG smoothLikes mainLikes likes numIt initTrace';
  saveCmd = ['save ' saveFile ' ' savevars];
else
  saveWork=0;
end

errorFlag=0;
lambda=G.lambda; nu=G.nu; initTrace=G.z;
samplesMat = reshape(cell2mat(samples),[G.numBins G.numRealTimes G.numSamples]);
clear samples;

currentTrace=initTrace;
allTraces='';
gammas='';
alphas='';
rhos='';
smoothLikes='';
mainLikes='';
mytolx = '';

if (isempty(errorLogFile))
    errorLogFile=['/u/jenn/phd/MS/matlabCode/workspaces/trainDirect_' filenameStamp '.LOG'];   
end

if (~isfield(G,'class'))
  error('G does not have the class variable in it');
end

errorFound=0; 

%% file to log errors and messages
errorLogFile
cmd=['[fidErr,message]=fopen(errorLogFile,' '''a''' ');']
eval(cmd);
if (fidErr==-1)
    error(['Unable to open file: ' errorLogFile]);
end

if (~isfield(G,'sigmas'))
    [G.sigmas,G.varsigma] = getInitSigmas(G,samplesMat);
end

tmpStr = printGfields(G);
tmpStr=sprintf(tmpStr);
display(tmpStr);
fprintf(fidErr,'%s\n',tmpStr);

%minSigmaUpdateIt=G.minSigmaUpdateIt;

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

uCoeff = zeros(G.maxIter,G.numSamples,4);
myfval = zeros(G.maxIter,G.numSamples);

%% precompute valid states for each time step (for updating Z)
%% this never changes
[allValidStates,scaleFacs,scaleFacsSq] = getValidStates(G);

initialGuess = getGuessVec(G);

%% ----use checkgrad----------
if (0)
  e=1e-2; %for G.z
  [d anal fd]=checkgrad('objective',initialGuess,e,G,samplesMat,allValidStates,scaleFacs,scaleFacsSq,scalesExp,scalesExp2);
  anal./fd
  warning('checked gradient'); keyboard;
end
%% ----------------------------

%a=getJacobPatternDirect(G,initialGuess);
%spy(a); warning('hh'); keyboard;

%% now set up the minimization routine
myTol=1e-10;
options = optimset('GradObj', 'on', 'DerivativeCheck','off','TolFun',1e-3,'Display','iter','TolX',myTol,'LargeScale','on','Diagnostics', 'off','TypicalX',initialGuess,'MaxIter',50,'MaxFunEvals',1000,'Hessian','off');%,'HessPattern',getJacobPatternDirect(G,initialGuess));

if (0)
  [newGuess, fval, exitflag,output,grad]=fminunc(@objective,initialGuess,options,G,samplesMat,allValidStates,scaleFacs,scaleFacsSq,scalesExp,scalesExp2);
  likes = fval;
  it = output.iterations;
else
  G.maxLineSearch=G.maxIter;
  verbose=1;
  [newGuess, derivGuess, it, fval,elapsed] = minimize(initialGuess,'objective',fidErr,G.maxLineSearch,verbose,G,samplesMat,allValidStates,scaleFacs,scaleFacsSq,scalesExp,scalesExp2);
  likes=fval;
end

%% now instantiate a newG with the newly found parameters
newG=reviseAllG(G,newGuess);
newG = stripG(newG);

%%%%%%%%%%%%%%% print some stuff out to file%%%%%%%%%%%
tmpStr=['Iterations: ' num2str(it)];
display(tmpStr);
fprintf(fidErr,'\n%s\n\n',tmpStr);

if (newG.updateSigma)
  formatStr = getFormatStr(newG.numSamples,2);
  myStr=sprintf(formatStr,newG.sigmas);
  display(tmpStr);
  fprintf(fidErr,'SigmaUpdates\n%s\n',myStr);
end
  
if (newG.updateU)
   myStr=sprintf('newG.u:%.4f\n',newG.u)
   display(tmpStr);
   fprintf(fidErr,'%s\n',myStr);
end

myStr=sprintf('FUNCTION_COUNTS:%d\n',FUNCTION_COUNTS)
display(tmpStr);
fprintf(fidErr,'%s\n',myStr);

myStr=sprintf('Elapsed Time (min) :%f\n',sum(elapsed))
display(tmpStr);
fprintf(fidErr,'%s\n',myStr);

msg1 = ['FINAL DIRECT Iteration: ' num2str(it), ',  logLike=' printSci(fval,6) ' elapsed:' num2str(sum(elapsed))];
msg1
fprintf(fidErr,'%s\n\n',msg1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[f d] = objective(initialGuess,G,samplesMat,allValidStates,scaleFacs,scaleFacsSq,scalesExp,scalesExp2);


%warning('Finished trainDirect.m'); keyboard
return;
