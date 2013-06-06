% function mzAbun=getMZAbun(data);
%
% Calculates the total abundance at each
% mz (however it was quantized and returned by 
% quantizeMS().

function mza=getMZAbun(data)

% data (scans X mass)

mza=sum(data,1);
