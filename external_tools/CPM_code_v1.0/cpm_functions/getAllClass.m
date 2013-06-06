function allClass = getAllClass(G)

allClass = zeros(1,G.numSamples);
for ss=1:G.numSamples
  allClass(ss)=getClass(G,ss);
end
