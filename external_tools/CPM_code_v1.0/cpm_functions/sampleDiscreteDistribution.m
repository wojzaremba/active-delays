% function ind = sampleDiscreteDistribution(x)
%
% given a 1D discrete probability distribution, x, 
% take a sample from it


function ind = sampleDiscreteDistribution(xx)

if (issparse(xx))
  xx=full(xx);
end

if (min(size(xx))>1)
  error('x should be 1d');
end

if (sum(xx)==0)
  ind=0;
  return;
end

%normalize x in case it isn't
x = xx./sum(xx);

if (sum(x)-1>100*eps)
  warning('sum should equal 1'); keyboard;
end

%generate random number uniformly between 0 and 1:
randNum = rand;

%form cumulative distribution
cumDistrib = cumsum(x);

ind = min(find(cumDistrib>=randNum));

if (isempty(ind)|ind<1)
  warning('ind<1'); keyboard;
  ind=0;
end

