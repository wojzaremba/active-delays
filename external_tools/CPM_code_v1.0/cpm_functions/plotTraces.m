function plotTraces(z)

numBins = size(z,3);
C = size(z,2);

myLeg = cell(1,C);
for cc=1:C
  myLeg{cc}=['Class ' num2str(cc)];
end

for bb=1:numBins
  figure, plot(squeeze(z(:,:,bb)));
  title(['Bin ' num2str(bb)]);
  legend(myLeg);
end
