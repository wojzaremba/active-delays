% function result = maxx(xx)
%
% Calculate the max over all dimensions of a 
% multi-dimensional table.

function result = maxx(xx)

numDims=length(size(xx));
cmdF='result=';
cmdB='';
for dd=1:numDims
  cmdF = [cmdF,'max('];
  cmdB = [cmdB,')'];
end

cmd = [cmdF,'xx',cmdB,';'];
eval(cmd);

