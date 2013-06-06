function plotAbsorb(dat,times,nm,pow);

dat(find(dat<0))=0;

if exist('pow')
    thisDat = dat.^pow;
    myTit = ['Absorbance.^{' num2str(pow) '}'];
else
    thisDat = dat;
    myTit = ['Absorbance'];
end

show(thisDat); title(myTit); 
colorbar;

ylabel('Time (seconds)');
xlabel('Wavelength (nanometers)');

timeRg = 1:50:length(times);
set(gca,'YTick', timeRg);
set(gca,'YTickLabel',round(60*times(timeRg)));

nmRg = 1:50:length(nm);
set(gca,'XTick', nmRg);
set(gca,'XTickLabel',nm(nmRg));