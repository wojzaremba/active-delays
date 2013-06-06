% function newS = getNewS(G,scaleCounts)


function newS = getNewS(G,newScaleCounts)

C = size(newScaleCounts,2);


%display('in getNews'); keyboard;

for cc=1:C
  tempSum0 = newScaleCounts(1,cc);
  tempSum1 = newScaleCounts(2,cc);
  newS(:,cc)=(tempSum0+G.pseudoS(1))/(tempSum1+tempSum0+sum(G.pseudoS));
end
