% function ubar = getUbar(G)
%
% returns mean(u_k^2) for each class

function ubar = getUbar(G)

if G.useBalancedPenalty
  ubar=zeros(1,G.numClass);

  for cc=1:G.numClass
    tmpInd = G.class{cc};
    ubar(cc)=sum(G.u(tmpInd).^2)/length(tmpInd);
  end
  
else
  ubar=ones(1,G.numClass);
end
