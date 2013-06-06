% function p = invGammaPdf(x,a,b)
%
% inv-gamma pdf for parameters, a,b, using the Rubin book parameterization
% (which I believe is different than what Matlab uses, for, gampdf, for
% example)
%
% this function works like the Matlab (which, compared to Rubin,
% uses b_matlab=1/b_rubin), 

function p = invGammaPdf(x,a,b)

% flip b to get Matlab consistency
b=1./b;

if a<=0 || b<=0 %|| any(x<=0)
   warning('error');
   keyboard;
end

%% may occasionally get get a negative value of x if using MH
%% with gaussian proposal distribution, so just give these a value of eps
x(find(x<=0))=eps;

%% this formula is not stable numerically
%p =  (b.^a/gamma(a)).*x.^(-a-1).*exp(-b./x);
d = a.*log(b) - gammaln(a) + (-a-1).*log(x);
p = exp(d);

if any(isnan(p))
    if any(isnan(b.^a))
        keyboard;
    elseif any(isnan(b.^a/gamma(a)))
        keyboard;
    elseif any(isnan(x.^(-a-1)))
        keyboard;
    elseif any(isnan(exp(-b./x)))
        keyboard;
    elseif any(isnan((b.^a/gamma(a)).*x.^(-a-1)))
        badInd = find(isnan((b.^a/gamma(a)).*x.^(-a-1)));
        jj=badInd(1);
        x(1)^(-a-1)
        tt=a*log(b) - gammaln(a) + (-a-1)*log(x);
        figure,plot(sort(tt));
        uu=exp(tt);
        figure,plot(sort(uu));
        keyboard;
    elseif any(isnan(x.^(-a-1).*exp(-b./x)));
        keyboard;
    else        
        keyboard;
    end
end