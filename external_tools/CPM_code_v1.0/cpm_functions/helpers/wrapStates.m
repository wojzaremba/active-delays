function encodedStates = wrapStates(unencodedStates,G);

[K,N,garb]=size(unencodedStates);
encodedStates=zeros(K,N);

for k=1:G.numSamples
    st=squeeze(unencodedStates(k,:,:));
    encodedStates(k,:)=scaleTauToState2(st,G);
end
