% function ubar = getUbar2(G,u)
%
% returns u bar for each class, size(ubar)=1,G.numClass

function ubar = getUbar2(G,u)

%% too slow to keep this here
% if ~exist('u')  %% need this indirectly for uFunction
%     u=G.u;
% end


if G.useBalancedPenalty
    ubar=zeros(1,G.numClass);
    if ~G.USE_CPM2      
        for cc=1:G.numClass
            tmpInd = G.class{cc};
            ubar(cc)=sum(u(tmpInd).^2)/length(tmpInd);
        end
    else
        %% average over control point values, which are stored
        %% in u now            
        for cc=1:G.numClass
            tmpInd = G.class{cc};
            ctrlPtVals = u(tmpInd,:);
            ubar(cc)=mean(ctrlPtVals(:).^2);
        end        
    end
else
    ubar=ones(1,G.numClass);
end
