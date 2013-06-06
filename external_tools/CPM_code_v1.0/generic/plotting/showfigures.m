% function nothing = showfigures(figInd,pauseDelay)
%
% Shows figures figInd with pauseDelay pause between
% if pauseDelay not provided, waits for user to strike a key

function nothing = showfigures(figInd,pauseDelay)

if ~(exist('figInd')==1)
    figInd = 1:gcf;
end

for ii=figInd
  figure(ii);
  if exist('pauseDelay')==1
      pause(pauseDelay);
  else
      disp('strike a key to continue display');
      pause;
  end
end
