% function nothing = closefigures(figInd)
%
% vector of figure numbers, if not provided,
% does 1:gcf

function nothing = closefigures(figInd)

if ~exist('figInd')
    figInd = 1:gcf;
end

for ii=reverse(figInd)
  if checkfigs(ii)
      close(ii);
  end
end


    