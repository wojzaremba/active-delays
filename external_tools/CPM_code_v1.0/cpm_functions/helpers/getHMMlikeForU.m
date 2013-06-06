function [hmmLikeForZU uMat]= getHMMlikeForU(u,G,scalesExpRep,...
    gammaSum5,gammaSum6,zPhi,sig2inv,binNum);

% helper function to calculate the HMM portion of the expected complete LOG
% likelihood.  two terms drop out 1) normalization constant of the
% gaussian, and 2) the x-related term in the quadratic expansion
%
% % used only for u updates, as z updates has a more efficient version
%
% note too it is only doing it for 1 bin, (the input params should only be
% given for this bin
%
% called by z2Function, and uFunction
%
% sig2inv = G.sigmas(binNum,:).^(-2);
%
% if want it for kk only, then specify which kk

%if ~exist('kk')
%    kk = 1:G.numSamples;
%end

uMat=0;

% zRep = zeros(G.numSamples,G.numStates);
% for cc=1:G.numClass
%   classInd = G.class{cc};
%   numInClass = length(classInd);
%   zTauS = z(G.stateToScaleTau(:,2),cc);
%   zRep(classInd,:)=repmat(zTauS,[1 numInClass])';
% end
% zPhi = scalesExpRep.*zRep;
%zPhi = squeeze(zPhi(kk,:));

if G.USE_CPM2    
    uMat = getUMat(G,u); %% need to call this each time
    %uMat = squeeze(uMat(:,:));    
    uMat2 = uMat.^2;   
    %% remember, this is just for one bin
    term1 = sum(sig2inv.*sum(uMat.*zPhi.*gammaSum6,2)');
    term2 = sum(sig2inv.*sum(uMat2.*zPhi.^2.*gammaSum5,2)')/2;
else       
    term1 = sum(u.*sig2inv.*sum(zPhi.*gammaSum6,2)');
    term2 = sum(u.^2.*sig2inv.*sum(zPhi.^2.*gammaSum5,2)')/2;
end

hmmLikeForZU = term1 - term2;

return;