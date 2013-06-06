% nothing=displayAlignment(G,allAxes,st,sample,mytitle,...
%    sampleNum,DETAILS,noScale)
% 
% Displays trace alignment before, after, and the scale states,
% using a particular figure format.  allAxes should contain the 
% handles: allAxes=[scaleAx,mainAx,insetAx];


function nothing=displayAlignment(G,allAxes,st,sample,mytitle,...
    sampleNum,DETAILS,noScale)

if exist('noScale') && noScale
  neutralScale = find(G.scales==0);
  st(:,1)=neutralScale;
end

if G.numBins>1
  error('Only works for numBins=1 right now');
end

myClass = getClass(G,sampleNum);
newTrace =squeeze(G.z(:,myClass));

% if sampleNum==2
%     keyboard;
% end

if ~exist('DETAILS')
  DETAILS=0; %whether or not numbers are printed
end
fontSize=12;
fs2=8;

numAxes=length(allAxes);

%warning('h'); keyboard;

tempA=sample;

if ~G.USE_CPM2
    tempB=G.u(sampleNum)*2.^(G.scales(st(:,1)));
else
    tempB=G.uMat(sampleNum,st(:,2));
end
tempC=tempA(:)./tempB(:);
myMu=newTrace(st(:,2))';

myMax=max([tempC',newTrace',tempA]);
myaxis1=[0 G.numTaus 0 myMax];
myaxis2=[0 G.numTaus 0 myMax];

%% Draw the aligned trace
axes(allAxes(1));
plot(newTrace,'.r-','MarkerSize',6); 
set(gca,'FontSize',fontSize);
hold on; 
plot(st(:,2)',tempC,'k-+','MarkerSize',2,'LineWidth',0.75);
myLeg={'Latent Trace','Aligned Experimental Time Series'};

%% draw the single noiseLevel for the whole trace
binNum=1;
noiseLevel=G.sigmas(binNum,sampleNum);
if DETAILS
    errorbar(G.numTaus-20,myMax/3,noiseLevel/2,'k');
    mytxt = ['\sigma=' num2str(noiseLevel,2)];
    text(G.numTaus-120,myMax/3,mytxt,'FontSize',fontSize);
    %myLeg{end+1} = 'Noise Level';
end

hold off;
lg=legend(myLeg);
set(lg,'FontSize',11);
legend boxoff;
title(mytitle);
axis(myaxis1);
ylabel('Amplitude');

bounds = axis;    
myXTick=100:100:G.numTaus;
set(gca,'XTick',myXTick);  
set(gca,'XTickLabel',myXTick);  

%% Draw an inset of the unaligned trace
if (numAxes==2|numAxes==5)
    if (numAxes==2)
        axes(allAxes(2));
    elseif (numAxes==5)
        axes(allAxes(5));
    end
    %plot(newTrace,'.r-','MarkerSize',1.5);
    %hold on; 
    plot(1:G.timeRatio:G.timeRatio*length(sample),sample,'k-'); %,'k-+','MarkerSize',1.5);
    %legend('Latent Trace','Unaligned Sample Trace');
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
    txt='Original Time Series';    
    text(0.02,0.9,txt,'Units','Normalized','FontSize',10);
    hold off;
    axis(myaxis2);
end

%% Now draw the scale states
if numAxes>=4
    axes(allAxes(2));
    if ~G.USE_CPM2
       plot(st(:,2)',G.scales(st(:,1)),'k-','MarkerSize',1,'LineWidth',2); 
    else       
       plot(st(:,2)',tempB,'k-','MarkerSize',1,'LineWidth',2); 
       %% also plot control points
       hold on;
       tmpP = G.cntrlPts;
       plot(tmpP,G.uMat(sampleNum,G.cntrlPts),'b+','MarkerSize',5,'LineWidth',2);
    end
    xlabel('');  
    %text(0.02,0.85,'Scale States','Units','Normalized','FontSize',6);
    %text(0.02,0.55,['p(\tau_i|\tau_i)=' num2str(G.S,2)],'Units','Normalized','FontSize',6);
    tmpStr = ['p(\tau_i=j|\tau_{i-1}=j)=' num2str(G.S,2)];
    
    if DETAILS
        %xcoord=0.01;ycoord=0.80;
        xcoord=0.01;ycoord=0.70;
        if ~G.USE_CPM2
            text(xcoord,ycoord,['Scale States, ' tmpStr],'Units','Normalized','FontSize',6);
        else
            text(xcoord,ycoord,['Interpolated Scaling Spline'],'Units','Normalized','FontSize',6);
        end
        %% display G.u
        %xcoord=0.02;ycoord=0.35;
        xcoord=0.02;ycoord=0.25;
        if ~G.USE_CPM2
            text(xcoord,ycoord,['u_k=' num2str(G.u(sampleNum),2)],'Units','Normalized','FontSize',6);
        else
            meanScale = exp(mean(log(tempB)));
            text(xcoord,ycoord,['average scaling=' num2str(meanScale,2)],'Units','Normalized','FontSize',6);
        end
    else
        text(0.01,0.65,['Scale States'],'Units','Normalized','FontSize',fontSize);
    end
    tmpAxis=axis;
    tmpAxis(1:2)=bounds(1:2);
    %tmpAxis(3:4)=[2^G.scales(1),2^G.scales(end)];
    %tmpAxis(3:4)=log2(G.u(sampleNum)) + [G.scales(1),G.scales(end)];
    if ~G.USE_CPM2
        tmpAxis(3:4)= [G.scales(1),G.scales(end)];    
    end
    if G.oneScaleOnly && ~G.USE_CPM2
        slack=0.01;
        tmpAxis(3) = tmpAxis(3)-slack;
        tmpAxis(4) = tmpAxis(4)+slack;
    end
        
    %tmpAxis;    
    axis(tmpAxis);
    set(gca,'XTick',myXTick);  
    set(gca,'XTickLabel',[]);
    set(gca,'FontSize',4);  
    %% draw a line at the neutral scale
    hold on;
    plot(st(:,2)',zeros(size(st,1),1),'k:','LineWidth',1); 
    hold off;    
         
    %log2(G.u(sampleNum));
    %[G.scales(1),G.scales(end)];
    %myYTick = log2(G.u(sampleNum)) + [G.scales(1),G.scales(end)];
    myYTick = [G.scales(1+1),0,G.scales(end-1)];
    myYTickF = [2^G.scales(1+1),2^0,2^G.scales(end-1)];
    if G.oneScaleOnly && ~G.USE_CPM2
        myYTick = [(G.scales(1)-slack),(G.scales(end)+slack)];
    end
    %myYTick = [myYTick(1),0,myYTick(2)];
    %format the tick labels
    if ~G.USE_CPM2
        myYTickF = sprintf('%.1f|',myYTickF);
        set(gca,'YTick',myYTick);
        set(gca,'YTickLabel',myYTickF);
%         if ~DETAILS
%             set(gca,'YTickLabel',[]);
%         end
    end
    xlabel('Latent Time','FontSize',fontSize);
    myXTick=200:200:G.numTaus;
    set(gca,'XTick',myXTick);
    set(gca,'XTickLabel',myXTick);
    %set(gca,'FontSize',fontSize);
    set(gca,'FontSize',fs2);
end

%% for sanity check, calculate residuals from viterbi
%% alignment to see if comparable to M-step error estimate
%avgSquareResidual = sum((tempC'-myMu).^2)/length(tempC);
%avgSquareResidual^(0.5);

%% Now draw the error from latent trace
if (numAxes>=4)
    axes(allAxes(4));
    DRAW_NOISE=1;
    if (DRAW_NOISE)
      %% draw the noise at each point
      bar(st(:,2)',abs(tempC'-myMu),'k');
      xlabel('');  
      text(0.01,0.65,'Residual','Units','Normalized','FontSize',fontSize);
    else %draw emission probability        
      myErr = (lognormpdf2(tempC',myMu,noiseLevel));    
      plot(st(:,2)',myErr,'b-','LineWidth',1);
      %bar(st(:,2)',myErr,'k');
      xlabel('');  
      text(0.02,0.8,'Log Emission Probability Density','Units','Normalized','FontSize',6);
    end
    tmpAxis=axis;
    tmpAxis(1:2)=bounds(1:2);
    %tmpAxis(3:4)=[2^G.scales(1),2^G.scales(end)];
    axis(tmpAxis);
    set(gca,'XTick',myXTick);  
    set(gca,'XTickLabel',[]);
    set(gca,'FontSize',4);  
    
    if (~DETAILS)
      set(gca,'YTickLabel',[]);
    end
end

%% draw time jumps
if (numAxes>=4)
    axes(allAxes(3));
    myTimeJumps = diff(st(:,2))';
    %myMark='k-';
    myMark='ks';
    plot(st(2:end,2)',myTimeJumps,myMark,'MarkerSize',2,'LineWidth',1,'MarkerFaceColor','k'); 
  if (DETAILS)
    text(0.01,0.7,'Time Jump From Previous State','Units','Normalized','FontSize',6);
    text(0.02,0.3,['d^k_v =' sprintf(' 	%.2f ',G.D(sampleNum,:))],'Units','Normalized','FontSize',6);
  else
    text(0.01,0.7,'Time Jump From Previous State','Units','Normalized','FontSize',fontSize);
  end
  tmpAxis=axis;
  tmpAxis(1:2)=bounds(1:2);
  tmpAxis(3:4)=[0.5,3.5];
  axis(tmpAxis);
  set(gca,'XTick',myXTick);  
  set(gca,'XTickLabel',[]);
  set(gca,'FontSize',8);  
  if (~DETAILS)
    %set(gca,'YTickLabel',[]);
  end
end

 
