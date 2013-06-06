function [l d] = uFunctionNew2(u,gammaSum3,gammaSum4,G,...
    gammaSum5,gammaSum6,scalesExp,sig2inv,extraTerm,zPhi)


%% gammaSum5 and gammaSum5 are for all kk and bb
%% the latter is required, and the former cannot hurt.
%% parts with no u_k dependency will drop out.
%%
%% this is for all observed traces
%% will calculate over all control points in this trace
%% (length(u) == numCtrlPts)

d = zeros(G.numSamples,G.numCtrlPts);

if any(u(:)<eps)
    l=realmax;
    d=realmax*ones(size(d));
    return;
end

l=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relevant portion of the log likelihood
tmpU = reshape(u,size(G.u));
%G.u = NaN*zeros(666);  %% for debugging
%G.uMat = NaN*zeros(666);  %% for debugging
[l uMat] = getPartialLogLikeForU(scalesExp,G,...
        gammaSum5,gammaSum6,tmpU,sig2inv,zPhi);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% derivative

w2inv = 1/G.w.^2;

for kk=1:G.numSamples
    for pt=1:G.numCtrlPts
        
        [tempTp sMinus sPlus] = getTimePts(G,pt);
        ptSet = {sMinus,sPlus};

        scaleCenterDiff = -w2inv*log(tmpU(kk,pt))./tmpU(kk,pt);
        d(kk,pt) = d(kk,pt) + extraTerm(pt,kk)*-tmpU(kk,pt)  + scaleCenterDiff;
        %% this is the other term I forgot from the log normal!!! (Aug 21, 2006)
        d(kk,pt) = d(kk,pt) - 1/tmpU(kk,pt);
        
        for ptSetInd=1:2  %% for sMinus and sPlus

            s = ptSet{ptSetInd};           
            
            if ~isempty(s)
                numS=length(s);

                tmpSum3 = gammaSum3(:,kk,s);  %% sum(gamma*x)
                tmpSum4 = gammaSum4(:,kk,s);  %% sum(gamma)

                tmpSum3 = permute(tmpSum3,[3 2 1]);
                tmpSum4 = permute(tmpSum4,[3 2 1]);

                tmpZPhi = zPhi(s,kk,:);
                %tmpUmat = repUMat(s,kk,:);
                tmpUmat = uMat(kk,s)';

                %tmpTerm3 = tmpZPhi.*tmpSum3;
                %tmpTerm4 = tmpZPhi.*tmpSum4;
                %% sum out the bins
                %tmpTerm3 = sum(tmpTerm3,3);
                %tmpTerm4 = sum(tmpTerm4,3);

                %% note that because we have divided up by sMinus and sPlus
                %% within one of these sets, c1s and c2s are not functions of
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
                tmp = repmat(sig2inv(:,kk),[1 numS 1])';
                repInvSig=permute(tmp,[1 3 2]);
                zPhiSum3 = sum(repInvSig.*tmpZPhi.*tmpSum3,3);
                zPhiSum4 = sum(repInvSig.*tmpZPhi.^2.*tmpSum4,3);

                ptTerm1 = sum(facRatio.*zPhiSum3);
                ptTerm2 = -sum(facRatio.*zPhiSum4.*tmpUmat);
                
                ptTerm = ptTerm1 + ptTerm2;
                d(kk,pt) = d(kk,pt) + ptTerm;
            end
        end
    end
end

%% want negative of these because using fminunc
d=-d(:);
l=-l;

%disp('-------------')
%[num2str(u,10) ' ' num2str(d,10) ' ' num2str(l,10)]

if isnan(l)
    keyboard;
end
if any(isnan(d))
    keyboard;
end


return;











