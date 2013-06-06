% function result = minx(xx)
%
% Calculate the min over all dimensions of a 
% multi-dimensional table.

function result = minx(xx)

numDims=length(size(xx));
cmdF='result=';
cmdB='';
for dd=1:numDims
  cmdF = [cmdF,'min('];
  cmdB = [cmdB,')'];
end

cmd = [cmdF,'xx',cmdB,';'];
eval(cmd);

