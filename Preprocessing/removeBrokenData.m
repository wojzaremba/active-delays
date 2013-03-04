function [ XRet, YRet, channelsRet ] = removeBrokenData(X, Y, channels);
    Xchannels = permute(X, [2, 1, 3]);
    Xchannels = Xchannels(:, :);
    [~, order] = sort(std(Xchannels'));
    left = order(1:floor(0.9 * size(order, 2)));
    XFix = X(:, left, :);
    channelsRet = channels(left, :);
    [~, order2] = sort(std(XFix(:, :)'));
    left2 = order2(1:floor(0.9 * size(order2, 2)));
    XRet = XFix(left2, :, :);
    YRet = Y(left2);
end

