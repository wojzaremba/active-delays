function extraTerm = getExtraTerm(G,theseClasses);

traceDiffs = squeeze(sum(diff(G.z,1,1).^2));  %sum out time
if G.numBins>1
    %% sum out bins
    traceDiffs = sum(traceDiffs,2)';
end
%% need the appropriate one for each u_k that we will solve
traceDiffs = traceDiffs(theseClasses);

if G.USE_CPM2
    extraTerm = 2*G.lambda*traceDiffs./...
        (G.numPerClass(theseClasses)*G.numCtrlPts);
else
    extraTerm = 2*G.lambda*traceDiffs./G.numPerClass(theseClasses);
end

