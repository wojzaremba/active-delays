% function qmz = quantizeAllMS(scans,header)
%
% Quantize mass spec data, and convert it into
% a 2D matrix (scans,mz)
%
% scans and header can be 1D cell arrays, then qmz returned
% will be a cell array result, one per cell array input.

function qmz = quantizeAllMS(scans,header)

qmz=cell(1,length(scans));

numExp=length(scans);

for ii=1:numExp
    numScanHeaders=size(header{ii},1);
    thisRange=1:numScanHeaders;
    tmpScale = 1;
    qmz{ii}=quantizeMS(scans{ii},header{ii},thisRange,tmpScale);
end
