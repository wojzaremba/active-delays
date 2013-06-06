function latentTrace = initializeAllLatentTrace(G,baseTraces,randSeed,smoothFrac)

latentTrace = zeros(G.numTaus,G.numClass,G.numBins);

if ~exist('smoothFrac','var')
    smoothFrac='';
end

for cc=1:G.numClass
  myInds = G.class{cc};
 
  % just use one from each class
  if G.zInitType==1
      %% just use one of the traces and then smooth it
      thisTrace = squeeze(baseTraces(myInds(G.startSamp),:,:))';
  elseif G.zInitType==2      
      %% for DTW need all of the traces
      thisTrace = baseTraces(myInds,:,:);
  end
  
  if exist('randSeed') && ~isempty(randSeed)
    latentTrace(:,cc,:) = initializeLatentTrace(G,thisTrace,randSeed,smoothFrac)';  
  else
    latentTrace(:,cc,:) = initializeLatentTrace(G,thisTrace,'',smoothFrac)';  
  end;
end


