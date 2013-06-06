function [randThresh] = ...
    plotWelchT(welchT,welchTR,keepTopFrac,...
    MAKE_FIGURES,timeWin);

%% keepTopFrac is how may of the random stats we actually
%% saved (keepTopFrac/2 on the top, and same on the bottom)
%% alpha is the significance level we would like to use in
%% determining significance

%% random data
welchTBlurR = welchTR;%;(find(welchTR~=0));
sortBlurStatsR = sort(welchTBlurR(:),1,'descend');
minAlphaInd =  length(sortBlurStatsR);
topAlphaInd = 1;
maxRandVal = sortBlurStatsR(topAlphaInd);
minRandVal = sortBlurStatsR(minAlphaInd);

PLOT_RANDOM = 0;%length(welchTR)>2;

%% for real data
global welchTReal;
welchTReal = welchT;%(find(welchT~=0));
clear welchT;
sortBlurStats = sort(welchTReal(:),1,'descend');
minRealVal = sortBlurStats(end);
maxRealVal = sortBlurStats(1);

%% for plotting axes informatively
maxVal = max(abs([minRealVal maxRealVal minRandVal maxRandVal]));

randThreshPos = maxRandVal;
randThreshNeg = minRandVal;

%% plot the distribution of statistics
if MAKE_FIGURES
    ftSize = 24;
    axFac = 1.02;
    legendLoc = 'NorthEast';
    %figure,

    if PLOT_RANDOM
        subplot(2,1,1),

        keyboard;

        plot(sortBlurStatsR,'k-','LineWidth',3);
        grid on;
        str = ['(min,max) = '...
            num2str(minRandVal,2) ', ' num2str(maxRandVal,2)];
        legend(str,'Location',legendLoc);
        title(['Sorted Non-Zero Blurred T-Statistics (Permuted Data)'],'FontSize',ftSize);

        ylabel('Blurred T-Statistic','FontSize',ftSize);
        xlabel('Sort Index','FontSize',ftSize);
        hold on;
        thisLength = length(sortBlurStatsR);
        %% plot the zero line
        plot([1 thisLength], [0 0],'b-','LineWidth',3);
        xaxis([0-thisLength*.05 thisLength*1.05]);
        yaxis([-maxVal*axFac maxVal*axFac]);
        set(gca,'FontSize',ftSize);

        subplot(2,1,2)
    end
    
    if 0%% used to be on
        plot(sortBlurStats,'k-','LineWidth',3);
        grid on;
        str{1} = ['(min,max) = '...
            num2str(minRealVal,2) ', ' num2str(maxRealVal,2)];
        str{2} = 'Zero Line';
        str{3} = ['randThreshNeg=' num2str(randThreshNeg,2)];
        str{4} = ['randThreshPos=' num2str(randThreshPos,2)];

        %title(['Sorted Non-Zero Blurred T-Statistics (Non-Permuted Data)'],'FontSize',ftSize);
        ylabel('Spatial T-Statistic','FontSize',ftSize);
        %xlabel('Sort Index','FontSize',ftSize);
        hold on;
        thisLength = length(sortBlurStats);
        plot([1 thisLength], [0 0],'b-','LineWidth',3);
        xaxis([0-thisLength*.05 thisLength*1.05]);
        yaxis([-maxVal*axFac maxVal*axFac]);
        set(gca,'FontSize',ftSize);

        hold on;
        plot([1 thisLength], [randThreshPos randThreshPos],'r--','LineWidth',2);
        plot([1 thisLength], [randThreshNeg randThreshNeg],'r--','LineWidth',2);

        %legend(str,'Location',legendLoc);
    end
    
    if 0
        set(gca,'FontSize',ftSize);
        saveDir = '/w/24/jenn/phd/workspaces/ECCB06/std0_1_Feb8.2006_rankCurves/';
        savefigures(1,1,'statDistrib','all',saveDir);
        keyboard;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    randThresh =5;%mean([randThreshPos abs(randThreshNeg)]);      
    timeRg=timeWin(1):timeWin(2);
    mzRg=1:size(welchTReal,2);
    global welchTRealPlot;
    welchTRealPlot=welchTReal(timeRg,mzRg);   
   
    %figure,show(welchTRealPlot);  
    maxTestStat = max(abs(welchTReal(:)));
    
    %% update the plot
    mask = abs(welchTRealPlot)>=randThresh;
    tmpDat = welchTRealPlot.*mask;
    show(tmpDat);
    
    useMyColorMap('greenToWhiteToRed');
    centerColorMap(welchTReal,0.99999);
    %colorbar;
    
    
    % Set up slider, give its range (0-100),
    % initial value (testThresh), and callback (m02)
    global hui;
    hui=uicontrol('style','slider',...
        'value',randThresh,...
        'min',0,'max',maxTestStat,...
        'callback','sliderCallback2');%,...
        %'SliderStep',[0.1 0.10]);
end

%clear global welchTReal;


