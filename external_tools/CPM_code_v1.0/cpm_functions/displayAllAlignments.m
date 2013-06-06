% function nothing = displayAllAlignments(G,st,samples,DETAILS)

function nothing = displayAllAlignments(G,st,allSamp,DETAILS,sampleNum)

for ii=sampleNum%1:G.numSamples   
  mytitle=['Sample ' num2str(ii) '  ' '\lambda=' num2str(G.lambda,2) ', \nu=' num2str(G.nu,2)];
  [H,allAxes]=getAxes(5); 
  tmpTrace = G.z(:,getClass(G,ii));
  tmpSt=squeeze(st(ii,:,:));
    
  displayAlignment(G,allAxes,tmpSt,allSamp{ii},mytitle,ii,DETAILS);
end
