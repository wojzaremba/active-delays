function [l d] = uFunction(u,A,B,C,G,...
    gammaSum5,gammaSum6,scalesExpRep,sig2inv,kk,zPhi)

%% gammaSum5 and gammaSum5 are for all kk and bb
%% the latter is required, and the former cannot hurt.
%% parts with no u_k dependency will drop out.

%% this is for one single observed trace, kk

if u<eps
    f=realmax;
    d=realmax;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relevant portion of the log likelihood

tmpU = G.u;
tmpU(kk)=u;

l = getPartialLogLikeForU(scalesExpRep,G,...
        gammaSum5,gammaSum6,tmpU,sig2inv,zPhi);
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% derivative
d = -u*B + C - (log(u)/u)*A;
%% this is the other term I forgot from the log normal!!! (Aug 21, 2006)
d = d - 1/u;

%% want negative of these because using fminunc

d=-d;
l=-l;

%disp('-------------')
%[num2str(u,10) ' ' num2str(d,10) ' ' num2str(l,10)]


return;











