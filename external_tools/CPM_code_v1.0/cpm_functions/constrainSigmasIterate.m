function newSigmas= constrainSigmasIterate(G,proposedSigmas,origSigs)

notConverge=1;
thresh=1e-3;

maxIt=500;
it=0;
%newSigmas=G.sigmas; %% won't work if each bin has its own
newSigmas=origSigs;
while notConverge
    it=it+1;
    oldSigmas=newSigmas;
    
    %newSigmas'
    %keyboard;
    
    newSigmas = constrainSigmas(G,oldSigmas,proposedSigmas);
    
    if any(isinf(newSigmas))
        it
        newSigmas
        keyboard;
    end
   
    relDiff = abs(newSigmas-oldSigmas)./newSigmas;
          
    if all(relDiff<thresh)
        notConverge=0;
    end
    
    if it==maxIt
        relDiff
        oldSigmas
        newSigmas'        
        keyboard;
    end
end

