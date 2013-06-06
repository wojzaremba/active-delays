dim=1;
xx=rand(1342,1342);
xx=[1 4 -Inf; 5 7 8];

% compile
mex /h/11/jenn/phd/MS/matlabCode/functions/MEX/logsumMEX.c

% call
xx=tempAlphaslog;
tic; mat_sum = logsum(xx,dim);toc;
tic; mex_sum = logsumFast(xx,dim); toc;

[a b]=find(~isnan(mat_sum));
[c d]=find(~isnan(mex_sum));

whos a b c d

imstats(mex_sum-mat_sum)


mat_sum
mex_sum


