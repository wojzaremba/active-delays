function printRunInfo(G,fidErr)

myPrint(fidErr,'======================');
myPrint(fidErr,'EM-CPM Run Information');
myPrint(fidErr,'======================');

msg=sprintf(['number of time series= %d'],G.numSamples);
myPrint(fidErr,msg);

msg=sprintf(['max number EM iterations= %d'],G.maxIter);
myPrint(fidErr,msg);

msg=sprintf(['EM log likelihood difference threshold= %.3e'],G.thresh);
myPrint(fidErr,msg);

msg=sprintf(['length of each time series= %d'],G.numRealTimes);
myPrint(fidErr,msg);

msg=sprintf(['number of bins (time series dimensionality)= %d'],G.numBins);
myPrint(fidErr,msg);

msg=sprintf(['number of HMM time states= %d'],G.numTaus);
myPrint(fidErr,msg);

msg=sprintf(['number of HMM scale states= %d'],G.numScales);
myPrint(fidErr,msg);

msg=sprintf(['total number HMM states= %d'],G.numStates);
myPrint(fidErr,msg);

msg=sprintf(['Use scaling spline = %d'],G.USE_CPM2);
myPrint(fidErr,msg);

if G.USE_CPM2
    msg=sprintf(['# scaling spline control point= %d'],G.numCtrlPts);
    myPrint(fidErr,msg);
end

myPrint(fidErr,'----------------------');

msg=sprintf(['Learn HMM emission variance= %d'],G.updateSigma);
myPrint(fidErr,msg);

msg=sprintf(['Learn latent trace= %d'],G.updateZ);
myPrint(fidErr,msg);

msg=sprintf(['Learn scale transitions probabilities= %d'],G.updateScale);
myPrint(fidErr,msg);

msg=sprintf(['Learn time transitions probabilities= %d'],G.updateTime);
myPrint(fidErr,msg);

msg=sprintf(['Learn scaling parameter(s)= %d'],G.updateU);
myPrint(fidErr,msg);

myPrint(fidErr,'----------------------');


msg=sprintf(['lambda (smoothing penalty)= %.3e'],G.lambda);
myPrint(fidErr,msg);

msg=sprintf(['nu (inter-class penalty)= %.3e'],G.nu);
myPrint(fidErr,msg);

msg=sprintf(['number of classes= %d'],G.numClass);
myPrint(fidErr,msg);


myPrint(fidErr,'======================');
myPrint(fidErr,'');

return;
