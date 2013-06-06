function [tempTp sMinus sPlus] = getTimePts(G,pt)

tempTp = G.timePts{pt};
sMinus = G.sMinus{pt};
sPlus = G.sPlus{pt};
