%function [l d] = uFunctionNew(u,A,B,C,G,...
%    gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,extraTerm,zPhi)

function [l d] = uFunctionNew(u,gammaSum3,gammaSum4,G,...
    gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,extraTerm,zPhi)


%% gammaSum5 and gammaSum5 are for all kk and bb
%% the latter is required, and the former cannot hurt.
%% parts with no u_k dependency will drop out.
%%
%% this is for one single observed trace, kk
%% will calculate over all control points in this trace
%% (length(u) == numCtrlPts)

d = zeros(G.numCtrlPts,1);

if any(u<eps)
    l=realmax;
    d=realmax*ones(size(d));
    return;
end

l=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relevant portion of the log likelihood

%% need this for hmmLikeForZU
tmpU = G.u;
tmpU(kk,:)=u;

%keyboard;

%% but now don't need G.u, G.uMat
%G.u = NaN*zeros(666,666);
%G.uMat = NaN*zeros(666,666);

[l uMat] = getPartialLogLikeForU(scalesExpRep,G,...
        gammaSum5,gammaSum6,tmpU,sig2inv,zPhi);

%repUMat = repmat(uMat, [1 1 G.numBins]);
%repUMat = permute(repUMat,[2 1 3]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% derivative

w2inv = 1/G.w.^2;

for pt=1:G.numCtrlPts

    [tempTp sMinus sPlus] = getTimePts(G,pt);
    ptSet = {sMinus,sPlus};

    scaleCenterDiff = -w2inv*log(u(pt))./u(pt);
    d(pt) = d(pt) + extraTerm(pt,kk)*-u(pt)  + scaleCenterDiff;

    for ptSetInd=1:2  %% for sMinus and sPlus        
        
        s = ptSet{ptSetInd};        
        
        if ~isempty(s)

            tmpSum3 = gammaSum3(:,kk,s);  %% sum(gamma*x)
            tmpSum4 = gammaSum4(:,kk,s);  %% sum(gamma)

            tmpSum3 = permute(tmpSum3,[3 2 1]);
            tmpSum4 = permute(tmpSum4,[3 2 1]);
            
            tmpZPhi = zPhi(s,kk,:);
            %tmpUmat = repUMat(s,kk,:);            
            tmpUmat = uMat(kk,s)';

            tmpTerm3 = tmpZPhi.*tmpSum3;
            tmpTerm4 = tmpZPhi.*tmpSum4;
            %% sum out the bins
            tmpTerm3 = sum(tmpTerm3,3);
            tmpTerm4 = sum(tmpTerm4,3);         

            %% note that because we have divided up by sMinus and sPlus
            %% within one of these setes, c1s and c2s are not functions of
            %% s but are constant
            c1s = G.c1s(s); 
            c2s = G.c2s(s);
            
            if ptSetInd==1 % sMinus
                topFac = s-c1s;
            elseif ptSetInd==2 % sPlus
                topFac = c2s-s;
            end
            bottomFac = c2s - c1s;
            facRatio = (topFac./bottomFac)';
                        
            %% sum out bins
            zPhiSum3 = squeeze(sum(tmpZPhi.*tmpSum3,3));
            zPhiSum4 = squeeze(sum(tmpZPhi.^2.*tmpSum4,3));
            
            ptTerm1 = sig2inv(kk)*sum(facRatio.*zPhiSum3);
            ptTerm2 = sig2inv(kk)*sum(facRatio.*zPhiSum4.*-tmpUmat);

            ptTerm = ptTerm1 + ptTerm2;
            d(pt) = d(pt) + ptTerm;
        end            
    end    
end


%% want negative of these because using fminunc
d=-d;
l=-l;

%disp('-------------')
%[num2str(u,10) ' ' num2str(d,10) ' ' num2str(l,10)]


return;











