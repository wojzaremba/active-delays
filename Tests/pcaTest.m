function pcaTest()
    twiceTheSameResultTest();  
    whiteningTest();
    dimensionalityReductionTest();
    recoveryTest();
end

function recoveryTest() 
    sizex1 = 10;
    samples = 2;
    sizex3 = 100;
    visual = false;
    x = zeros(sizex1, samples, sizex3);
    x(:, 1:(samples/2), :) = randn(sizex1, samples/2, sizex3);
    x(:, (samples/2+1):end, :) = randn(sizex1, samples/2, sizex3) / 20;        
    [Q, ~] = qr(randn(samples));
    x = permute(x, [2, 1, 3]);
    x = x(:, :);    
    avg = mean(x, 2);
    x = x - repmat(avg, 1, size(x, 2));      
    x = Q * x;
    if visual, scatterplot(squeeze(x)');end;        
    x = reshape(x, [samples, sizex1, sizex3]);
    x = permute(x, [2, 1, 3]);    
    [xres, reconstruct] = pcaWhite(x, 1);
    xres = permute(xres, [2, 1, 3]);
    xres = xres(:, :);
    if visual, scatterplot(xres);end;   
    xres = reconstruct * xres;
    if visual, scatterplot(xres');end;
    xres = reshape(xres, [samples, sizex1, sizex3]);   
    xres = permute(xres, [2, 1, 3]);       
    assert((norm(xres(:)*std(x(:))/std(xres(:)) - x(:))/ norm(x(:))) < 0.1);
end

function twiceTheSameResultTest()
    x = randn(10, 10, 10);
    xres = pcaWhite(x, 8);
    xres2 = pcaWhite(xres, 8);
    %inner order of channels could change
    assertClose(norm(xres(:)), norm(xres2(:)));
end

function whiteningTest()
    x = zeros(4, 2, 1);
    x(1, :, 1) = [1, 0];
    x(2, :, 1) = [-1, 0];
    x(3, :, 1) = [0, 1];
    x(4, :, 1) = [0, -1];
    x = x * sqrt(2)/2;
    assertClose(x, pcaWhite(x, 2));
end

function dimensionalityReductionTest()
    x = zeros(8, 4, 1);
    x(1, :, 1) = [1, 0, 0, 0];
    x(2, :, 1) = [-1, 0, 0, 0];
    x(3, :, 1) = [0, 1, 0, 0];
    x(4, :, 1) = [0, -1, 0, 0];
    x(5, :, 1) = [0, 0, 1, 0] / 2;
    x(6, :, 1) = [0, 0, -1, 0] / 2;
    x(7, :, 1) = [0, 0, 0, 1] * 10;
    x(8, :, 1) = [0, 0, 0, -1] * 10;
    xret = zeros(8, 3, 1);
    xret(1, :, 1) = [0, 1, 0];
    xret(2, :, 1) = [0, -1, 0];
    xret(3, :, 1) = [0, 0, 1];
    xret(4, :, 1) = [0, 0, -1];
    xret(7, :, 1) = [1, 0, 0];
    xret(8, :, 1) = [-1, 0, 0];
    xret = xret * sqrt(2) / 2;
    assertClose(xret, pcaWhite(x, 3));
end
