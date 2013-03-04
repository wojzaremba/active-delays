function [ derivative ] = getSumOfSquareDerivatives_( data, firsts, len )
	load([getenv('data_path'), 'processed08_ica.mat'], 'channels');
    quality = 0.010;

    xrange = -1.05:quality:1.05;
    yrange = -0.8:quality:0.95;
    
    sizegauss = quality * 6;
    xrangeconv = -sizegauss:quality:sizegauss;
    yrangeconv = -sizegauss:quality:sizegauss;

    xrangeall = repmat(xrange, size(yrange, 2), 1)';
    yrangeall = repmat(yrange, size(xrange, 2), 1);

    xrangeallconv = repmat(xrangeconv, size(yrangeconv, 2), 1)';
    yrangeallconv = repmat(yrangeconv, size(xrangeconv, 2), 1);

    derivative = 0;
    c = sizegauss/4;
    gaussx = xrangeallconv .* exp((-xrangeallconv.^2 - yrangeallconv.^2)/(2*(c^2)))*quality^3 / c^4;
    gaussy = yrangeallconv .* exp((-xrangeallconv.^2 - yrangeallconv.^2)/(2*(c^2)))*quality^3 / c^4;
    for i = 1:len
        F = TriScatteredInterp(channels(:, 1),channels(:, 2), data(:, firsts + i - 1));

        tab{i} = F(xrangeall, yrangeall);
        convx = (conv2(tab{i}, gaussx)) .^ 2;
        convy = (conv2(tab{i}, gaussy)) .^ 2;

        tmp = convx + convy;
        tmp(isnan(tmp)) = 0;

        derivative = derivative + sum(tmp(:));% * 1 /(4 * pi^2)
    end
    % 10^9 is just a constant to make results more readable.
    derivative = sqrt(derivative) * 10^9;

end

