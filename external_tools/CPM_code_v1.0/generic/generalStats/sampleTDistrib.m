function [tsamps tVars] = sampleTDistrib(M,dof);

%% the way the redbook says to do it on p.581
%% standard deviation and mean of the T-distrib 
%tstd=1; mu=0;

%%
z=randn(M,1);

tVars=chi2rnd(dof,M,1);

%x=mu+tstd.*z.*sqrt(v./tVars);
tsamps=mu+tstd.*z.*sqrt(v./tVars);

