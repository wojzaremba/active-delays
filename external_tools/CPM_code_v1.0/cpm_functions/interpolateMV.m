% function newVals = interpolateMV(vals)
%
% interpolate over the gaps from the DP alignment
% currently uses the built in interp1q (quick linear interp)


function newVals = interpolateMV(vals,gapSymbol)

%extrapMethod = 'linear';
%extrapVal = 0;
newVals = zeros(size(vals));

for seq=1:2
  temp=vals(seq,:);
  %find gapSymbols
  gapInd = find((temp==gapSymbol)==1);
  knownInd = find((temp~=gapSymbol)==1);
  %interpVals = interp1(knownInd,vals(knownInd),gapInd,extrapMethod,extrapVal);
  interpVals = ...
      interp1q(knownInd',temp(knownInd)',gapInd');
  temp(gapInd)=interpVals;
  
  newVals(seq,:)=temp;
  
  if (0)  %for debugging
    if (seq==1)
      original=d1;
    elseif (seq==2)
      original=d2;
    end
    figure,
    subplot(3,1,1), plot(original); title('original data');
    subplot(3,1,2), plot(vals(seq,:)); title('aligned/missing');
    subplot(3,1,3), plot(temp); title('aligned/interp');
  end
end

