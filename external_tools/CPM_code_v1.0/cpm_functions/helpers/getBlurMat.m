% function [blurMat timeVec mzVec] = ...
%    getBlurMat(timeBlur,mzBlur,drawMat);
%
% drawMat=1 then blurring matrix will be shown

function [blurMat timeVec mzVec] = ...
    getBlurMat(timeBlur,mzBlur,drawMat);

if ~(exist('drawMat')==1)
    drawMat=0;
end    

%timeBlur = 300;
%mzBlur = 5;

disp(['Blurring by ' num2str(timeBlur) ' in time']);
disp(['Blurring by ' num2str(mzBlur) ' in m/z']);

if 0
    %% rectangular
    blurMat = ones(timeBlur,mzBlur);    
elseif 0
    facLonger = 1;
    maxSize = max([facLonger*timeBlur facLonger*mzBlur]);
    mySize = [facLonger*timeBlur facLonger*mzBlur];
    myCov = maxSize*10;
    %myMean = 
    blurMat = mkGaussian(mySize,myCov);%,myMean,myAmp);
elseif 1
    timeVec = hamming(timeBlur);%hann(timeBlur);
    mzVec = hamming(mzBlur)';%hann(mzBlur)';
    %% normalize each, so that total is normalized
    if sum(timeVec)~=0
        timeVec=timeVec/sum(timeVec);
    end
    if sum(mzVec)~=0
        mzVec = mzVec/sum(mzVec);
    end
end

%% normalize it
mzVec = mzVec/(sum(mzVec));
timeVec = timeVec/(sum(timeVec));
blurMat = timeVec*mzVec;

if drawMat
    [midx midy]=size(blurMat);
    midx=max(floor(midx/2),1); 
    midy=max(floor(midy/2),1);
    figure,show(blurMat); colorbar;
    figure,plot(blurMat(midx,:)); title('X Slice');
    figure,plot(blurMat(:,midy)); title('Y Slice');
end

return;

blurStr = ['blurMat_T' num2str(timeBlur) '_M' num2str(mzBlur)];
savefigures(1:gcf,1:gcf,blurStr,'all');

    