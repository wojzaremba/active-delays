function [ derivative ] = getSumOfSquareDerivatives( Xin, Y, H, component, firsts, len )    
    load([getenv('data_path'), 'processed08_ica.mat'], 'icawinv', 'pca_reconstruct');
    last = firsts + len - 1;
    X = zeros(size(Xin, 1), size(Xin, 2), size(Xin, 3));   
    for i = 1:size(Xin, 1)
        h = H(i);
        X(i, component, firsts:last) = Xin(i, component, (firsts + h):(last + h));
    end     
    oneClassAmount = min(sum(Y == 1), sum(Y == -1));
    oneClass1 = find(Y == 1);
    oneClass2 = find(Y == -1); 
    tmp = X(:, component, firsts:last);
    X(:, component, firsts:last) = X(:, component, firsts:last) - mean(tmp(:));
    X(:, component, firsts:last) = X(:, component, firsts:last) ./ std(tmp(:));
    % makes number of elements in both classes equal and negate one class.
    X = cat(1, -X(oneClass1(1:oneClassAmount), :, :), X(oneClass2(1:oneClassAmount), :, :));

    tmp = permute(X, [2, 1, 3]);    
    data = pca_reconstruct * icawinv * tmp(:, :);
    data = reshape(data, [size(data, 1), size(X, 1), size(X, 3)]);
    data = permute(data, [2, 1, 3]);
    data = squeeze(mean(data, 1));
    
    derivative = getSumOfSquareDerivatives_(data, firsts, len);     
    writelnLog(2, 'returning square derivative value %f', derivative);
end

