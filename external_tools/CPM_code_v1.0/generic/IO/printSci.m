% function str = printSci(num,s)
%
% prints in scientific notation, with s significant digits

function str = printSci(num,s)

if (~exist('s'))
  s=3;
end

formatString=['%.' num2str(s) 'e'];
str=sprintf(formatString,num);

