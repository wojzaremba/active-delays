function p=igampdf(x,a,b)

% evaluates the pdf of a inverse gamma distribution,
% using the scale factor (b)
% as matlab uses it for the gamma distribution
% Vasco Curdia and Daria Finocchiaro
% Created on March 10, 2004

p= b.^(-a) * x.^(-(a+1)) .* exp(-1./(b*x))/gamma(a);
