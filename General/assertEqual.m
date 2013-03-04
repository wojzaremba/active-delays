function assertClose( a, b )
    c = a - b;
    assert(norm(c(:)) == 0);
end

