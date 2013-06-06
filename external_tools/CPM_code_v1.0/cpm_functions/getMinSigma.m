function minSigma = getMinSigma(data)

%error('This should depend on the number of samples');

for ii=1:length(data)
  mydiff(ii) = max(data{ii}) - min(data{ii});
end

minSigma = 0.05*max(mydiff);

%minSigma = minSigma*2/3;
%minSigma = minSigma*1/3;
%minSigma = minSigma*1/5;
minSigma = 0;

