function myMuTemp = getMyMuTemp(G,sampleNum,latentTrace)

states = 1:G.numStates;

myMuTemp =  G.traceLogConstant(states,:).*...
    latentTrace(G.stateToScaleTau(states,2),:);

return;




%% THIS USED TO BE LIKE THIS -- PROBABLY IT WAS FINE FOR EM-BASED VERSION
%% NOW I'm doing the HB-CPM though, and found this redundancy which I
%% am removing

thisClass = getClass(G,sampleNum);

myMuTemp =  G.traceLogConstant(states,:).*...
    permute(G.z(G.stateToScaleTau(states,2),thisClass,:),[1 3 2]);
