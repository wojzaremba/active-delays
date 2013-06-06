% function = axtitle(str,fontSize)
%
% adds a title to axes created with splitAxes, assuming that that 
% is the active axis
% (regular 'title' command puts it too high up)

function garb = axtitle(str,fontSize)

if (~exist('fontSize'))
  fontSize=12;
end
text(0.4,0.9,str,'Units','Normalized','FontSize',fontSize);
