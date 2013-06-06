% function str = printGfields(G)
%
% print out G's parameters to a string


function str = printGfields(G)

fieldList = getGfields;
str = printFieldValues(G,fieldList);
