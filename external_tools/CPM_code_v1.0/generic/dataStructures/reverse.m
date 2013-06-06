%function result=reverse(oneD)
%
% reverses a 1D array

function result=reverse(oneD)

if isempty(oneD)
    result=oneD;
    return
end

numR=max(size(oneD));

result=oneD(numR:-1:1);