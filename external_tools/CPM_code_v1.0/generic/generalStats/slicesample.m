function S = slicesample(N,burn,logdist, x, w, varargin)

% SLICESAMPLE(N,burn,logdist, X, w, varargin) --- draw N samples from distribution
% after discarding burn-in period using slice sampling. Starts at X. Step
% size(s) w.  'logdist' need not be normalised.
%
% Implemented by Iain Murray May 2004 from Pseudo-code in David MacKay's text
% book p375
%
% Could try computer friendly Skilling version, although perhaps I shouldn't be
% doing this in Matlab/Octave if I care at all about performance.
%
% June 3, 2006 - modified by Jennifer Listgarten to use varargin{:} 
% instead of userstruct - just pass as many variables as your
% function needs


% startup stuff
D=length(x);
S=zeros(D,N);
if isequal(size(w),[1,1])
	w=repmat(w,D,1);
end
lPx = feval(logdist, x, varargin{:});

% Main loop
for i=1:(N+burn)
	fprintf('Iteration %d                 \r',i-burn);
	luprime = log(rand)+lPx;
	
	% Setup stuff for sampling along random axis
	% (could do random direction, but this is simpler for now)
	d=ceil(rand*D);
	x_l = x;
	x_r = x;
	xprime = x;
	
	% Create a horizontal interval (x_l,x_r) enclosing x
	r=rand;
	x_l(d) = x(d)-r*w(d);
	x_r(d) = x(d)+(1-r)*w(d);
	% Typo in book. Book says compare to u, but it should say u'
	while (feval(logdist, x_l, varargin{:})>luprime)
		x_l(d)=x_l(d)-w(d);
	end
	while (feval(logdist, x_r, varargin{:})>luprime)
		x_r(d)=x_r(d)+w(d);
	end

	% Inner loop:
	% Propose xprimes and shrink interval until good one found
	z=0;
	while 1
		z=z+1;
		fprintf('Iteration %d   Step %d       \r',i-burn,z);
		xprime(d) = rand*(x_r(d)-x_l(d))+x_l(d);
		lPx = feval(logdist, xprime, varargin{:});
		if lPx>luprime
			break % this is only way to leave while loop
		else
			% Shrink in
			if xprime(d)>x(d)
				x_r(d)=xprime(d);
			else
				x_l(d)=xprime(d);
			end
		end
	end
	x=xprime;
	
	% Record samples
	if i>burn
		S(:,i-burn)=x;
	end
end

