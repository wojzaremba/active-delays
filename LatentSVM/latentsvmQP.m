function [ model, primalobj ] = latentsvmQP( X, Y, first, len, windowSize, C, H, Xcache, eps)
    last = first + len - 1;
    nrChannels = size(X, 2);
    gap = Inf;
    iter = 0;
    dualobj = -Inf;
    loss = zeros(iter, 1);    
    alp = zeros(iter, 1);
    phi = zeros(iter, len * nrChannels);
    XH = zeros(size(X, 1), nrChannels * len);
    for i = 1:size(X, 1)  
        tmp = [];
        for j = 1:size(X, 2)      
            tmp = [tmp, X(i, j, (first(j) + H(i)):(last(j) + H(i)))];
        end
        XH(i, :) = tmp(:);
    end
    Yrep = repmat(Y', 2 * windowSize + 1, 1);    
    Yrep2 = repmat(Y, 1, len * nrChannels);    
    while (gap > eps)
        w = (phi' * alp) / size(X, 1);         
        iter = iter + 1;
        g(:, :) = reshape(Xcache * w, 2*windowSize+1, size(X, 1));  
        vPhi = zeros(size(X, 1), 1);        
        phiHvalues = 1 - (repmat((XH * w)', (2 * windowSize + 1), 1) + g) .* Yrep;
        if (size(phiHvalues, 1) > 1)
            [vPhi, vH] = max(phiHvalues);
        else
            vPhi = squeeze(phiHvalues);
            vH = ones(1, size(X, 1));
        end
        primalobj = (norm(w(:)) ^ 2)/2 + C * sum(max(vPhi(:), 0)) / size(X, 1);              
        phi = [phi;zeros(1, nrChannels * len)];
        loss = [loss;sum(vPhi > 0)];
        phi(iter, :) = phi(iter, :) + (vPhi > 0) * ((XH + Xcache(vH + ((1:size(X,1))-1) * (2 * windowSize + 1), :)) .* Yrep2);

        Hmat = (phi(:, :) * phi(:, :)') / (size(X, 1)^2);
        olddualobj = dualobj;
        [alp, fval, exitflag, output, lambda] = quadprogExtended(Hmat, -loss / size(X, 1), ones(1, size(phi, 1)), C, [], [], zeros(size(phi, 1), 1), [], [alp;0], []);  
        writelnLog(3, 'Max alpha in Latent SVM is %f', max(abs(alp)));
        if (exitflag ~= 1)
            writeLog(-1, 'mosek error, have to break\n');
            alp = aplold;
            break;
        end
        olddualobj = dualobj;
        dualobj = -fval;    
        gap = primalobj - dualobj;
        if (olddualobj > 1.1*dualobj + 1e-8)
            writeLog(-2, 'gap error\n');
        end  
        if mod(iter, 100) == 0
            writeLog(2, 'iter %d primalobj =%.10f, dualobj %.10f, primal-dual gap=%.10f\n', iter, primalobj, dualobj, gap);       
        end
        writeLog(3, 'iter %d primalobj =%.10f, dualobj %.10f, primal-dual gap=%.10f\n', iter, primalobj, dualobj, gap);        
    end
    model = (phi' * alp) / size(X, 1); 
end
