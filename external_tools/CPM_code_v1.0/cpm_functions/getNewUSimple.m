% function [newU, uCoeff,myfval] = getNewUSimple(G,gammaSum3,gammaSum4,scalesExp,lambda)
%
% Solve for new u iteratively (or analytically if possible)
%

function [newU] = getNewUSimple(G,gammaSum3,gammaSum4,...
        gammaSum5,gammaSum6,scalesExp)

C=G.numClass;

scalesExpRep = repmat(scalesExp,[G.numSamples 1 G.numBins]);
scalesExpRep = permute(scalesExpRep,[2 1 3]);

theseClasses = getAllClass(G);
zPhi = G.z(G.stateToScaleTau(:,2),theseClasses,:).*scalesExpRep;
gammaSum3=permute(gammaSum3,[3 2 1]);
gammaSum4=permute(gammaSum4,[3 2 1]);

sig2 = G.sigmas.^2;
sig2inv = 1./sig2';

if G.numBins>1
  D =   sum(sig2inv.*squeeze(sum(zPhi.*gammaSum3,1)),2);
  B = sum(sig2inv.*squeeze(sum(zPhi.^2.*gammaSum4,1)),2);
else
  D =   sum(sig2inv'.*sum(zPhi.*gammaSum3,1),1)';
  B = sum(sig2inv'.*sum(zPhi.^2.*gammaSum4,1),1)';
end

%% assumes same sigma for each bin!!!
%A = (sig2(1,:)/(G.w^2))';
A = (1/(G.w^2))';

%% extra term has to do with the smoothing penalty relating to u
if G.useBalancedPenalty
    extraTerm = getExtraTerm(G,theseClasses);
    B=B+extraTerm';
end

%if any([A(:); B(:); D(:)]<=0)
%    display(['trainFBHHM: A B D: ' num2str([A B D])]);
%    keyboard;
%end

newU = zeros(size(G.u));  %% works for USE_CPM2 or not
% if G.numBins>1
%     error('no, it is different for every bin! change this if using it');
%     bin=1; % arbitrarily, since assuming same for all bins
%     sig2inv_t = G.sigmas(bin,:).^(-2);
% end
sig2inv_t = G.sigmas.^(-2);

for kk=1:G.numSamples     
    [newU(kk) myfval(kk)] = helper(A,B(kk),D(kk),...
        G,kk,gammaSum5,gammaSum6,scalesExpRep,sig2inv_t);   
end

if any(isinf(newU)) | any(isnan(newU))
  warning('newU is screwed up, look at sum(gammaX,1) ');
  keyboard;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newU,fval]=helper(A,B,C,G,kk,...
    gammaSum5,gammaSum6,scalesExpRep,sig2inv)
%%%%%%%%%%%%%%%%

fval=NaN;
tolx=NaN;

if G.uType==1     %% With no prior on u_k:   
    newU=mean(C./B);

elseif G.uType==2 %% With prior on u_k
    validInterval=[realmin,10];
    % whatever log base I use here has to be the same as when I
    % calculate the penalty term in the likelhiood.

    newU = NaN;
    
    theseClasses = getAllClass(G);
    zPhi = G.z(G.stateToScaleTau(:,2),theseClasses,:).*scalesExpRep;

    startGuess=G.u(kk);
      
    if 0
        %fminunc on derivative
        tolx=1e-5;
        options=optimset('TolX',tolx,'DerivativeCheck','off',...
            'GradObj','on','Display','off');
        [newU2,fval2,exitflag,output] = fminunc(@(u)uFunction(u,A,B,C,...
            G,gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,zPhi),...
            startGuess,options);
    else       
        numIter=30;
        [newU,fval]=minimize(startGuess,'uFunction',numIter,A,B,C,...
            G,gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,zPhi);
        fval=fval(end);
    end

    
    %% check the derivative
    if 0
        keyboard;
        %save tmp.mat;
        y=rand(size(startGuess));
        G.u = [0.8 0.9 1.1 1.2 1.3 1.4];        
        e=1e-6;
        [d anal fd] = checkgrad('uFunction',y,e,...
            A,B,C,G,gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,zPhi);    
    end
    
    
 
end

return;


