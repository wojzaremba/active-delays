% function x = mygamrnd(A,B,M,N)
%
% Generate random samples from a gamma distribution
% using Rubin notation
%
% Matlab parameterization relates to Rubin notation as follows:
% uses b_matlab = 1/B_rubin
%
% Expectation(gaminvrnd) = B/(A-1)
% 
% See also gaminvrnd gamrnd, gamcdf, gamfit, gaminv, gamlike, gampdf, gamstat, random.

function y = mygamrnd(A,B,M,N)

%% to make it match Rubin book and standard notation
B=1/B;

if exist('M','var')
    y = gamrnd(A,B,M,N);
else
    y = gamrnd(A,B); %expectation(y)=A*B
end

return;
