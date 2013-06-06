% function [lamVal nuVal] = parseForLambda(filename)
%
% parse files like: 'cvLambda.1.1.6.2e+06.2004-02-05.13:15:55.cluster12.mat'
% for the value of lambda, in this case, 6.2e+06.

function [lamVal, nuVal, numBins] = parseForLambda(filename)

%expr = '.*S(\d*e?.?\d*).N(\de?.?\d*).B(\d\d?).200.*';
%expr = '.*S(\d*e?.?\d*).N(\de?.?\d*).B(\d\d?).?P?\d?\d?.200.*';
expr = '.*S(\d*e?.?\d*).N(\de?.?\d*|Inf).B(\d\d?).?P?\d?\d?.200.*';

%expr = '.*S(\d*e?.?\d*).*';

%expr = '.*N([0-9e-+]*)S(.*).200d.*';
%expr = '.+S(\d*e?\d*.*).N(.*\d).*';



[startInd,finishInd,token]=regexp(filename,expr);

if isempty(token)
    error('regular expression not working');
end

token=token{1};
lamVal = str2num(filename(token(1,1):token(1,2)));
nuVal  = str2num(filename(token(2,1):token(2,2)));
numBins = str2num(filename(token(3,1):token(3,2)));


return;



%% old style
% 'cvLambda.1.1.6.2e+06.2004-02-05.13:15:55.cluster12.mat'
expr = 'cvLambda\.1\.1\.(.*)\.2004.*';
[startInd,finishInd,token]=regexp(filename,expr);
token=token{1};
lamVal = str2num(filename(token(1):token(2)));
