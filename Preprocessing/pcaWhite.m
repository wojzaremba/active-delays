function [ xoutput, pca_reconstruct ] = pcaWhite( xInput, npca )
    x = permute(xInput, [2, 1, 3]);
    x = x(:, :);
    
    avg = mean(x, 2);
    x = x - repmat(avg, 1, size(x, 2));
    sigma = x * x';
    
    rng('default');
    [U, S, ~] = svd(sigma);
        
    diagS = diag(S);
    epsilon = median(diagS) / 100;    
    diagS(diagS < epsilon) = diagS(diagS < epsilon) + epsilon;
    cutDiagInv = zeros(npca, size(diagS, 1));
    cutDiagInv(1:npca, 1:npca) = diag(1./sqrt(diagS(1:npca)));    
    xPCAwhite = cutDiagInv * U(:,:)' * x;
    
    xoutput = reshape(xPCAwhite, npca, size(xInput, 1), size(xInput, 3));
    xoutput = permute(xoutput, [2, 1, 3]);
   
    cutDiag = zeros(size(diagS, 1), npca);
    cutDiag(1:npca, 1:npca) = diag(sqrt(diagS(1:npca)));  
    
    pca_reconstruct = U(:,:) * cutDiag;
    
    writeLog(0, 'Performing data whitening with PCA\n');
end

