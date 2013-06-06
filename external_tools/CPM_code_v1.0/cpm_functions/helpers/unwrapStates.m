% Take the HMM states, and unwrap them to the tau/scale states
% and do so for each sample

function unwrappedStates = unwrapStates(encodedStates,G)

[K,pathLength]=size(encodedStates);

unwrappedStates = zeros(K,pathLength,2);
for k=1:K
    unwrappedStates(k,:,:)=G.stateToScaleTau(encodedStates(k,:),:);
end

