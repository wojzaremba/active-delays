function myAx = showTraces(allSamp,newGKeep,scaleAndTimes,numPlots,IND)

newTrace=newGKeep.z;

if ~IND
    %myAx1=axes('Position',[0.13, 0.11, 0.775, 0.815]);
    if (numPlots==2)
        figure,
        myAx(2)=axes('position',[0.13, 0.11,   0.775, 0.40]);
        myAx(1)=axes('position',[0.13, 0.40+0.11+0.02, 0.775, 0.4075]);
    elseif (numPlots==3)
        figure,
        myHeight = 0.815/3;
        pos3 = 0.1; %space=0.02;
        space=0.04;
        pos2 = myHeight+ pos3 +space;
        pos1 = myHeight+ pos2 +space;
        width=0.775; offset=0.13;
        myAx(1)=axes('position',[offset, pos1, width, myHeight]);
        myAx(3)=axes('position',[offset, pos2, width, myHeight]);
        myAx(2)=axes('position',[offset, pos3, width, myHeight]);
    end
end

fs=18;

%keyboard;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display all before alignments
%subplot(numPlots,1,1),
if ~IND
    axes(myAx(1));
else
    figure,
end
showHeaderAbun(allSamp);
legend('off');

if (numPlots==2)
  myTit='Unaligned and Aligned Time Series';
elseif (numPlots==3)
  %myTit='Unaligned, Linear Warp Alignment and CPM Alignment';
  myTit='Unaligned, CPM Alignment (no scaling)';
end
%title(myTit);
title('');
%set(gca,'XTick',[]);
xlabel('');
set(gca,'FontSize',fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% display all after alignments, with the latent trace
%subplot(numPlots,1,2),
if ~IND
    axes(myAx(2));
else
    figure,
end

showScale=1;
%z=newTrace;
z=[];
showAlignedAll(newGKeep,allSamp,scaleAndTimes,z,showScale);
%set(gca,'XTick',[]);
%title('Aligned Experimental TICs');
%title('Aligned and Scaled Replicate Time Series');
title('');
if (numPlots==2)
  ylabel('Latent Space Amplitude'); 
elseif (numPlots==3)
  ylabel('Amplitude','FontSize',fs); 
end
xlabel('Time','FontSize',fs);
set(gca,'FontSize',fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display time correction OR linear warp
if (numPlots==3)
    if ~IND
        axes(myAx(3));
    else
        figure,
    end
  %set(gca,'XTick',[]);
  %% linear time warp
  if (0)
    linearWarp = getLinearWarp(allSamp,scaleAndTimes,newGKeep);
    showWarp(linearWarp,allSamp,scaleAndTimes,newGKeep,newTrace);
    title('');
  else  
      %% time correction but now scale corrections
      showScale=0;
      z=[]; %% don't show latent trace
      showAlignedAll(newGKeep,allSamp,scaleAndTimes,z,showScale);
      title('');
      xlabel('');
  end
  set(gca,'FontSize',fs);
end
