function garb = plotLatentTrace(newTrace,lineWidth)

fontSize=12;

if ~exist('lineWidth')
  lineWidth=2;
end

[numTimes numClass numBins]=size(newTrace);

for cc=1:numClass
    thisTrace = squeeze(newTrace(:,cc,:));

    %% 1-D lines
    plot(thisTrace,'-');%,'LineWidth',lineWidth);
    set(gca,'FontSize',fontSize);
    xlabel('Latent Time','FontSize',fontSize);
    ylabel('Amplitude','FontSize',fontSize);
    title(['Latent Trace - Class ' num2str(cc) ', numBins=' num2str(numBins)]);
    myLeg={};
    for jj=1:numBins
        myLeg{jj}=num2str(jj);
    end
    legend(myLeg);

    %% 2D
    figure,show((thisTrace)); colorbar;
    title(['Latent Trace - Class ' num2str(cc) ', numBins=' num2str(numBins)]);
    ylabel('Latent Time');
    xlabel('Bin Number');
end