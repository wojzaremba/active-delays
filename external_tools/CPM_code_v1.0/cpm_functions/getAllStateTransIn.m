function precursors = getAllStateTransIn(G)

precursors = cell(1,G.numStates);

for st=1:G.numStates
  [thisScale,thisTau]=find(G.stMap==st);
  [precStates, precTaus, precScales] = getStateTransIn(thisScale,thisTau,G);
  temp = zeros(length(precStates),3);
  temp(:,1) =precStates;
  temp(:,2) =precTaus;
  temp(:,3) =precScales;
  precursors{st}=temp;
end

