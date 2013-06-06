% function stateTrans = getStateTrans(G)
%
% Creates a sparse transition matrix, using the scale
% and time transition matrixes that are provided in G.

function allStateTrans = getStateTrans(G)

%% MAKE SURE TO UPDATE timeTransLog first!!!

for ss=1:G.numSamples
  stateTrans = G.stateTransLog{ss};
  [ii,jj,vals] = find(G.stateTransLog{ss});
  stateTrans(find(G.stateTransLog{ss}))=exp(vals);
  allStateTrans{ss}=stateTrans;
end

return;


