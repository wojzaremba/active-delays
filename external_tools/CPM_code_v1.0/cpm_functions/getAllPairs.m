% function pairs = getAllPairs(vec)
%
% returns all possible pairs from the numbers in vec

function pairs = getAllPairs(vec)

howmany=length(vec);

numPairs = choose(howmany,2);
pairs=zeros(numPairs,2);
nxt=1;

for ii=1:howmany
  for jj=ii+1:howmany
    pairs(nxt,1:2)=[ii,jj];
    nxt=nxt+1;
  end
end
