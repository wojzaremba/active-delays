function newZ = collapseZ(z)

%% take the latent trace found when G.numBins>1
%% and simply sum out the bins so that it is sort of the
%% equivalent of a 1D latent trace

if length(size(z))==2
    newZ=z;
else
    newZ = sum(z,3);
end

return;