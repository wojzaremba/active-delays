function nothing = drawAllFunctions(ha,exptxt,allG,st,tracesOneD,)

if (~exist('useInd'))
  useInd=1:numExp

numExp=length(ha);

%%% Look at 1D alignments
[H,allAxes]=getAxes(5);
K=figure,
M=figure,
filename = '/u/jenn/temp/matlabFigures/';
tempSamp=ha;

if (1) 
  %K=figure,
  figure(K), 
  myoffset=0.02; myheight=0.9;
    
  subplot(3,1,1,'replace'),
  showHeaderAbun(tempSamp);
  title([exptxt{jj} ' (4 Replicates)']);
  mytitle='Raw Data';
  text(myoffset,myheight,mytitle,'Units','Normalized')
    
  % display time correction    
  myst2 = squeeze(st(:,:,:,jj));

  subplot(3,1,2,'replace'),
  showScale=0;
  showAlignedAll(allG{jj},tempSamp,myst2,tracesOneD(jj,:),showScale);
  mytitle= 'Time Corrected';
  text(myoffset,myheight,mytitle,'Units','Normalized')
  xlabel('UpsampledExperimental Time');
  
  % display time and scale correction, with latent trace
  subplot(3,1,3,'replace'),
  showScale=1;
  showAlignedAll(allG{jj},tempSamp,myst2,tracesOneD(jj,:),showScale);
  mytitle='Time and Scale Corrected';
  xlabel('');
  text(myoffset,myheight,mytitle,'Units','Normalized')
  
  saveas(K,[filename 'viterbiAlignmentAll' num2str(jj) '.jpg']);
end
if (1)
  figure(M),
  for ii=1:numReplicate
    subplot(4,1,ii),
    plot(tempSamp{ii},'k-+','MarkerSize',2);
    title([exptxt{jj} '  Rep ' num2str(ii) ' (' num2str(useInd(ii,jj)) ')' ]);
    axis([0 410 0 2.5*10^9]);
  end
  saveas(M,[filename 'RawDataExp' num2str(jj) '.jpg']);
end
if (1)
  for ii=1:numRep
    %[H,allAxes]=getAxes(5);
    myst = squeeze(st(ii,:,:,jj));
    hold off;
    %mytitle=[exptxt{jj} ' - Replicate ' num2str(ii) ' (Noise Level=' num2str(allG{jj}.sigmas(ii),2) ')' ];
    mytitle=[exptxt{jj} ' - Replicate ' num2str(ii) ];
    displayAlignment(allG{jj},allAxes,tracesOneD(jj,:),myst,tempSamp{ii},mytitle,allG{jj}.sigmas(ii),ii);
    %saveas(H,[filename 'viterbiAlignment' num2str(ii) '.eps'],'psc2');
    saveas(H,[filename 'viterbiAlignmentExp' num2str(jj) '.R' num2str(ii) '.jpg']);
    %pause;
  end
end
