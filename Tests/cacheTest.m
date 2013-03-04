function cacheTest()    
    modSimpleTest();
    modNarrowTest();
    modTest();
    keyTest();
    descriptionSizeSingleTest();
    descriptionSizeTest();
    ensureCacheFileindexTest();
    cacheIdxTest();
    cacheIdxInclusionTest();
    cacheIdxChangeOrderStructTest();
    cacheIdxIntersectionTest();   
    cacheSameNumberOfElementsTest()
end



function cacheSameNumberOfElementsTest()
    cacheName = 'test';
    removeCache(cacheName);
    while(true)
        idx = getCacheIndex(struct('aaa', 10:11, 'bbb', -1:1, 'ccc', 60:61), cacheName);  
        if (idx.done), break;end
        updateCache(idx, struct('something', idx));
    end
	count = 0;
    while(true)
        idx = getCacheIndex(struct('aaa', 10:11, 'bbb', 0:2, 'ccc', 60:61), cacheName);  
        if (idx.done), break;end
        assert(idx.aaa <= 11);
        assert(idx.bbb == 2);
        assert(idx.ccc <= 61);
        assert(idx.aaa >= 10);
        assert(idx.ccc >= 60);        
        count = count + 1;
        updateCache(idx, struct('something', idx));
    end 
    assert(count == (2 * 2));
    removeCache('test');
end

function cacheIdxChangeOrderStructTest()
    cacheName = 'test';
    count = 0;
    removeCache(cacheName);
    while(true)        
        if (mod(count, 2) == 0)
            idx = getCacheIndex(struct('aaa', 100:102, 'bbb', 10:11, 'ccc', 6:6), cacheName);  
        else
            idx = getCacheIndex(struct('ccc', 6:6, 'aaa', 100:102, 'bbb', 10:11), cacheName);  
        end
        if (idx.done), break;end
        if (count >= 3*2*1)
            assert(false);
        end
        assert(idx.aaa <= 102);
        assert(idx.bbb <= 11);
        assert(idx.ccc == 6);
        assert(idx.aaa >= 100);
        assert(idx.bbb >= 10);
        count = count + 1;
        updateCache(idx, struct('something', idx));
    end
    assert(count == 3*2*1)
    removeCache(cacheName);
end

function cacheIdxInclusionTest()
    cacheName = 'test';
    removeCache(cacheName);
    while(true)
        idx = getCacheIndex(struct('aaa', 10:13, 'bbb', -1:1, 'ccc', 61:62), cacheName);  
        if (idx.done), break;end
        updateCache(idx, struct('something', idx));
    end
    for i = 10:13
        idx = getCacheIndex(struct('aaa', [11, i], 'bbb', [-1,0], 'ccc', 62), cacheName);  
        assert(idx.done);    
    end
    removeCache(cacheName);
end


function cacheIdxIntersectionTest()
    cacheName = 'test';
    removeCache(cacheName);
    while(true)
        idx = getCacheIndex(struct('aaa', 10:11, 'bbb', -1:1, 'ccc', 60:61), cacheName);  
        if (idx.done), break;end
        updateCache(idx, struct('something', idx));
    end
	count = 0;
    while(true)
        idx = getCacheIndex(struct('aaa', 9:12, 'bbb', -1:2, 'ccc', 59:60), cacheName);  
        if (idx.done), break;end
        assert(idx.aaa <= 12);
        assert(idx.bbb <= 2);
        assert(idx.ccc <= 60);
        assert(idx.aaa >= 9);
        assert(idx.bbb >= -1);        
        assert(idx.ccc >= 59);        
        assert(~((idx.aaa <=11) && (idx.aaa >= 10) && (idx.bbb <= 1) && (idx.bbb >= -1) && (idx.ccc <=61) && (idx.ccc >= 60)));       
        count = count + 1;
        updateCache(idx, struct('something', idx));
    end 
    assert(count == (4*4*2 - 2*3*1));
    removeCache('test');
end


function cacheIdxTest()
    cacheName = 'test';
    count = 0;
    removeCache(cacheName);
    while(true)
        idx = getCacheIndex(struct('aaa', [100,105], 'bbb', 10:12, 'ccc', 6:6), cacheName);  
        if (idx.done), break;end
        if (count >= 2*3*1)
            assert(false);
        end
        assert((idx.aaa == 105) || (idx.aaa == 100));
        assert(idx.bbb <= 12);
        assert(idx.ccc == 6);
        assert(idx.aaa >= 100);
        assert(idx.bbb >= 10);
        count = count + 1;
        updateCache(idx, struct('something', idx));
    end
    assert(count == 2*3*1)
    removeCache(cacheName);
end

function modSimpleTest() 
    assertEqual(getMod_(1, [10, 324, 5, 345]), [1,1,1,1]);
end

function modTest() 
    assertEqual(getMod_(1234, [10, 10, 10, 10]), [2,3,4,4]);
end

function modNarrowTest() 
    assertEqual(getMod_(4, [1, 10, 1, 1, 11, 1, 1]), [1, 1, 1, 1, 4, 1, 1]);
end

function keyTest()
    assert(strcmp(getKey_([12,13,14], [{'c'}, {'a'}, {'b'}]), 'a=13 b=14 c=12 '));
end

function descriptionSizeTest()
    [ ~, all_width ] = getDescriptionSize_(struct('aaa', 101:110, 'bb', 30:31, 'cc', -1:1));
    assert(all_width == 10*2*3);
end

function descriptionSizeSingleTest()
    [ ~, all_width ] = getDescriptionSize_(struct('aaa', 1:110));
    assert(all_width == 110);
end

function ensureCacheFileindexTest()
    removeCache('test');
    cache_path = getenv('cache_path');
    file_path = [cache_path, '/test/test.m'];
    index = ensureCacheFileindex_(file_path, struct('aa', 10:12, 'bb', [1,4,5]));
    assertEqual(index, zeros(3 * 3, 1));
    index = ensureCacheFileindex_(file_path, struct('aa', 10:22, 'bb', [1,4,5], 'cc', [10,14]));
    assertEqual(index, zeros(13 * 3 * 2, 1));
    removeCache('test');
end