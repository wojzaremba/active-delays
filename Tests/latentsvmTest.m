function latentsvmTest()
    commonSVMSimpleTest();
    commonSVMSymmetryCTest();
    latentSVMCommonTest();
    latentSVMBiggerGapTest();
    latentSVMTogetherTest();
    latentSVMTogetherComplexTest();
    latentSVMdeterminismTest();
    latentSVMSwitchComponentsTest();
    latentSVMsameComponentTest();
end


function commonSVMSimpleTest() 
    X = zeros(4, 1, 2);
    X(1, 1, :) = [0, 1];
    X(2, 1, :) = [1, 1];
    X(3, 1, :) = [1, 0];
    X(4, 1, :) = [1, -1];
    Y = [1, 1, -1, -1]';
    firsts = 1;
    len = 2;
    windowSize = 0;
    C = 100000;
    [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
    assertClose(squeeze(model), [-0.5, 1]');  
end

function commonSVMSymmetryCTest() 
    X = zeros(2, 1, 2);
    X(1, 1, :) = [0, 1];
    X(2, 1, :) = [1, 0];
    Y = [1, -1]';
    firsts = 1;
    len = 2;
    windowSize = 0;
    for C = 2.^(-3:5)
        [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
        assertClose([1, 1] * squeeze(model), 0);  
    end
end

function latentSVMCommonTest() 
    X = zeros(4, 1, 6);
    X(1, 1, :) = [0, 0, 1, -1, 0, 0];
    X(2, 1, :) = [0, 1, -1, 0, 0, 0];
    X(3, 1, :) = [0, 0, -1, 1, 0, 0];
    X(4, 1, :) = [0, 0, 0, -1, 1, 0];
    Y = [1, 1, -1, -1]';
    firsts = 3;
    len = 2;    
    C = 10;
    windowSize = 1;
    [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
    assertClose(squeeze(model), [1, -1]');  
    assert(latentsvmClassify(model, X, Y, firsts, len, windowSize) == 1);
    
    windowSize = 0;
    [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
    assertClose(squeeze(model), [1, -1]'/4);  
    assert(latentsvmClassify(model, X, Y, firsts, len, windowSize) ~= 1);
end

function latentSVMBiggerGapTest() 
    X = zeros(6, 1, 10);
    X(1, 1, :) = [0, 0, 0, 0, 1, -1, 0, 0, 0, 0];
    X(2, 1, :) = [0, 0, 0, 1, -1, 0, 0, 0, 0, 0];
    X(3, 1, :) = [0, 0, 1, -1, 0, 0, 0, 0, 0, 0];
    X(4, 1, :) = [0, 0, 0, 0, 0, 1, -1, 0, 0, 0];
    X(5, 1, :) = [0, 0, 0, 0, 0, 0, 1, -1, 0, 0];    
    X(6, 1, :) = [0, 0, 0, 0, -1, 1, 0, 0, 0, 0];
    X(7, 1, :) = [0, 0, 0, 0, 0, -1, 1, 0, 0, 0];
    X(8, 1, :) = [0, 0, 0, 0, 0, 0, -1, 1, 0, 0];
    X(9, 1, :) = [0, 0, 0, -1, 1, 0, 0, 0, 0, 0];
    X(10, 1, :) = [0, 0, -1, 1, 0, 0, 0, 0, 0, 0]; 
    Y = [1, 1, 1, 1, 1, -1, -1, -1, -1, -1]';
    firsts = 5;
    len = 2;
    C = 10;    
    for windowSize=0:1    
        [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
        assert(latentsvmClassify(model, X, Y, firsts, len, windowSize) ~= 1);
    end
    
    for windowSize=2:3
        [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
        assert(latentsvmClassify(model, X, Y, firsts, len, windowSize) == 1);    
    end
end


function latentSVMTogetherTest() 
    X = zeros(2, 2, 6);
    X(1, 1, :) = [0, 0, 0, -1, 0, 0];
    X(1, 2, :) = [0, 0, 1, -1, 0, 0];
    X(2, 1, :) = [0, 0, -1, 0, 0, 0];
    X(2, 2, :) = [0, 0, 1, -1, 0, 0];    
    Y = [1, -1]';    
    len = 3;
    C = 10000;    
    windowSize = 1;
    firsts = [2, 2];
    [ ~, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
    %lack of convergence bug
    assert(true); 
end

function latentSVMTogetherComplexTest() 
    X = zeros(2, 2, 6);
    X(1, 1, :) = [0, 0, 1, 0, -1, 0];
    X(1, 2, :) = [0, 0, 1, -1, 0, 0];

    X(2, 1, :) = [0, 1, 0, -1, 0, 0];
    X(2, 2, :) = [0, 1, -1, 0, 0, 0];    
    
    X(3, 1, :) = [0, 1, 0, -1, 0, 0];
    X(3, 2, :) = [0, 0, 1, -1, 0, 0];    

    X(4, 1, :) = [0, 0, 1, 0, -1, 0];
    X(4, 2, :) = [0, 0, 0, 1, -1, 0];      
    
    Y = [1, 1, -1, -1]';
    
    len = 3;
    C = 10000;    
    firsts = 2;
    for windowSize = 0:1
        for component = 1:2
            [ model, ~ ] = latentsvmTrain( X(:, component, :), Y, firsts, len, windowSize, C );
            assert(latentsvmClassify(model, X(:, component, :), Y, firsts, len, windowSize) ~= 1);
        end
    end
    windowSize = 1;
    firsts = [2, 2];
    [ model, ~ ] = latentsvmTrain( X, Y, firsts, len, windowSize, C );
    assert(latentsvmClassify(model, X, Y, firsts, len, windowSize) == 1);    
end

function latentSVMdeterminismTest()
    X = randn(6, 2, 15);
    Y = [1, 1, 1, -1, -1, -1]';
    [model1, H1] = latentsvmTrain(X, Y, [5, 7], 5, 3, 1);
    [model2, H2] = latentsvmTrain(X, Y, [5, 7], 5, 3, 1);
    assertClose(model1, model2);
    assertClose(H1, H2);
end

function latentSVMSwitchComponentsTest()
    rng('default');
    X = randn(6, 2, 15);
    Y = [1, 1, 1, -1, -1, -1]';
    len = 3;
    [model1, H1] = latentsvmTrain(X, Y, [7, 5], len, 3, 1);    
    X2 = zeros(size(X));
    X2(:, 1, :) = X(:, 2, :);
    X2(:, 2, :) = X(:, 1, :);
    [model2, H2] = latentsvmTrain(X2, Y, [5, 7], len, 3, 1);
    assertClose(H2, H1);
    tmp = reshape(model2, [2, len]);
    tmp = [tmp(2, :); tmp(1, :)];
    assertClose(tmp(:), model1);
end

function latentSVMsameComponentTest()
    rng('default');
    X = randn(6, 2, 15);
    X(:, 2, :) = X(:, 1, :);
    Y = [1, 1, 1, -1, -1, -1]';
    len = 3;
    [model1, H1] = latentsvmTrain(X, Y, [5, 5], len, 3, 1);   
    [model2, H2] = latentsvmTrain(X(:, 1, :), Y, 5, len, 3, 2);   
    assertClose(H1, H2);
    assertClose(model1(1:2:end), model2 / 2);
end