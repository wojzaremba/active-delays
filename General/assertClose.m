function assertClose( a, b )
    c = a - b;
    normalizator = max(max(norm(a(:)), norm(b(:))), 10^-5);
    eps = 10^(-6);
    if (~(norm(c(:)) < normalizator*eps)) 
        writelnLog(-1, 'Assertion failed !(%.10f < %.10f)', norm(c(:)), eps)
        assert(false);
    end
    
end

