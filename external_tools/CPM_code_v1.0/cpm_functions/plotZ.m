% function garb = plotZ(G)
%
% plots each class of z one axis at a time, and then the
% difference between them.  does not work well for more
% than two classes, does not work well for numBins>1


function garb = plotZ(G)

if (G.numBins>1) | (G.numClass>2)
  error('only works with numBins=1, numClass<2');
end

allAx=splitAxes(G.numClass+1,1,'latent trace');
ms=2;
maxVal = maxx(G.z);

for cc=1:G.numClass
  axes(allAx{cc});
  tmpDat = G.z(:,cc);
  %imstats(tmpDat);
  %whos tmpDat
  plot(tmpDat,'MarkerSize',ms);
  title(['Class ' num2str(cc)]);
  tmpAx = axis;
  tmpAx(4)=maxVal;
  axis(tmpAx);
end

zdiff = (G.z(:,2)-G.z(:,1));

axes(allAx{G.numClass+1});
plot(zdiff,'MarkerSize',ms);
title('Class 2 - Class 1');
hold on;
plot(zeros(size(zdiff)),'r-');
