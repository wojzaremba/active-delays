function [allStates lastState it updates iterTime G] = trainMCCPM(...
    G,samplesMat,updates,state,FP,saveFile)

%%% use MCMC on our Bayesian, Hierarchical CPM

%% I think it makes most sense to sample starting near the bottom,
%% since that is where our hard evidence is.  Not sure if that is
%% something standard or not

%% somewhere in here I need to check the condition numbers of
%% covariance matrixes to make sure that they are ok

%% check to see if lightspeed is installed
if exist('test_trigamma.m','file')~=2
    error('Need to have the Minka lightspeed toolbox installed');
end

if ~isfield(G,'SMART_INIT_ZP')
    G.SMART_INIT_ZP=0;
end

str = printGfields(G);
myPrint(FP,str);
str=printStruct(updates);
myPrint(FP,str);

%if any(samplesMat<0)
%    error('Problems if data is negative, please transform it');
%end

if G.numScales>1
    error('need to fix up');
end

%allStates=cell(1,G.maxIter);
iterTime = zeros(1,G.maxIter);

str=['Training HBCPM by MCMC (' num2str(G.maxIter) ' iterations)'];
myPrint(FP,str);

%% this is really just a special case of having some G.fixedClasses
if G.ONE_CLASS
    updates.rc=0;
    updates.rhoc=0;
    updates.alphac=0;
    updates.mixFlags=0;
    updates.mixProp=0;
    updates.mixVar=0;
    updates.childTrace=0;  
    state.rhoc=state.rhop
    state.alphac=state.alphap;
    state.rc='';
end

if ~isempty(G.fixedClasses)  %% includes G.ONE_CLASS
    %% make the child trace be the parent trace (for some computations)
    %% but need to change it's shape so that code works
    zc=stealZpForZc(state,G);
    if ~G.ONE_CLASS
        for c=G.fixedClasses
            state.zc(:,c,:)=zc;
            state.rc(:,c,:)=0;
        end
    else
        state.zc=zc;
        state.rc=0;
    end
end

%% allocate space for all samples we will store
zpA=zeros([G.maxIter size(state.zp)]);
rpA=zeros([G.maxIter size(state.rp)]);
alphapA=zeros([G.maxIter size(state.alphap)]);
rhopA=zeros([G.maxIter size(state.rhop)]);
parentMeanA=zeros([G.maxIter size(state.parentMean)]);
parentVarA=zeros([G.maxIter size(state.parentVar)]);
if ~G.ONE_CLASS
    zcA=zeros([G.maxIter size(state.zc)]);
    rcA=zeros([G.maxIter size(state.rc)]);
    alphacA=zeros([G.maxIter size(state.alphac)]);
    rhocA=zeros([G.maxIter size(state.rhoc)]);   
    mixVarA=zeros([G.maxIter size(state.mixVar)]);
    mixPropA=zeros([G.maxIter size(state.mixProp)]);
    mixFlagsA=zeros([G.maxIter size(state.mixFlags)]);
end
DA=zeros([G.maxIter size(state.D)]);
%S=zeros([G.maxIter size(state.S)]);
uA=zeros([G.maxIter size(state.u)]);
sigmasA=zeros([G.maxIter size(state.sigmas)]);
sigaA=zeros([G.maxIter size(state.siga)]);
sigbA=zeros([G.maxIter size(state.sigb)]);
HMMstatesA=zeros([G.maxIter size(state.HMMstates)]);
allLikesA=zeros(G.maxIter,1);
CPUtimeA=zeros(G.maxIter,1);

state.CPUtime=NaN;

if G.SMART_INIT_ZP
    str=['Using smart initialization for latent trace'];
    myPrint(FP,str);
    %% then we want to do the first few MCMC iterations locking z, and
    %% updating rp, rhop and alphap, to make sure we latch on to the
    %% good initial latent trace
    
    %% copy the updates we wish to do into another variable, and then
    %% make a new one to suit our needs
    realUpdates=updates;
    %% don't update the latent traces
    updates.parentTrace=0;
    updates.childTrace=0;
    updates.rc=0;
    updates.mixFlags=0;
    updates.mixProp=0;
    updates.mixVar=0;
      
    %% counter to keep track of smart initialization iterations
    smartInit=1;
end


it=1;
keepGoing=1;
while (it<=G.maxIter)   
    t=cputime;

    G.sigmas=state.sigmas;
    currentLike=HBCPMlogLike(G,state,samplesMat);
    G=rmfield(G,'sigmas');
    str=['Joint Log Like: ' num2str(currentLike,10)];
    myPrint(FP,str);

    
    
    %allStates{it}=state;
    zpA(it,:,:,:)=(state.zp);
    rpA(it,:,:,:)=(state.rp);
    alphapA(it,:,:,:)=(state.alphap);
    rhopA(it,:,:,:)=(state.rhop);
    parentMeanA(it,:,:,:)=(state.parentMean);
    parentVarA(it,:,:,:)=(state.parentVar);
    if ~G.ONE_CLASS
        zcA(it,:,:,:)=(state.zc);
        rcA(it,:,:,:)=(state.rc);
        alphacA(it,:,:,:)=(state.alphac);
        rhocA(it,:,:,:)=(state.rhoc);
        mixVarA(it,:,:,:)=(state.mixVar);
        mixPropA(it,:,:,:)=(state.mixProp);
        mixFlagsA(it,:,:,:)=(state.mixFlags);
    end
    %S(it,:,:,:)=(state.S);
    uA(it,:,:,:)=(state.u);
    sigmasA(it,:,:,:)=(state.sigmas);
    sigaA(it,:,:,:)=(state.siga);
    sigbA(it,:,:,:)=(state.sigb);
    DA(it,:,:,:)=state.D;
    HMMstatesA(it,:,:,:)=(state.HMMstates);
    allLikesA(it)=currentLike;
    CPUtimeA(it)=state.CPUtime;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if updates.rc
        rc = sampleChildEnergyImpulseAll(G,state);
        state.rc=rc;
    end

    if updates.childTrace  
        zc = sampleChildTraces(G,state,samplesMat);
        state.zc=zc;
    end
    
    if updates.rhoc
        %propStd=1.5e-1;  %% good for Inv-Gamm prior
        [rhoc rejectFrac] = sampleRhoC(G,state,FP);
        state.rhoc=rhoc;
        state.rejectFrac(1)=rejectFrac;
    end
    
    if updates.alphac  
       %propStd=1.5e-1;  %% good for Inv-Gamm prior             
        [alphac rejectFrac] = sampleAlphaC(G,state,FP);
        state.alphac=alphac;
        state.rejectFrac(2)=rejectFrac;
    end
    
    if updates.mixProp        
        mixProp = sampleMixProp(G,state,FP);
        state.mixProp = mixProp;
    end

    if updates.mixVar
        mixVar = sampleMixVar(G,state,FP);
        state.mixVar = mixVar;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if updates.u       
        [u uMat]=sampleU(G,state,FP,samplesMat);      
        state.u=u;        
        G.uMat = uMat;        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if updates.rp       
        rp = sampleParentEnergyImpulse(G,state,FP);
        state.rp=rp;
    end

    if updates.parentTrace        
        zp = sampleParentTraces(G,state,samplesMat);
        state.zp=zp;
        if ~isempty(G.fixedClasses)  %% includes G.ONE_CLASS       
            zc=stealZpForZc(state,G);
            if ~G.ONE_CLASS
                for c=G.fixedClasses
                    state.zc(:,c,:)=zc;
                    state.rc(:,c,:)=0;
                end
            else
                state.zc=zc;
                rc=0;
            end
        end

        if any(isnan(zp))
            keyboard;
        end
    end

    if updates.rhop         
        %propStd=5e-2; %% good for Inv-Gamm prior   
        [rhop rejectFrac] = sampleRhoP(...
            G,state,FP);
        state.rhop=rhop;
        state.rejectFrac(3)=rejectFrac;
        if G.ONE_CLASS
            state.rhoc=state.rhop;
        end
    end
    
    if updates.alphap        
        %propStd=5e-2; %% good for Inv-Gamm prior
        [alphap rejectFrac] = sampleAlphaP(...
            G,state,FP);
        state.alphap=alphap;
        state.rejectFrac(4)=rejectFrac;
        if G.ONE_CLASS
            state.alphac=state.alphap;
        end
    end
        
    if updates.parentMean       
        parentMean = sampleParentMean(G,state,FP);
        state.parentMean = parentMean;
    end
    
    if updates.parentVar       
        parentVar = sampleParentVar(G,state,FP);
        state.parentVar = parentVar;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if updates.mixFlags        
        mixFlags=sampleMixFlag(G,state);
        %% artificially make them all in-liers
        %mixFlags = ones(size(state.mixFlags));  
        state.mixFlags=mixFlags;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if updates.HMMstates           
        HMMstates = sampleHMMstates(samplesMat,G,state);       
        state.HMMstates(:,:,2)=HMMstates;
    end
    
    if updates.sigmas        
        sigmas = sampleHMMsigmas(samplesMat,G,state,FP);
        state.sigmas=sigmas;
    end
  
    if updates.D       
        D = sampleD(state,G,FP);        
        state.D=D;
        %% transmit to stuff in G that we need
        %% for historical reasons, add it to G
        G.D=state.D;
        G = reviseG(G,'',D);
        G=rmfield(G,'D');
    end

    if updates.S
        keyboard;
        %% transmit to stuff in G that we need
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    iterTime(it)=cputime-t;
    state.CPUtime=iterTime(it);
    str = '-----------------------------------------';
    myPrint(FP,str);
    str=['Iteration: ' num2str(it) ' -- CPU time: ' num2str(iterTime(it),3)];
    myPrint(FP,str);
    str = '-----------------------------------------';
    myPrint(FP,str);

    it=it+1;
    if G.SMART_INIT_ZP
        if smartInit==G.smartInitNumIter
            %% switch back to updating everything
            updates=realUpdates;
            str=['Finished using smart initialization, now doing all updates'];
            myPrint(FP,str);            
            G.SMART_INIT_ZP=0;
        else
            smartInit=smartInit+1;
        end
    end
    
    if mod(it,500)==1 || it==100 || it==300  || it==20    
        cmd=['save ' saveFile];
        eval(cmd);        
    end
end
m=1;

state.iterTime=iterTime;

lastState=state;

allStates.zpA=zpA;
allStates.rpA=rpA;
allStates.alphapA=alphapA;
allStates.rhopA=rhopA;
allStates.parentMeanA=parentMeanA;
allStates.parentVarA=parentVarA;
if ~G.ONE_CLASS
    allStates.zcA=zcA;
    allStates.rcA=rcA;
    allStates.alphacA=alphacA;
    allStates.rhocA=rhocA;
    allStates.mixVarA=mixVarA;
    allStates.mixPropA=mixPropA;
    allStates.mixFlagsA=mixFlagsA;
elseif G.ONE_CLASS
    allStates.zcA=zpA;
    allStates.rcA=rpA;
end
allStates.DA=DA;
%allStates.S=S;
allStates.uA=uA;
allStates.sigmasA=sigmasA;
allStates.sigaA=sigaA;
allStates.sigbA=sigbA;
allStates.HMMstatesA=HMMstatesA;
allStates.allLikesA=allLikesA;
allStates.CPUtimeA=CPUtimeA;

return;

