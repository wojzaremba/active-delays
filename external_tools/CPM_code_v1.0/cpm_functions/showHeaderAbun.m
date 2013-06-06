% function showHeaderAbun(headerAbun, keepScans, 
%          pauseDelay, imConfig, axisVals);
%
% Displays the abundance at each scan header.
% If a cell array is given, then it treats each one
% as a seperate plot on the same graph.
%
% keep scans will delimit the plots with vertical bars at
% the beginnig and end of the keepScans
%
% If pauseDelay is provided, then a pause of that many seconds
% will exist between plots.  If pauseDelay='user', then
% it wait for the user to hit a key.
%
% imconfig = [numrows, numcols], plots are drawn, as many
% as possible, on one figure, until numrows x numcols is
% surpassed, etc.

function showHeaderAbun(ha, keepScans, pauseDelay, imc, axisVals)

fontSize=18;
mkrsize=3;

if exist('pauseDelay')~=1
  pauseDelay=0;
end

if ~exist('keepScans')| isempty(keepScans)
  keepScans=1:length(ha{1});
end

if exist('imc')~=1
  useConfig=0;
  numRow=0; numCol=0;
else
  useConfig=1;
  numRow=imc(1); numCol=imc(2);
end

%font size for plot
if (numRow*numCol>4)
  FS=8;
else
  FS=14;
end
  
myLeg=cell(1,length(ha));
linespecs=getLineSpecs(1);
%linespecs=getLineSpecs(2);
% for j=1:30%length(linespecs)
%     linespecs{j}='b-';
% end
current=1;
for jj=1:length(ha)

  %myLeg{jj} = ['Rep. ' num2str(jj)];
  myLeg{jj} = [num2str(jj)];

  %% if we need to start a new figure
  if mod(current,numRow*numCol)==1 & current~=1 & useConfig
      figure,
      current=1;
  end
  
  if useConfig
    subplot(numRow,numCol,current);
    plot(ha{jj},linespecs{jj},'MarkerSize',mkrsize);
    %plot(ha{jj},'k-','MarkerSize',mkrsize);
    set(gca,'FontSize', FS);
    if current==1
      xlabel('Experimental Time');
      ylabel('Amplitude');
      title('Amplitude','FontSize',fontSize);
    end
    hx=legend(myLeg{jj});
    set(hx,'FontSize',4);

  else
    plot(ha{jj},linespecs{jj},'MarkerSize',mkrsize);
    hold on;
  end

  current=current+1;
  
  if exist('axisVals')
    axis(axisVals);
  else
    myMax=max(cell2mat(ha));
    myLength=length(ha{1});
    tmp=axis; tmp(1:2)=[1,myLength]; tmp(4)=myMax*1.05; axis(tmp);    
  end

  if isnumeric(pauseDelay)
    pause(pauseDelay);
  else
    pause;
  end
end

if ~useConfig
  hx=legend(myLeg);
  xlabel('Experimental Time','FontSize',fontSize);
  ylabel('Amplitude','FontSize',fontSize);
  title('Total Ion Count','FontSize',fontSize);
  minVal = min(ha{jj}); maxVal = max(ha{jj}); 
  tempLS='m--';
  
  set(gca,'FontSize',fontSize);
end

hold off;

%legend off;


