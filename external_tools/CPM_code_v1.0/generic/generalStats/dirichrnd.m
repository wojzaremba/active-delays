function r = dirichrnd(p,k)

% function r = dirichrnd(p,k)
%
% generate a random sample from a dirichlet distribution, with
% dimentionality vector of parameters (of length n), p.
%
% k (default k=1) is the number of samples returned
%
% Depends on 'gamrnd' in the stats toolbox
%
% Author: Jennifer Listgarten, Aug 12, 2005.

if ~exist('k')
    k=1;
end

n=length(p);
g=zeros(n,k); %store temporary gamma samples

for dim=1:n
    g(dim,:) = gamrnd(p(dim)*ones(1,k),1);
end    

counts = sum(g,1);
countsRep = repmat(counts,[n 1]);

r=g./countsRep;

return;


