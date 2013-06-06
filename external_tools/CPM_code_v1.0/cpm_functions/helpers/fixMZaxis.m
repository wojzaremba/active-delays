function fixMZaxis(ax,tickInterval)

if ~exist('tickInterval','var')
	tickInterval=100;
end

% make the mz axis correct
numDig=2;
xTickLabel = 400:tickInterval:1600;
xTick=mzToCoord(xTickLabel);
%tmp=coordToMz(xTick)
set(ax,'XTick',xTick);
set(ax,'XTickLabel',xTickLabel);

return;

