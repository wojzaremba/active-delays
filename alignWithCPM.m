function Xaligned = alignWithCPM(X)
    X = squeeze(X);
    setenv('log_level', '1');
    USE_SPLINE = 1;
    oneScaleOnly = 1;
    maxIter = 1;
    numCtrlPts = 10;
    extraPercent = 0.05;
    learnGlobalScaleFactor = 1;
    lambda = 0;
    nu = 0;
    myThresh=10^-5; 
    learnStateTransitions=0;
    learnEmissionNoise=1; 
    learnLatentTrace=0;  
    saveDir = [];
    saveName = [];
    initLatentTrace=[];   
    classesTrain = {}; 
    
    classesTrain{1} = 1:size(X, 1);        
    [result ~, ~ , ~] = trainTestEMCPM(...
        X(:, :), 1:size(X, 1),[],classesTrain,[],...
        USE_SPLINE,oneScaleOnly,maxIter,numCtrlPts,extraPercent,...
        lambda,nu,myThresh, learnStateTransitions,learnGlobalScaleFactor,...
        learnEmissionNoise,learnLatentTrace,saveDir,saveName,initLatentTrace);
    % trainTestEMCPM produces twice as long response as output. We just choose every second value to shirk it.    
    Xaligned = reshape(result{1}.uMat(:, 5:2:(end-5)), [size(X, 1), 1, size(X, 2)]);
end