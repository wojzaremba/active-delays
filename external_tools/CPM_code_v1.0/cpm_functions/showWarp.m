% function garb = showWarp(warp,allSamp,newGKeep)
%
% show the results obtained from getLinearWarp which returns a
% new set of time scales with which to plot

function garb = showWarp(warp,allSamp,scaleAndTimes,newGKeep,newTrace)

fontSize=12;


if (0)
  figure,


  myAx2=axes('position',[0.13, 0.11,   0.775, 0.40]);
  myAx1=axes('position',[0.13, 0.40+0.11+0.02, 0.775, 0.4075]);
  
  %% Viterbi with no scaling:
  axes(myAx2);
  showScale=0;
  showAlignedAll(newGKeep,allSamp,scaleAndTimes,newTrace,showScale);
  title('');
  xlabel('Time','FontSize',fontSize);
  ylabel('Amplitude');

  axes(myAx1);
end



%% Linear Warp

%% find out how to make axis on warp
xAx = [realmax,realmin];
for kk=1:newGKeep.numSamples
  tmp = warp{kk};
  if (tmp(1)<xAx(1))
    xAx(1)=tmp(1);
  end
  if (tmp(end)>xAx(2))
    xAx(2)=tmp(end);
  end
end

ls = getLineSpecs(1);

for kk=1:newGKeep.numSamples
  tmp = allSamp{kk};
  plot(warp{kk},tmp,ls{kk},'MarkerSize',2);
  hold on;
end
tmpAx=axis; 
tmpAx(1:2)=xAx;
axis(tmpAx);

ylabel('Amplitude','FontSize',fontSize);
%xlabel('Time','FontSize',fontSize);
xlabel('');
set(gca,'XTick',[]);
mytitle= 'CPM Time Alignment Compared To Linear Warp with Offset';
title(mytitle,'FontSize',fontSize);
set(gca,'FontSize',fontSize);


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fontSize=12;
ls = getLineSpecs(1);

%% find out how to make axis on warp
xAx = [realmax,realmin];
for kk=1:newGKeep.numSamples
  tmp = warp{kk};
  if (tmp(1)<xAx(1))
    xAx(1)=tmp(1);
  end
  if (tmp(end)>xAx(2))
    xAx(2)=tmp(end);
  end
end

figure, 
nxt=1;
numPlots=3;

for kk=1:newGKeep.numSamples
  tmp = allSamp{kk}/newGKeep.u(kk);
  %tmp = allSamp{kk};
  if (0)
    subplot(newGKeep.numSamples,numPlots,nxt),
    nxt=nxt+1;
    plot(allSamp{kk},ls{kk},'MarkerSize',2);
    subplot(newGKeep.numSamples,numPlots,nxt),
    nxt=nxt+1;
    plot(warp{kk},tmp,ls{kk},'MarkerSize',2);
    tmpAx=axis; 
    tmpAx(1:2)=xAx;
    axis(tmpAx);
    if (numPlots==3)
      subplot(newGKeep.numSamples,numPlots,nxt),
      nxt=nxt+1;
      plot(scaleAndTimes(kk,:,2),allSamp{kk},ls{kk},'MarkerSize',2);
      tmpAx=axis; 
      tmpAx(1:2)=[1,newGKeep.numTaus];
      axis(tmpAx);
    end
  else
    plot(warp{kk},tmp,ls{kk},'MarkerSize',2);
  end
  hold on;
end

ylabel('Amplitude','FontSize',fontSize);
title('Linear Warp with Offset Correction','FontSize',fontSize);
set(gca,'FontSize',fontSize);
