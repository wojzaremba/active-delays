function plotMeansVariances(m1,m2,v1,v2,percentile)

if min(v1(:))<-eps || min(v2(:))<-eps
    error('variance is negative');
end

v1(find(v1<0))=0;
v2(find(v2<0))=0;

pow = 1;%0.5;
pow2 = 1%0.5;
%percentile=95;  %% for cropping the image

myAx = splitAxes(2,2,'Spectral Class Comparison',0.05);

axes(myAx{1}),showCrop(m1.^pow,percentile);
title(['mean^{' num2str(pow) '} Class 1']); colorbar;

%axes(myAx{2}),show(v1.^pow2);
%title(['variance^{' num2str(pow2) '} Class 1']); colorbar;
zeroInd = find(m1==0);
v1(zeroInd) = 0; m1(zeroInd)=1;
this = (v1./(m1)).^pow2;
axes(myAx{2}),showCrop(this,percentile);
title(['CV^{' num2str(pow2) '} Class 1']); colorbar;

axes(myAx{3}),showCrop(m2.^pow,percentile);
title(['mean^{' num2str(pow) '} Class 2']); colorbar;

zeroInd = find(m2==0);
v2(zeroInd)=0; m2(zeroInd)=1;
this = (v2./(m2)).^pow2;
this(zeroInd)=0;
axes(myAx{4}),showCrop(this,percentile);
title(['CV^{' num2str(pow2) '} Class 2']); colorbar;

myDiff = m1-m2;
pp=100;
figure,showCrop(myDiff,pp);
title(['mean(class 1) - mean(class 2)']);
useMyColorMap('greenToWhiteToRed');
centerColorMap(myDiff,0.99999);
colorbar;

