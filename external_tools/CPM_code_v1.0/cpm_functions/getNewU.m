function newU = getNewU(G,gammaSum3,gammaSum4,...
    gammaSum5,gammaSum6,scalesExp)

if ~G.USE_CPM2
    newU = getNewUSimple(G,gammaSum3,gammaSum4,...
        gammaSum5,gammaSum6,scalesExp);
else
    newU = getNewUCPM2(G,gammaSum3,gammaSum4,...
        gammaSum5,gammaSum6,scalesExp);
end