function garb = showSegments(uu,segment);

numSeg=size(segment,1);
numSig = length(uu);

plot(uu,'c'); 
hold on;
myRange = max(uu)-min(uu);
barLength=myRange/5;
offset=20;

ls=getLineSpecs;

for jj=1:numSeg
  cl=ls{jj};
  cl=[cl(1) '+-'];
   %% segment
  tmpSeg = round(segment(jj,:));
  tmpSeg(1)=tmpSeg(1)+offset;
  tmpSeg(2)=tmpSeg(2)-offset;
  %errorbar(tmpSeg,[0,0],[barLength barLength],cl);
  plot(tmpSeg,[0,0],cl,'LineWidth',2,'MarkerSize',6);
end

