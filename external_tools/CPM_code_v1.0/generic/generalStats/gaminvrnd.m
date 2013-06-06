% function x = gaminvrnd(A,B)
%
% Generate random samples from an inverse-gamma distribution, using
% Rubin notation.
%
% B_matlab = 1/B_rubin
%
% See also gamrnd, gamcdf, gamfit, gaminv, gamlike, gampdf, gamstat, random.

function x = gaminvrnd(A,B,M,N)

if exist('M','var')
    y = mygamrnd(A,B,M,N);
else
    y = mygamrnd(A,B); 
end
%% make it draw from the inverse
x = 1./y; 

return;

%%%%%
A=1.5; B=0.5;
if A>1
    temp = gaminvrnd(A,B,1e6,1);
    mean(temp)
    B./(A-1)
end

temp=mygamrnd(A,B,1e6,1);
mean(temp)
A/B
