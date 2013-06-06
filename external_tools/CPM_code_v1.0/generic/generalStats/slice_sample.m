% function x=slice_sample(logdist,xinit,L,R,W,N,MODE,maxsearch,varargin)
%
%Description
%-------------------
%Use slice sampling to generate samples from any distribution over
%a one dimensional space where the initial interval [l,r] is known.
%Takes a one parameter function computing the log of the distribution,
%or any function computing the log of a function proportional to the
%distribution. Additional parameters and constants can be passed in
%using the params structure.
%
% Jenn says:  looks like w is the estimate of a typical slice size,
%             (i.e. in following Radford's notes)
%
%Syntax: x=slice_sample(logdist,params,xinit,l,r,n)
%--------------------
%* logdist: a function handle for a function computing the log of a distribution of
%           one parameter.
%* params:  a structure of paramaeters and constants needed by logdist
%* xinit:   initial point to start sampling from
%* L:       the lower bound of the sampling interval
%* R:       the upper bound of the sampling interval
%* N:       the number of samples to draw  
%* MODE:    0 - perform shrinkage on the given interval
%           1 - perform stepping out then shrinkage
%*          2 - perform doubling then shrinkage
%
% Written by Ben Marlin @ University of Toronto.  Please acknowledge any
% use of this code.
% Modified by Jennifer Listgarten, June 3, 2006 to use varargin with the
% logdist function call rather than 'params'
% Jenn comment:  L/R define the boundaries of the domain to make
% sure we don't go out of them (I think).

function x=slice_sample(logdist,xinit,L,R,W,N,MODE,maxsearch,varargin)

%declare space for samples
x = zeros(1,N);
x(1) = xinit;

%maximum times to expand or shrink the interval
%maxsearch=10;

%sample n points from the distribution
for i=2:(N+1)
  %pick the slice level from a uniform density under the log posterior curve
  logprob_old = feval(logdist,x(i-1),varargin{:});
  if(isnan(logprob_old)); error('Slice Error: logdist returned NaN');end;
  if(isinf(logprob_old) && logprob_old>0); error('Slice Error: logdist returned Inf');end;
  z = logprob_old-exprnd(1);

  %Determine the interval
  if(MODE==0) %shrinkage on the given interval
    l=L;r=R;
  elseif(MODE==1) %stepping out
    c = rand(1);
    l=x(i-1)-c*W; if l <= L, l = L+eps; end
    r=l+W; if r >= R, r = R-eps; end

    logprobl = feval(logdist, l, varargin{:});
    if(isnan(logprobl)); error('Slice Error: logdist returned NaN'); end;
    j=0;
    while (logprobl > z && j<maxsearch)
      l=l-W; if l <= L, l = L+eps; break; end
      logprobl = feval(logdist, l, varargin{:});
      if(isnan(logprobl)); error('Slice Error: logdist returned NaN');end;
      j=j+1;
    end;

    logprobr = feval(logdist, r, varargin{:});
    if(isnan(logprobr)); error('Slice Error: logdist returned NaN');end;
    j=0;
    while (logprobr > z && j<maxsearch)
      r=r+W; if r >= R, r = R-eps;break; end
      logprobr = feval(logdist, r, varargin{:});
      if(isnan(logprobr)); error('Slice Error: logdist returned NaN');end;
      j=j+1;
    end

  elseif(MODE==2) %doubling
    c = rand(1);
    l=x(i-1)-c*W; if l < L+eps, l = L+eps; end
    r=l+W; if r > R, r = R-eps; end

    logprobl = feval(logdist, l, varargin{:});
    if(isnan(logprobl)); error('Slice Error: logdist returned NaN'); end;
    logprobr = feval(logdist, r, varargin{:});
    if(isnan(logprobr)); error('Slice Error: logdist returned NaN'); end;
    j=0;
    while (j<maxsearch && (logprobl > z || logprobr > z) && (abs(r-R)>2*eps || abs(l-L)>2*eps ))
      c=rand(1);
      j=j+1;
      if( (c<0.5 || R==r) && l>L)
        l = l - (r-l);
        if (l<=L); l=L+eps; end
        logprobl = feval(logdist, l, varargin{:});
        if(isnan(logprobl)); error('Slice Error: logdist returned NaN'); end;
      elseif( (c>=0.5 || L==l) && r<R)
        r = r + (r-l);
        if(r>=R);r=R-eps;end;
        logprobr = feval(logdist, r, varargin{:});
        if(isnan(logprobr)); error('Slice Error: logdist returned NaN'); end;
      end
    end
    [l r];
  end

  db=j;

  %shrink until we draw a good sample
  j=0;
  x(i)=0;  %% this line added by Jenn
  while(j<maxsearch)
    j=j+1;
    %randomly sample a new alpha on the interval
    x_new = l + rand(1)*(r-l);

    %compute the log posterior probability for the new alpha
    %any function proportional to the true posterior is fine
    logprob  = feval(logdist,x_new,varargin{:});
    if(isnan(logprob)); error('Slice Error: logdist returned NaN'); end;

    %Accept the sample if the log probability lies above z
    if (logprob>z || abs(r-l)<eps);
      x(i) = x_new;
      break
    else
      %If not, shrink the interval
      if (x_new<x(i-1))
         l = x_new;
      else
         r = x_new;
      end
    end
   end
   %check to see if a new value was assigned.
   %if not assign the previous value and we try again.
   if(x(i)==0 && j==maxsearch)
     x(i) = x(i-1);
   end
   
   [db j];

end

return
