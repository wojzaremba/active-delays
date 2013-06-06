% function bigvector = oversample(vector, ratioMore);
%
% Oversample 'vector' by a ratio 'ratioMore' (eg. ratioMore=2
% means that bigvector has 2 X as many entries as vector.
%
% Use linear interpolation between real points

function bigvector = oversample(vector, ratioMore);


%choice='resample'; %note that this depends on the signal toolbox
choice='noInterp';

if (choice=='noInterp')
  newsize = ratioMore*length(vector);
  bigvector = ones(1,newsize);
  for ii=1:ratioMore
    bigvector(ii:ratioMore:end) = vector;
  end

elseif (choice=='resample')
  bigvector = resample(vector,ratioMore,1);

else
  error('No other options');
end

