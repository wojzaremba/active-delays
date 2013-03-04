function derivativeTest( )
    simpleTest();
    sharpnesTest();
    sharpnesSinTest();
end

function simpleTest()
    componentsNr = 60;
    sampleNr = 10;
    X = ones(sampleNr, componentsNr, 30);
    Y = ones(sampleNr, 1);
    Y((floor(sampleNr / 2) + 2):end) = -1;
    H = zeros(sampleNr, 1);
    component = 5;
    firsts = 10;
    len = 10;
    % zero test
    assertClose(getSumOfSquareDerivatives( X, Y, H, component, firsts, len ), 0);   
    
    X = randn(10, componentsNr, 30);
    % affine invariance
    assertClose(getSumOfSquareDerivatives( X, Y, H, component, firsts, len ), getSumOfSquareDerivatives( 5 * X + 123, Y, H, component, firsts, len ));           
    
    for i = 1:3
        X = randn(10, componentsNr, 30);
        % possitivity
        assert(getSumOfSquareDerivatives( X, Y, H, component, firsts, len ) > 0);                   
    end
end

function sharpnesTest()
    load([getenv('data_path'), 'processed08_ica.mat'], 'channels');    
    for a = 1:5
        X = zeros(size(channels, 1), 1);
        for channel = 1:size(channels, 1)
            x = channels(channel, 1);
            y = channels(channel, 1);
            X(channel, 1) = x + a * y;
        end
        res{a} = getSumOfSquareDerivatives_( X , 1, 1);
    end
    for k = 2:5
        assertClose((res{k}-res{1}) / (res{2} - res{1}), k-1);
    end
end

function sharpnesSinTest()
    load([getenv('data_path'), 'processed08_ica.mat'], 'channels');    
    for a = 1:5
        X = zeros(size(channels, 1), 1);
        for channel = 1:size(channels, 1)
            x = channels(channel, 1);
            y = channels(channel, 1);
            X(channel, 1) = sin( a * (x + y));
        end
        res{a} = getSumOfSquareDerivatives_( X , 1, 1);
    end
    for i = 1:5
        for j = (i+1):5
            assert( res{j} > res{i} );
        end
    end
end