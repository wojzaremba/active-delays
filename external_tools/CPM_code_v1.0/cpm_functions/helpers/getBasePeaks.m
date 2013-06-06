function basePeaks = getBasePeaks(qmz)

basePeaks = cell(size(qmz));

for ss=1:length(qmz)
    tmp = qmz{ss};
    basePeaks{ss} = sum(tmp,2)';
end

return;


figure,showHeaderAbun(basePeaks);