%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [neighR,neighC,neighInd] = getNeighbours(rr,cc,dims);
%% return set of neighbours that have already been analyzed
%% in the loop (and hence may have been assigned a peak

neighR=[]; neighC=[];
nxt=0;
for r=(rr-1):(rr+1)
    for c=(cc-1):(cc+1)
        if r>=1 && c>1
            nxt=nxt+1;
            neighR(nxt)=r;
            neighC(nxt)=c;
        end
    end
end

goodVal = neighR<=dims(1) & neighC<=dims(2);
neighR=neighR(find(goodVal));
neighC=neighC(find(goodVal));
neighInd = sub2ind(dims,neighR,neighC);

return;