% function H = showMS(qmzD,merged,myWindow,lineMarkerPos,...
%    timeRatio,keepScans,plotLog,numDig,LOW,SHOW_DIFF,colorScheme)
%
% SHOW_DIFF will also show the difference between the two spectra
% if merged==1
%
% Display one figure per dd item as a 2D MS data, with
% color for the third dimension.
%
% If 'merged'=1, it can only take two samples, and
% superimposes them using two different color schemes,
% and transparency
%
% lineMarkPos is the position of line markers to put in to track
% the shifting traces

function H = showMS(qmzD,merged,myWindow,lineMarkerPos,...
    timeRatio,SHOW_DIFF,drawColorbar,keepScans,plotLog,numDig,LOW,colorScheme)


fontSize=12;

if ~iscell(qmzD)
    qmzD={qmzD};
end

if ~exist('drawColorbar','var')
    drawColorbar=1;
end

if ~exist('merged')|isempty(merged)
    merged=0;
end

if ~(exist('SHOW_DIFF')==1)
    SHOW_DIFF=0;
elseif ~merged
    SHOW_DIFF=0;
end

if length(qmzD)>2 & (merged)
    error('Not yet equipped to handle more than 2 images');
end

if ~exist('colorScheme')
    colorScheme=6;
end

if ~exist('myWindow')
    zoomIn=0;
elseif isempty(myWindow)
    zoomIn=0;
else
    zoomIn=1;
end

if ~exist('timeRatio')
    timeRatio=1;
end

if ~exist('keepScans')
    keepScans=1:length(qmzD{1});
end

if ~(exist('plotLog')==1)
    plotLog=0;
end

if ~(exist('numDig')==1)
    numDig=2;
end
if ~(exist('LOW')==1)
    LOW=400;
end

if merged &(length(qmzD)~=2)
    error('Can only use 2 merged images');
end

%% Load up colormaps
theseMaps{1} = {'blackToRed' 'blackToGreen'};
theseMaps{2} = {'blackToRedNowhite' 'blackToGreenNowhite'};
theseMaps{3} = {'whiteToRed' 'whiteToGreen'};
theseMaps{4} = {'blackToRed2' 'blackToGreen2'};
theseMaps{5} = {'whiteToRed2' 'whiteToGreen2'};
theseMaps{6} = {'whiteToRed4' 'whiteToGreen4'};
thisMap=theseMaps{colorScheme};
clmaps=getColorMaps(thisMap);

if merged
    %% concatenate them to get dual colormaps on same image
    clMap = [clmaps{1} ; clmaps{2}];
else
    clMap = clmaps{1};
end

LOGBASE=2;

for ii=1:length(qmzD)
    %%display the data in 2D
    plotData=qmzD{ii};
    if ~zoomIn
        myWindow=[1 size(plotData,1) 400 1600];
    end
    
    %% Y - scan data,  X - M/Z
    rangeYLim = [myWindow(1),myWindow(2)];
    %rangeYLim = rangeYLim*timeRatio;
    rangeY=rangeYLim(1):rangeYLim(2);

    rangeXLim=[myWindow(3),myWindow(4)];
    % account for qmz quanitzation
    rangeXLim=(rangeXLim-(LOW-1))*numDig;
    rangeX=rangeXLim(1):rangeXLim(2);

    %[minx(rangeY) maxx(rangeY)]
    %[minx(rangeX) maxx(rangeX)]
    %whos plotData
    
    plotData=plotData(rangeY,rangeX);

    %% make small stuff go away a bit:
    plotData = plotData.^(1.5);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Tricks with data to get good contrast given the huge
    %% dynamic range of the data and tons of garbage, etc.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BLUR=1;
    if BLUR
        %% blur the data along m/z
        %blurMat = [1/4 1/2 1/4];
        %plotData2 = conv2(plotData,blurMat);
        timeBlur=2; mzBlur=2;
        [blurMat timeVec mzVec] = getBlurMat(timeBlur,mzBlur,0);
        plotData2 = blurQmz(plotData,timeVec,mzVec); 
        %% remove extra padding that got from convolution
        plotData = plotData2(:,2:(end-1));
    end

    mymin=0; mymax=100; midway=(mymax+mymin)/2;
    %mymin=0; mymax=max(plotData(:));
    tempSort = sort(plotData(:));
    clipmin=0; clipmax=tempSort(end-10); % in case of outliers

    %plotData=rescaledata(plotData,mymin,mymax,clipmin,clipmax);
    %fracRemove=0;%.05;
    %plotData(plotData<fracRemove*mymax)=0;

    %mymin=''; mymax='';
    plotData=rescaledata(plotData,mymin,mymax,clipmin,clipmax);
    %% now push the bottom junk to 0
    plotDataRaw{ii}=rescaledata(plotData,mymin,mymax,0,100);
    %% apply a power transform to make stuff more visible
    powTransform = 0.55;
    plotData = plotData.^powTransform;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~merged
        colormap(clMap);
        %plotData(1:1,1:1)=2*max(max(plotDataKeep{1})); %HERE?
        H{ii}=image(plotData,'CDataMapping','scaled'); hold on;
    else
        if merged & (ii==2)
            %% Hack for adding two colour maps together on same figure
            %% Found this on the mathworks website!
            plotData = plotData + max(max(plotDataKeep{1}));
        end
        plotDataKeep{ii}=plotData;
        %imstats(plotData);
    end
    if ~merged & (ii>1)
        figure,
    end
end  %% end iterating over images


if merged
    %% play with the data so that when only one of the two
    %% merged images has non zero data, that that one gets
    %% full pixel intensity, but otherwise, they share
    minInk=0;
    for jj=1:2
        if jj==1
            hasInk{jj} = (plotDataKeep{jj}>minInk);
        elseif jj==2
            hasInk{jj} = (plotData>minInk);
        end
    end
    %% find out where there is no competion
    noComp{1} = hasInk{1} & ~hasInk{2};
    noComp{2} = hasInk{2} & ~hasInk{1};
    noCompDat = plotDataKeep{1};
    for jj=1:2
        tmpDat = plotDataKeep{jj};
        noCompDat(find(noComp{jj})) = tmpDat(find(noComp{jj}));
    end
    isComp = ~noComp{1} | ~noComp{2};
    compSecondImage = zeros(size(plotData));
    tmpDat = plotDataKeep{2};
    compSecondImage(find(isComp)) = tmpDat(find(isComp));
    H{1}=image(noCompDat,'CDataMapping','scaled'); hold on;
    H{2}=image(compSecondImage,'CDataMapping','scaled'); hold on;
    
    imAlphaData = 0.5*ones(size(plotData));
    imAlphaData(noComp{1})=0;
    imAlphaData(noComp{2})=1;
    set(H{ii},'AlphaData',imAlphaData);

    colormap(clMap);
    if drawColorbar
        colorbar;
    end
    
    %% add the colour axes together
    newcaxis=[mymin,length(qmzD)*mymax];
    %newcaxis=[mymin,length(qmzD)*clipmax];
    caxis(newcaxis);
    %set(gca,'FontSize',fontSize);
end

ylabel('Time','FontSize',fontSize);
xlabel('Mass/Charge','FontSize',fontSize);

Xlabels=get(gca,'XTickLabel');
if zoomIn
    newXLabels=(str2num(Xlabels))/numDig + myWindow(3);  
    Ylabels=get(gca,'YTickLabel');
    newYLabels=str2num(Ylabels);
    %newYLabels=newYLabels + myWindow(1)*timeRatio;
    newYLabels=(newYLabels + myWindow(1)*timeRatio)/timeRatio;
    set(gca,'YTickLabel',newYLabels);
    %end
else
    newXLabels=str2num(Xlabels)/numDig+(LOW-1);
end

%Xlabels
%str2num(Xlabels)/numDig
%str2num(Xlabels)/numDig +LOW

set(gca,'XTickLabel',newXLabels);
myTit='Time Vs. M/Z';
myTit = [myTit ' Experiment ' num2str(ii)];
title(myTit,'FontSize',fontSize);

if (exist('lineMarkerPos')==1)
    drawMarkers(lineMarkerPos,timeRatio,myWindow);        
end

if merged
    ax = findobj(gcf,'Type','axes');
    set(ax,'CLim', [minx(plotDataKeep{1}) maxx(plotDataKeep{2})]);
    %% something about ensuring proper usage of the color map
    set(gcf,'MinColormap',length(get(gcf,'ColorMap')));
end
set(gca,'FontSize',fontSize);

%% also show a map of the differences
if SHOW_DIFF
    %% get axes from previous graph
    Ylabels=get(gca,'YTickLabel');
    YTick=get(gca,'YTick');
    Xlabels=get(gca,'XTickLabel');
    XTick=get(gca,'XTick');
    
    tmpDat = plotDataRaw{1}-plotDataRaw{2};
    posInd = find(tmpDat>0);
    negInd = find(tmpDat<0);
    tmpDat(posInd) = tmpDat(posInd).^powTransform;
    %% to avoid complex numbers,etc
    tmpDat(negInd) = -((-tmpDat(negInd)).^powTransform);
    figure,image(tmpDat,'CDataMapping','scaled'); hold on;
    useMyColorMap('greenToWhiteToRed');
    trimFrac=0.9999;
    centerColorMap(tmpDat,trimFrac)
    if drawColorbar
        colorbar;
    end

    ylabel('Time','FontSize',fontSize);
    xlabel('Mass/Charge','FontSize',fontSize);
    
    set(gca,'YTick',YTick);
    set(gca,'XTick',XTick);
    set(gca,'YTickLabel', Ylabels);
    set(gca,'XTickLabel', Xlabels);
    
    drawMarkers(lineMarkerPos,timeRatio,myWindow);    
    set(gca,'FontSize',fontSize);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawMarkers(lineMarkerPos,timeRatio,myWindow)

for ii=1:length(lineMarkerPos)
    % draw guidelines to track alignments
    if exist('lineMarkerPos')
        if ~isempty(lineMarkerPos)
            guideLabels=['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I'];
            lsp={'-', '--', ':', '-.','-', '--', ':', '-.','-', '--', ':', '-.'};
            if timeRatio==1
                mycolours1 = {'k','k'};
                mycolours2 = {'k','k'};
            else
                mycolours1 = {'r','g'}; %lines
                mycolours2 = {'r','k'}; %matching text
            end
            ms=lineMarkerPos{ii};
            for jj=1:length(ms)
                thisSpec = [mycolours1{ii} lsp{jj}];
                tmpaxis=axis;
                myLineX=[ceil(tmpaxis(1)),floor(tmpaxis(2))];
                %myLineY=[ms(jj),ms(jj)] - myWindow(1)*timeRatio;
                myLineY=[ms(jj),ms(jj)] - myWindow(1);
                plot(myLineX,myLineY,thisSpec,'LineWidth',1);
                if (timeRatio>1)
                    %% this just offsets the two sets of labels in
                    %case they lie on top of each other
                    %offset=10;
                    offset=2;
                    text(myLineX(2)+4+offset*(ii-1),myLineY(1), guideLabels(jj),'Color', mycolours2{ii},'FontSize',12);
                else
                    text(myLineX(2)+4,myLineY(1), guideLabels(jj),'Color', mycolours2{ii},'FontSize',12);
                end
            end
        end
    end
end











