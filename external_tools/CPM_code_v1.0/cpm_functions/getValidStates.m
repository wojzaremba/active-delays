%function [allValidStates, scaleFacs,scaleFacsSq] =
%                                                  getValidStates(G)
%
% for each possible time state jj, compute the states that have this
% as a time states.  
% Also, for each of these 'valid states', compute the
% corresponding value of the scale state, and this value squared.


function [allValidStates, scaleFacs,scaleFacsSq] = getValidStates(G)

allValidStates = cell(1,G.numTaus);
scaleFacs = cell(1,G.numTaus);
scaleFacsSq = cell(1,G.numTaus);

for jj=1:G.numTaus
  allValidStates{jj} = find(G.stateToScaleTau(:,2)==jj);
  scaleFacs{jj} = 2.^(G.scales(G.stateToScaleTau(allValidStates{jj},1)));
  scaleFacsSq{jj} = scaleFacs{jj}.*scaleFacs{jj};
end

