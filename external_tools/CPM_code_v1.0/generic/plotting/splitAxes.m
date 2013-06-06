%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function axesArray = 
%     splitAxes(R,C,myTitle,space,oneD,isSquare,flip,keepOrigSize,maxNum)
%
% Split up a normal sized image into R rows by C columns, just like
% subplot would, but with less space between them
%
% default space is 0.02
%
% if flip==1, then the handles are given for the transpose
% matrix template
%
% 'keepOrigSize=1' uses only the same portion of the figure that plot would;
% otherwise this funciton uses a bit more.
%
% 'maxNum' specified how many plots you will use, if using fewer than
% R*C (so that you don't have blank axes)
%
% 'oneD=1' -- I can't remember...
%
% 'isSquare=1' -- I can't remember...
%
% After calling h=splitAxes(4,2), draw on using axes(h{1}), axes(h{2}),
% etc.
% 
% Author: Jennifer Listgarten, 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function axesArray = ...
    splitAxes(R,C,myTitle,space,oneD,isSquare,flip,keepOrigSize,maxNum)

if ~exist('myTitle','var')
  myTitle='';
end

if ~exist('oneD','var')
  oneD=1;
end

if ~exist('isSquare','var')
    isSquare=0;
end

if ~exist('flip','var')
    flip=0;
end

if ~exist('keepOrigSize')
    keepOrigSize=1;
end

if ~exist('maxNum','var')
    maxNum=R*C;
end


figure,

%% this is the default window
%% axes('Position',[0.13, 0.11, 0.775, 0.815]);

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
    if any(space>0.1)
        error('probably wont work');
    end
    xSpace=space(1);
    if length(space)==2
        ySpace=space(2);
    else
        ySpace=xSpace;
    end
else
    xSpace = 0.02;
    ySpace = 0.02;
end


xWidth = (xSpan - (C-1)*xSpace)/C;
yWidth = (ySpan - (R-1)*ySpace)/R;

if isSquare
    tmpSize = min(xWidth,yWidth);
    xWidth = tmpSize;
    yWidth = tmpSize;
end

axesArray = cell(R,C);
nxt=0;
rr=1;
for r=R:-1:1
    cc=1;
    for c=1:C
        nxt=nxt+1;
        if nxt<=maxNum
            xS = (c-1)*(xWidth+xSpace) + xStart;
            yS = (r-1)*(yWidth+ySpace) + yStart;
            %yS = yStart - (r-1)*(yWidth+ySpace);
            tmpAx = axes('Position',[xS,yS,xWidth,yWidth]);
            axesArray{rr,cc}=tmpAx;
            cc=cc+1;
        end
    end
    rr=rr+1;
end

axesArray=axesArray';
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
text(xx,yy,myTitle,'Units','Normalized','FontSize',10);
