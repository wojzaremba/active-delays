function pattern = getJacobPattern(G)

pattern = sparse(G.numTaus,G.numClass);

for cc=1:G.numClass
  for jj=1:G.numTaus
    myInd = (cc-1)*G.numTaus + jj;
    fullInd=[myInd];
    if (jj>1)
      fullInd = [fullInd myInd-1];
    end
    if (jj<G.numTaus)
      fullInd = [fullInd myInd+1];
    end
    moreInd = ((1:G.numClass)-1)*G.numTaus +jj;
    fullInd = [fullInd, moreInd];
    pattern(myInd,fullInd)=1;
  end
end

return;

spy(pattern);
