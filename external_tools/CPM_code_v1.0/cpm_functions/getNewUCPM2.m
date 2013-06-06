% function newU = getNewUCPM2(G,gammaSum3,gammaSum4,scalesExp,lambda)
%
% Solve for new u iteratively (or analytically if possible)
% when using CPM2 -- which currently uses control points for
% a linear spline

function newU = getNewUCPM2(G,gammaSum3,gammaSum4,gammaSum5,...
    gammaSum6,scalesExp)

%load /u/jenn/newUPCM2.mat;

C=G.numClass;

scalesExpRep = repmat(scalesExp,[G.numSamples 1 G.numBins]);
scalesExpRep = permute(scalesExpRep,[2 1 3]);

theseClasses = getAllClass(G);
zPhi = G.z(G.stateToScaleTau(:,2),theseClasses,:).*scalesExpRep;

%B = zeros(G.numCtrlPts,G.numSamples);
%D = zeros(G.numCtrlPts,G.numSamples);

B = cell(G.numCtrlPts,1);
D = cell(G.numCtrlPts,1);

%% extra term has to do with the smoothing penalty relating to u
if G.useBalancedPenalty
    extraTerm = getExtraTerm(G,theseClasses);    
    %% same for all control points
    extraTerm = repmat(extraTerm,[G.numCtrlPts 1]);
end

%sig2 = G.sigmas.^2;
%sig2inv = 1./sig2';

newU = zeros(size(G.u));  %% works for USE_CPM2 or not
newU = G.u;  %% so that we can debug by updating just one

%% NO!!!
%bin=1; % arbitrarily, since assuming same for all bins
%sig2inv_t = G.sigmas(bin,:).^(-2);
%% CORRECT WAY:
sig2inv_t = G.sigmas.^(-2);

if 0
    for kk=1:G.numSamples
        solvedU = helperCPM2(gammaSum3,gammaSum4,...
            G,kk,gammaSum5,gammaSum6,scalesExp,sig2inv_t,...
            extraTerm,zPhi);
        newU(kk,:) = solvedU;
    end
else
    %% All together, far more efficient
    solvedU = helperCPM3(gammaSum3,gammaSum4,...
        G,gammaSum5,gammaSum6,scalesExp,sig2inv_t,...
        extraTerm,zPhi);
    newU = reshape(solvedU,size(G.u));
end

if any(isinf(newU)) | any(isnan(newU))
    warning('newU is screwed up, look at sum(gammaX,1) ');
    keyboard;
end


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% solve all u_kt together
function [newU,fval] = helperCPM3(gammaSum3,gammaSum4,...
        G,gammaSum5,gammaSum6,scalesExp,sig2inv,extraTerm,zPhi);

fval=NaN;
tolx=NaN;

if G.uType==1     %% With no prior on u_k: 
    error('not implemented');
    keyboard;
    
elseif G.uType==2 %% With prior on u_k
    % whatever log base I use here has to be the same as when I
    % calculate the penalty term in the likelhiood.
    tolx=1e-4;
    startGuess=squeeze(G.u(:));

    if 0
        options=optimset('TolX',tolx,'DerivativeCheck','off',...
            'GradObj','on','Display','off');
        [newU2,fval2,exitflag,output,grad] = fminunc(@(u)uFunctionNew2(u,...
            gammaSum3,gammaSum4,G,gammaSum5,gammaSum6,scalesExp,...
            sig2inv,extraTerm,zPhi),startGuess,options);
    else
        numIter=50;
        [newU, fval] = minimize(startGuess,'uFunctionNew2',numIter,...
            gammaSum3,gammaSum4,G,gammaSum5,gammaSum6,scalesExp,...
            sig2inv,extraTerm,zPhi);
    end

    %% check the derivative
    if 0
        keyboard;
        %clear; load bug.mat;
        y = startGuess;
        if 1
            y=rand(size(startGuess));
            G.u = rand(size(G.u));
            %G.u(find(G.u<0.7))=0.7;
        end
        e=1e-6;
        
        [d anal fd] = checkgrad('uFunctionNew2',y,e,...
            gammaSum3,gammaSum4,G,gammaSum5,gammaSum6,...
            scalesExp,sig2inv,extraTerm,zPhi);

        %figure,plot(fd-anal); title('fd-analy');
        
        keyboard;
    end

    if any(newU<0)
        keyboard;
    end
    if any(~isreal(newU))
        keyboard;
    end
end

return;







