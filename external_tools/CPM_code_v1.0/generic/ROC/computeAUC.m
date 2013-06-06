%% function AUC = computeAUC(w)
%%
%% compute the AUC, assuming that:
%% y=w(:,1);
%% x=w(:,2);
%% or... computeAUC([yVec;xVec]);
%%
%% 

function AUC = computeAUC(w)

y=w(:,1);
x=w(:,2);

%% make sure x's are in increasing order
[sortVal sortInd]=sort(x,'ascend');
x=x(sortInd);
y=y(sortInd);

%% figure, plot(x(1:5),y(1:5))
%% figure, plot(x,y);

numChunks = length(x)-1;
total = 0;

%% calculate from left->right SAME AS smallest->biggest
for ch = 2:numChunks
    ch1 = ch-1;
    ch2 = ch;
    width = x(ch2)-x(ch1);
    height = mean(y(ch1:ch2));
    contrib = width*height;
    total = total + contrib;
end

AUC = total;