% showClassTraces(allSamp,G,scaleAndTimes,newTrace,numPlots)
%
% Same as showTraces (which this calls), but makes a seperate
% plot for each plot.


function allAx = showClassTraces(allSamp,G,scaleAndTimes,z,numPlots)

for cc=1:G.numClass
  cInd = G.class{cc};
  tmpG=reduceG(cInd,G);
  allAx{cc} = showTraces(allSamp(cInd),tmpG,scaleAndTimes(cInd,:,:),z(:,cc),numPlots);
  varTxt = ['\nu=' num2str(G.nu,3) ' \lambda=' num2str(G.lambda,3)];
  title([varTxt ', Class ' num2str(cc)]);
end
