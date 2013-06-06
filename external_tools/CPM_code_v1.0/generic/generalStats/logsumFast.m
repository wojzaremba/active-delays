% function result = logsumFast(xx,dim)
% 
% fast version of logsum, but only works on 1 or 2 dimensional
% tables, not multi-dim. tables.


function result = logsumFast(xx,dim)

xdims=size(xx);

if (length(xdims)>2)
  error('Fast function does not work on multi-dim tables');
end

% mex function only works on dim=1
if (dim~=1)
  xx=permute(xx,[2,1]);
end

alphas = max(xx,[],1) - log(realmax)/2 + 2*log(xdims(1));
result = logsumMEX(xx,alphas);

% switch back
if (dim~=1)
  result=permute(result,[2,1]);
end
