function r = cumsum(x)

%% returns the cumulative sum of x from the first index
%% to the last

r = zeros(size(x));

r(1)=x(1);
for jj=2:length(r)
    r(jj)=r(jj-1) + x(jj);
end