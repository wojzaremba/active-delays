function mz = coordToMz(coord,LOW,numDigits)

if nargin==1
    numDigits=2;
    LOW=400;
end

mz=(coord-1)/numDigits + LOW; %% CORRECT

return;
