% function garb = showAlignedAll(G,allSamples,scaleAndTimes,newTrace,SHOWSCALE)
%
% display all the 1D aligned samples
%
% if SHOWSCALE exists and equals zero, then the scaling is not
% performed, and the latent trace not displayed



function myMax = showAlignedAll(G,allSamples,scaleAndTimes,newTrace,showScale,linespecs)


fontSize=18;
if ~exist('linespecs','var')
    linespecs=getLineSpecs(1);
end
legCount=1;


if ~isempty(newTrace)
    plot(newTrace,'c-','MarkerSize',2,'LineWidth',2.5);
    myleg{legCount}='Latent Trace';
    legCount=legCount+1;
end


myMax=0;


for ii=1:G.numSamples
  st = squeeze(scaleAndTimes(ii,:,:));
  
  a=allSamples{ii}; 
  b=G.u(ii)*2.^(G.scales(st(:,1))); 
  if (showScale)
    myTemp=a(:)./b(:);
  else
    myTemp=a(:);
  end
  
  plot(st(:,2)',myTemp,linespecs{ii},'MarkerSize',2);
  hold on;
  myleg{legCount} = ['Rep. ' num2str(ii)];
  legCount=legCount+1;
  myMax=max(myMax,max(myTemp));
end


hold off;
hx=legend(myleg);
axis('auto');
ylabel('Amplitude','FontSize',fontSize);
xlabel('Latent Time','FontSize',fontSize);


myLength=G.numTaus;
tmp=axis; tmp(1:2)=[1,myLength]; tmp(4)=myMax*1.05; axis(tmp);
set(hx,'FontSize',4);

title('Aligned Time Series','FontSize',fontSize);

legend off;
set(gca,'FontSize',fontSize);
