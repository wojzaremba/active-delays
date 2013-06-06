%function numLines = getFileNumLines(fName);
%
% find out how many lines this file has

function numLines = getFileNumLines(fName);

cmd = ['[a b] = system(''' 'wc -l ' fName '''' ');'];
eval(cmd);

tmp = split(b,' ');
numLines = str2num(tmp{1});