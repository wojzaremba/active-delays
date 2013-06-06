% imStats(IM1,IM2)
%
% Report image (matrix) statistics.
% When called on a single image IM1, report min, max, mean, stdev, 
% and kurtosis.
% When called on two images (IM1 and IM2), report min, max, mean, 
% stdev of the difference, and also SNR (relative to IM1).

% Eero Simoncelli, 6/96.

function [] = imStats(im1,im2)

if (~isreal(im1))
  error('Args must be real-valued matrices');  
end

if (issparse(im1))
  im1=full(im1);
end

if ( (length(size(im1))>1))
  im1=im1(:);
end

%% remove NaNs
if ~exist('im2')==1 %% otherwise could be different sizes
    im1 = im1(find(~isnan(im1)));
end

if (exist('im2') == 1)
  if ( (length(size(im2))>2))
    im2=im2(:);
  end

  difference = im1 - im2;
  [mn,mx] = range2(difference);
  myMean = mean(difference);
  v = var2(difference,myMean);
  if (v < realmin) 
    snr = Inf;
  else
    snr = 10 * log10(var2(im1)/v);
  end
  fprintf(1, 'Difference statistics:\n');
  fprintf(1, '  Range: [%.3e, %.3e]\n',mn,mx);
  %fprintf(1, '  Range: [%f.3, %f.3]\n',mn,mx);
  fprintf(1, '  Mean: %.3e,  Stdev (rmse): %.3e,  SNR (dB): %f\n',...
      myMean,sqrt(v),snr);
else
  [mn,mx] = range2(im1);
  myMean = mean(im1);
  var = var2(im1);  
  stdev = sqrt(real(var))+sqrt(imag(var));
  kurt = kurt2(im1, myMean, stdev^2);
  fprintf(1, 'Image statistics:\n');
  fprintf(1, '  Range: [%.3e, %.3e]\n',mn,mx);
  fprintf(1, '  Mean: %.3e,  Stdev: %.3e,  Kurtosis: %f\n',myMean,stdev,kurt);
end
