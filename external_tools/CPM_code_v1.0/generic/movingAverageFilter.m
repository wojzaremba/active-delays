% function c = movingAverageFilter(x,span)
%
% span is the number of points to be averaged at each time

function smoothX = movingAverageFilter(x,span)

if (length(size(x))>2)
  error('only works on vectors');
elseif (min(size(x))~=1)
  error('only works on vectors');
end

N=length(x);

if span==1
    smoothX=x;
    return;
end

if span==N
    smoothX=mean(x)*ones(size(x));
end

%% normalized filter with equal weight everywhere
filt = ones(1,span)/span;

%% use 2D conv because it has the 'same' option
smoothX = conv2(filt,1,x','same');

return;


% figure,subplot(2,1,1),plot(smoothX); subplot(2,1,2),plot(x);