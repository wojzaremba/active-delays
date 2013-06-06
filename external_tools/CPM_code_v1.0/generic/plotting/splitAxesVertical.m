% function axesArray =  splitAxesVertical(numPlots,ratios,space)
%
% split up the plot into vertical plots, in the ratio
% specified by the vector ratios (can be unnormalized)

function axesArray =  splitAxesVertical(numPlots,ratios,space)

ratios = ratios/sum(ratios);
R=numPlots; C=1;
if length(ratios)~=numPlots
    error('ratios vector needs to be same length as numPlots -- otherwise just use splitAxes(1,numPlots)');
end

figure,

%% this is the default window
%% axes('Position',[0.13, 0.11, 0.775, 0.815]);

keepOrigSize=0;
if keepOrigSize
    xSpan = 0.775; ySpan = 0.815;
    xStart = 0.13; yStart = 0.11;
else    
    xSpan = 0.9; ySpan = 0.92;
    xStart = 0.05; yStart = 0.05;
end

%xStart = 0.08; 				%0.13
%yStart = 0.11;%0.815;

if exist('space','var') && ~isempty(space)
    if space>0.1
        error('probably wont work');
    end
    xSpace=space;
    ySpace=space;
else
    xSpace = 0.02;
    ySpace = 0.02;
end


xWidth = (xSpan - (C-1)*xSpace)/C;
%yWidth = (ySpan - (R-1)*ySpace)/R;

totalVertSpaceAvail = (ySpan - (R-1)*ySpace);
yWidth = zeros(1,numPlots);
for n=1:numPlots
    yWidth(n) = (ySpan - (R-1)*ySpace)*ratios(n);
end

axesArray = cell(1,C);
nxt=0;
rr=1;
for r=R:-1:1
    cc=1;
    for c=1:C
        nxt=nxt+1;

        xS = (c-1)*(xWidth+xSpace) + xStart;

        %yS = (r-1)*(yWidth+ySpace) + yStart;
        if nxt==1
            yS(nxt) = yStart;
        else
            yS(nxt) = yS(nxt-1) + ySpace + yWidth(nxt-1);
        end

        tmpAx = axes('Position',[xS,yS(nxt),xWidth,yWidth(nxt)]);
        axesArray{rr,cc}=tmpAx;
        cc=cc+1;

    end
    rr=rr+1;
end

axesArray=axesArray';

oneD = 0;
if oneD
    if ~flip
        axesArray=axesArray(:);
    else
        tmp=axesArray';
        axesArray=tmp(:);
    end
end

axes(axesArray{max(floor(C/2),1)});
xx=0.5;
yy=0.95;
%text(xx,yy,myTitle,'Units','Normalized','FontSize',10);
