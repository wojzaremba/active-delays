%function linespecs = getLineSpecs(whatType)
%
% Returns a matrix of different line specs to be used when
% iteratively plotting on the same graph.
% 'whatType'=0 gives only marker points
% 'whatType'=1 gives lined/marker plots
% 'whatType'=2 gives line only plots
%
% default is whatType=1

function linespecs = getLineSpecs(whatType)

if (~exist('whatType'))
  whatType=0;
end


mycolours = {'b' 'r','k','g','m'};%,'y'};
mylines = {'-','--',':'};
mymark = {'^','o','x','+','<','>','p','h','d','v','s','.','*'};

nxt=1;
clear linespecs;

if (whatType==1)
    for ln=1:length(mylines)
        for mk=1:length(mymark)
            for cl=1:length(mycolours)
                linespecs{nxt}= [mycolours{cl} mymark{mk} mylines{ln}];
                nxt=nxt+1;
            end
        end
    end
elseif (whatType==2)
    for ln=1:length(mylines)
        for cl=1:length(mycolours)
            linespecs{nxt}= [mycolours{cl} mylines{ln}];
            nxt=nxt+1;
        end
    end

elseif (whatType==0)
    for mk=1:length(mymark)
        for cl=1:length(mycolours)
            linespecs{nxt}= [mycolours{cl} mymark{mk}];
            nxt=nxt+1;
        end
    end
end

%% have it cycle around in case need a huge number
%% lightspeed causes this to crash now
%linespecs = repmat(linespecs, [1 50]);

for j=1:5
    N=length(linespecs);
    linespecs((end+1):(end+N))=linespecs;
end

return;

