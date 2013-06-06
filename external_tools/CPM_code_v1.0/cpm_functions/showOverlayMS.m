% function garb = showOverlayMS(dd,st,win,G,exptxt,showAlignedOnly)
%
% show aligned and unaligned images, overlayed
% exptxt containts the title information for specific repeats
% win =[minTime maxTime minMZ maxMZ]
%
% SHOW_DIFF also shows the difference between 'merged' pairs

function alignQMZ = showOverlayMS(dat,st,win,G,scaleType,exptxt,...
    showAlignedOnly,SHOW_DIFF)

%dat=qmzD; st=scaleAndTimes(useThese,:,:); win=myWin{thisWin}; exptxt='';

if length(dat)~=2
  error('Can only display 2 at a time');
end

alignQMZ = alignMS(dat,st,G,scaleType);

numGuideLines=5; 
%% start the first guide line near the beginning of window
if ~isempty(win)
    a=win(1)+2; b=win(2)-2;
else
    [numTime, numMZ]=size(dat{1});
    a=1+2; b=numTime-2;
end
for ii=1:length(dat)
  lineMarkPos{ii}=floor([a:floor(b-a)/numGuideLines:b]);
end
%% track these guide lines into upsampled, aligned space
for ii=1:length(dat)
  lineMarkPos2{ii}=st(ii,lineMarkPos{ii},2);
end


if ~showAlignedOnly
    figure,showMS(dat,1,win,lineMarkPos); 
    title(['Unaligned ' exptxt]);
    set(gca,'XGrid','on','GridLineStyle',':','XColor','k');
end

%% we want the window in this case to start somewhere
%% near where the the originals map to in the new space,
%% and to be the same length (ie timeRatio * length)

win2=win;
%% now find where beginning of win1 maps to in the first
%% sample
win2(1)=st(1,win(1),2);
%% now just make window same length (module time sampling)
win2(2)=win2(1)+G.timeRatio*(win(2)-win(1))-1;
if win2(2)>size(alignQMZ{1},1)
    error('This window is too large in time');
end

drawColorbar=1;
figure,showMS(alignQMZ,1,win2,lineMarkPos2,G.timeRatio,SHOW_DIFF,...
    drawColorbar);

thisFig=gcf;

if SHOW_DIFF
    figure(thisFig-1);
else
    figure(thisFig);
end
title(['Aligned ' exptxt]);
set(gca,'XGrid','on','GridLineStyle',':','XColor','k');
ylabel('Latent Time');

if SHOW_DIFF
    figure(thisFig);
    title(['Difference in Aligned ' exptxt]);
    set(gca,'XGrid','on','GridLineStyle',':','XColor','k');
    ylabel('Latent Time');
end

return;




