function tokenList = split(str, delimiter)
% SPLIT Split a string based on a given delimiter
%	Usage:
%	tokenList = split(str, delimiter)

%	Roger Jang, 20010324

tokenList = {};
remain = str;
i = 1;
while ~isempty(remain),
	[token, remain] = strtok(remain, delimiter);
	tokenList{i} = token;
	i = i+1;
end
