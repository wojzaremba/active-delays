% function newG = changeNumScales(G,mode)
%
% takes a G, and leaves everything the same, except that it makes 
% it so that there is either 'one' or 'all' (as determined by
% mode) local scale states


function newG = changeNumScales(G,mode)

newG=G;

if (strcmp(mode,'one'))
  newG.oneScaleOnly=1;
  newG.scales=getScales(1);
elseif (strcmp(mode,'all'))
  newG.oneScaleOnly=0;
  newG.scales=getScales;
else
  error('mode must be all or one');
end

newG.numScales = length(newG.scales);

newG = getGhelper(newG);
forceIt=1;
newG=reviseG(newG,newG.S,newG.D,forceIt);

% this is for when we have a log-normal prior on the u_k's
%newG.w = (newG.scales(end)-newG.scales(1))*0.05;
