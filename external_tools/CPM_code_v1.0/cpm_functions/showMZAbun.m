% function showMZAbun(mza,numDig,LOW)
%
% Displays the abundance at each mz slice.
% If a cell array is given, then it treats each one
% as a seperate plot on the same graph.
% 
% numDig has to do with how the mz data was quantized
% see quantizeMS() for more details

function showMZAbun(mza,numDig,LOW)

if (~(exist('numDig')==1))
    numDig=2;
end
if (~(exist('LOW')==1))
    LOW=400;
end

if (~iscell(mza))
    figure,plot(mza,'+-','MarkerSize',2);
else
    %then there are multiple things to plot
    myLeg=cell(1:length(mza));
    linespecs=getLineSpecs;
    figure,
    for jj=1:length(mza)
        myLeg{jj} = num2str(jj);
        plot(mza{jj},linespecs{jj},'MarkerSize',2);
        hold on;
    end
    legend(myLeg);
end

xlabel('Different M/Z Slices');
ylabel('Total Abundance Over All Scans');
title('Abundance At Each M/Z Slice');
    
labels=get(gca,'XTickLabel');
newLabels=str2num(labels)/numDig+LOW;
set(gca,'XTickLabel',newLabels);
