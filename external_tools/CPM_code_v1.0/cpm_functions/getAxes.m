% function [H,allAxes] = getAxes(numAx);
% 
% generates the three axes to generate inset plots for alignments
% allAxes=[scaleAx,mainAx,insetAx];

function [H,allAxes] = getAxes(numAx);

if (~exist('numAx'))
  numAx=3;
end

%% format is always
%% xStart, yStart, xSpan, ySpan

H=figure;

if (numAx==2)
  %default when you call just axes by itself
  mainAx=axes('Position',[0.13, 0.11, 0.775, 0.815]);
  insetAx=axes('Position',[0.18,0.50,0.22,0.38]);
  allAxes=[mainAx,insetAx];

elseif (numAx==4)
  mainAx=axes('Position',[0.1,0.25,0.85,0.7]);

  scaleAx=axes('Position',[0.1,0.1,0.85,0.04]);
  timeAx=axes('Position',[0.1,0.15,0.85,0.04]);
  errAx=axes('Position',[0.1,0.2,0.85,0.04]);
  allAxes=[mainAx,scaleAx,timeAx,errAx];

elseif (numAx==5)
  %mainAx=axes('Position',[0.1,0.25,0.85,0.7]);
  %scaleAx=axes('Position',[0.1,0.1,0.85,0.04]);
  %timeAx=axes('Position',[0.1,0.15,0.85,0.04]);
  %errAx=axes('Position',[0.1,0.2,0.85,0.04]);
  %insetAx=axes('Position',[0.11,0.70,0.26,0.22]);
  
  mainAx=axes('Position',[0.1,0.4,0.85,0.55]);
  scaleAx=axes('Position',[0.1,0.1,0.85,0.09]);
  timeAx=axes('Position',[0.1,0.2,0.85,0.09]);
  errAx=axes('Position',[0.1,0.3,0.85,0.09]);
  
  %% largest one
  %insetAx=axes('Position',[0.13,0.65,0.33,0.28]);
  %% smaller one
  %insetAx=axes('Position',[0.15,0.8,0.15,0.13]);
  %% intermediate one
  insetAx=axes('Position',[0.11,0.73,0.20,0.20]);
  
  allAxes=[mainAx,scaleAx,timeAx,errAx,insetAx];
end
