function icaTest()
    nondeterminismTest();
    reconstructionTest();
end

function reconstructionTest() 
    sizex1 = 10;
    sizex3 = 100;
    samples = 3;
    visual = false;
    xSum = [];
    for i = 1:2
        x = zeros(sizex1, samples, sizex3);
        x(:, 1, :) = randn(sizex1, 1, sizex3);
        x(:, 2, :) = randn(sizex1, 1, sizex3) / 20;          
        x(:, 3, :) = randn(sizex1, 1, sizex3) / 20;     
        [Q, ~] = qr(randn(samples));
        x = permute(x, [2, 1, 3]);
        x = x(:, :);    
        avg = mean(x, 2);
        x = x - repmat(avg, 1, size(x, 2));      
        x = Q * x;               
        x = reshape(x, [samples, sizex1, sizex3]);
        x = permute(x, [2, 1, 3]);      
        xSum = cat(1, xSum, x);        
    end    
    sizex1 = sizex1 * 2;
    x = xSum;
    xSum = permute(xSum, [2, 1, 3]);
    xSum = xSum(:, :);      
    if visual, scatter3(xSum(1, :), xSum(2, :), xSum(3, :));end;           
    [xpca, reconstruct] = pcaWhite(x, 2);
    [xica, icaweights, icasphere, icawinv] = ica(xpca);        
    xres = xica;
    xres = permute(xres, [2, 1, 3]);
    xres = xres(:, :);
    if visual, scatterplot(xres');end;   
    xres = reconstruct * icawinv * xres;
    if visual, scatter3(xres(1, :), xres(2, :), xres(3, :));end;
    xres = reshape(xres, [samples, sizex1, sizex3]);   
    xres = permute(xres, [2, 1, 3]);       
    assert((norm(xres(:)*std(x(:))/std(xres(:)) - x(:))/ norm(x(:))) < 0.1);       
end

function nondeterminismTest() 
    X = randn(5, 10, 15);
    [Xica1, icaweights1, icasphere1, icawinv1] = ica(X);
    [Xica2, icaweights2, icasphere2, icawinv2] = ica(X);
    assertClose(Xica1, Xica2);
    assertClose(icaweights1, icaweights2);
    assertClose(icasphere1, icasphere2);
    assertClose(icawinv1, icawinv2);
end
