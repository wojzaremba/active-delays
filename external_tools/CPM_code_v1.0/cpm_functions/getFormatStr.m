% function str = getFormatStr(n,numSigs)
%
% gives back a format string of the form:
% '%.3e %.3e .%3e .%3e\n' where here 
% numSigs=3 and n=4

function str = getFormatStr(n,numSigs)

str = '';
for ii=1:n
  str = [str '%.' num2str(numSigs) 'e' ' '];
end
str = [str '\n'];
