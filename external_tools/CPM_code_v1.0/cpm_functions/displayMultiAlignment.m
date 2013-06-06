% function nothing=displayMultiAlignment(G,allAxes,allSt,samples,slice)
% 
% Similar to displayAlignment, but shows multiple traces at at
% time on the same plot.

function nothing=displayMultiAlignment(G,...
    allAxes,allSt,samples,slice,scaleType)

useInset=0;

%lnsp = getLineSpecs(1);
lnsp = getLineSpecs(2);

if G.numBins==1
   [numRealTimes,numExp] = size(samples);
else
   [numRealTimes,numExp,numBins] = size(samples);
end

%% first draw the aligned traces
myLeg = cell(1,numExp);

if useInset
  axes(allAxes(1));
else
  %subplot(2,1,1),
  allAx=splitAxes(2,1);  
  axes(allAx{1});
end

mkSize=2.3;

%keyboard;

for ss=1:numExp
  st = squeeze(allSt(ss,:,:));
  if scaleType==0
      plot(st(:,2), samples(:,ss),lnsp{ss},'MarkerSize',mkSize);

  elseif ~G.USE_CPM2
      %plot(st(:,2), samples(:,ss)./(2.^(G.scales(st(:,1)))),...
      plot(st(:,2), samples(:,ss)'./(2.^(G.scales(st(:,1)))),...
          lnsp{ss},'MarkerSize',mkSize);
  else
      disp('using scaling spline');
      tmpU = G.uMat(ss,st(:,2));
      plot(st(:,2)', samples(:,ss)'./tmpU,lnsp{ss},'MarkerSize',mkSize);      
  end
  myLeg{ss}=num2str(ss);
  hold on;
end

if exist('slice')==1 && ~isempty(slice)
    title(['Aligned Slice - M/Z: ' num2str(slice)]);
else
    title('Aligned');
end
axis('auto');
bounds = axis;
%axis([0 900 0 13*10^8]);
ylabel('Abundance');
xlabel('Upsampled Experimental Time');
hold off;
%axis([0 350 0 12*10^8]);

%% now draw an inset of the unaligned traces
if (useInset)
  axes(allAxes(2));
else
  %subplot(2,1,2),
  axes(allAx{2});
  ylabel('Abundance');
  xlabel('Experimental Time');
end

for ss=1:numExp
  plot(1:numRealTimes,samples(:,ss),lnsp{ss},'MarkerSize',mkSize);
  hold on;
end
%legend(myLeg,'Location','NorthWest');
%legend(myLeg);
if exist('slice')==1
   title(['Unaligned Slice']);
else
   title(['Unaligned']);
end
axis('auto');
bounds = axis;
%axis([0 900 0 13*10^8]);
%ylabel('Abundance');
%xlabel('Experimental Time');
hold off;

%keyboard;

return;



