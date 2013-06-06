% function nothing = minfigures(figInd)
%
% minimize figure windows
%
% vector of figure numbers, if not provided,
% does 1:gcf

function nothing = closefigures(figInd)

if ~exist('figInd')
    figInd = 1:gcf;
end

for ii=reverse(figInd)
  close(ii);
end


    