function coord = mzToCoord(mz,LOW,numDigits)

if nargin==1
    numDigits=2;
    LOW=400;
end

%% round mz to nearest 0.5
mzr=round(mz*numDigits)/numDigits;
coord=(mzr-LOW)*numDigits+1;  %CORRECT
return;



