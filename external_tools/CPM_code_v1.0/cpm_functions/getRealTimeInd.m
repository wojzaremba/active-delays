function realTmInd = getRealTimeInd(st,tmInd)

distToTime = abs(st(:,2)-tmInd);
[garb,realTmInd]=min(distToTime);
