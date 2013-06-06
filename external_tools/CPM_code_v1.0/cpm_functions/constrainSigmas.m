function sigmas = constrainSigmas(G,oldSigmas,proposedSig);

%% make sure that each sigma for a sample of the same class
%% is within a factor sigFac of each other
%% update the smallest sigma first


sigmas=oldSigmas; %% this is from before any updates
fac=G.sigmaFac;
%display('jenn');
%fac=realmax %Jenn
%violations=zeros(size(sigmas));

%% SAME FOR ALL SIGMAS! (no, but pulled it oustide)

for cc=1:G.numClass
    thisClass = G.class{cc};
    for bb=1%:G.numBins        
    %for bb=1:G.numBins        
        updateOrder = thisClass; %1:length(thisClass);
        for jj=1:length(updateOrder)            
            ss=updateOrder(jj);
            %% make one update
            sigmas(bb,ss)=proposedSig(bb,ss);         
                        
            %% now check it
            theseSig = sigmas(bb,ss);
            %% setdiff is really slow, so use:
            %otherSig = sigmas(bb,setdiff(updateOrder,ss));            
            otherSig = sigmas(bb,[updateOrder(1:(jj-1)) ...
                updateOrder((jj+1):end)]);
            maxOther = max(otherSig);
            minOther = min(otherSig);
            
            if theseSig>fac*minOther
                sigmas(bb,ss)=fac*minOther
            elseif theseSig*fac<maxOther
                sigmas(bb,ss)=maxOther/fac;
            end
            %replicate to other bins
            sigmas(:,ss) = sigmas(bb,ss);           
        end
    end    
end

%sigmas'
%keyboard;


