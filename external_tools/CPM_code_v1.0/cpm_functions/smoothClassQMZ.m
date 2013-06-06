% function smoothQMZ = smoothClassQMZ(avgQMZ,mzBlock,timeBlock);
%
% smooths out a 2D 'image' of the time versus qmz, using mzBlock 
% m/z values, and timeBlock time values

function smoothQMZ = smoothClassQMZ(avgQMZ,mzBlock,timeBlock);

mzFilt = ones(1,mzBlock);
tmFilt = ones(timeBlock,1);
filt = tmFilt*mzFilt;
filt = filt./sum(sum(filt));

smoothQMZ = zeros(length(avgQMZ),size(avgQMZ{1},1),size(avgQMZ{1},2));

for cc=1:length(avgQMZ)
  smoothQMZ(cc,:,:) = conv2(avgQMZ{cc},filt,'same');
end

smoothQMZ=squeeze(smoothQMZ);
