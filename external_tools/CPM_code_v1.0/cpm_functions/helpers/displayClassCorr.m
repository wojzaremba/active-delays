%function displayClassCorr(ms1,ms2,i1,i2,statType,doBlur,timeBlur,mzBlur,minStd,minDiff)
% 
%% Same parameters as 'getClassCorr', except now we plot the 
%% difference in the means, thresholded by the test statistic

function displayClassCorr(ms1,ms2,i1,i2,statType,doBlur,...
    timeBlur,mzBlur,minStd,minDiff,minRelDiff,testThresh)

global hui meanDiff stat;

%% calculate stat with initial values
[stat m1 m2] = getClassCorr(ms1, ms2,...
    i1,i2,statType,doBlur,timeBlur,mzBlur,minStd,...
    minDiff,minRelDiff);

if 0
    global datB;
    for jj=1:size(datB,3)
        tmp=datB(:,:,3);
        if any(isinf(tmp(:))) 
            disp(['IsInf: ' num2str(jj)])
        end
        if any(isnan(tmp(:)))
            disp(['IsNan: ' num2str(jj)])
        end
    end
end
   

%% plot the difference in means, modulated by the t-statistic
%% (i.e. zero all differences that are not greater than
%% 'testThresh')

if ~exist('testThresh','var')
    testThresh=0;
end

meanDiff = m1-m2;
mask = abs(stat)>=testThresh;
show(meanDiff.*mask);
useMyColorMap('greenToWhiteToRed');
centerColorMap(meanDiff.*mask,0.99999);
colorbar;
title(['test statistic >= ' num2str(testThresh)]);

maxTestStat = max(abs(stat(:)));

% Set up slider, give its range (0-100),
% initial value (testThresh), and callback (m02)
hui=uicontrol('style','slider',...
    'value',testThresh,...
    'min',0,'max',maxTestStat,...
    'callback','sliderCallback',...
    'SliderStep',[0.1 0.10]);

















