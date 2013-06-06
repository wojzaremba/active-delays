%% function [currentTrace,G,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG]=
%%  trainFast(G,samples,UPDATE_SIGMA,thresh,errorLogFile,maxIter,saveFile)
%%
%% Same as trainFBHMM, but first trains using onlyOneScale, and
%% with no scale/time transition learning.  After that converges, 
%% it goes a few iterations with full learning.


function [currentTrace,G,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG]=trainFast(G,samples,UPDATE_SIGMA,thresh,errorLogFile,maxIter,saveFile)


%% first train, with oneScaleOnly, and not updateScale, updateT

UPDATE_SCALE=0; UPDATE_T=0;
UPDATE_Z=1; UPDATE_U=1;

%% convert parameter strucutre to only have one local scale state
tmpG = changeNumScales(G,'one');
%tmpG = G;

if (maxIter>0)
  [currentTrace,newG,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG]=trainFBHMM(tmpG,samples,UPDATE_SIGMA,UPDATE_T,UPDATE_SCALE,UPDATE_U,thresh,UPDATE_Z,errorLogFile,maxIter,saveFile);
else
  newG=tmpG;
end
  
%% now use the results of this to intialize full training, but
%% only for a few iterations

%% convert the newG to have all local scale states
tmpG = changeNumScales(newG,'all');
%tmpG=newG;

UPDATE_SCALE=1; UPDATE_T=1;
UPDATE_Z=1; UPDATE_U=1;
maxIter2 = 200;



[currentTrace,newG2,allTraces,likes,mainLikes,smoothLikes,nuTerm,timePriorTerm,scalePriorTerm,gammas,elapsed,myfval,allG]=trainFBHMM(tmpG,samples,UPDATE_SIGMA,UPDATE_T,UPDATE_SCALE,UPDATE_U,thresh,UPDATE_Z,errorLogFile,maxIter2,saveFile);

if (1)
  figure, plot(newG.z);
  figure, plot(newG2.z);
  imstats(abs(newG.z-newG2.z));
  warning('h'); keyboard;
end


return;

%%%%%%%%%%%%%%%%%%
fn=fieldnames(G);

for ii=46:length(fn)
  fn{ii}
  a=getfield(tmpG,fn{ii});
  b=getfield(G,fn{ii});
  if (max(size(a))==1)
    [a b]
    pause;
  else
    whos a b 
    if (isa(a,'double'))
      imstats(abs(a-b));
    end
    keyboard;
  end
end


%ii=45, scaleTransLog
% a         7x7x2                    784  double array
%  b         1x1x2                     16  double array

%ii=47, prec
% a         1x252                  61632  cell array
%  b         1x36                    4608  cell array
