% function pDistance = dist2pDist(d)

%% converts a distance matrix into the form output
%% by pDist and required by linkage

%% "distances are arranged in the order of 
%% ((1,2),(1,3),..., (1,N), (2,3),...(2,N),.....(N-1,N)), 
%% i.e. the lower left triangle of the full
%%    N-by-N distance matrix in column order."

function pDistance = dist2pDist(d)

numRow = size(d,1);
pDistance = zeros(1,numRow*(numRow-1)/2);


nxt=1;
for ft=1:numRow    
    for sc=(ft+1):numRow
        pDistance(nxt)=d(ft,sc);
        nxt=nxt+1;
    end
end
