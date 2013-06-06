%% function d=getSquaredDist(t,r)
%%
%% distance function used with DTW function such as dp.m dp2.m and dpJenn.m
%%
%% assumes that t and r have dimension: [length x numDims]
%% the squared distance is the sum of the squared differences across
%% all dimensions at one time point

function x=getSquaredDist(t,r)

%% CHANGES BY JENN:
[N D]=size(t); 
[M D]=size(r);
x=zeros(N,M);

%% accumulate over each dimension
for d=1:D
    x = x + (repmat(t(:,d),1,M)-repmat(r(:,d)',N,1)).^2;
end
x=x/D;

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% original code that I got from web

[rows,N]=size(t); 
[rows,M]=size(r);

%for n=1:N
%    for m=1:M
%        d(n,m)=(t(n)-r(m))^2;
%    end
%end

%this replaces the nested for loops from above Thanks Georg Schmitz 
d=(repmat(t(:),1,M)-repmat(r(:)',N,1)).^2;