% function [tt aa]=getAlignment(dpMat,bestPath,d1,d2);
% 
% does the traceback for dynamic programming, returning
% an alignment that is the equivalent of:
%
% tt is the resulting alignment (2,length(alignment)):
%
% HEAGAWGHE-E    for proteins
% --P-AW-HEAE
%
% except we are aligning header scans 1:L1, 1:L2:
% eg. 
% 1 2 3 - 4 5 6 -
% - - 1 2 3 4 5 - 
%
% bestPath is L1 x L2 x 2, where L1 and L2 are the
% dimensions of the two sequences
%
% currently, gaps are filled in with the mean value of
% what lies on either side.  (probably mean of several
% values to get rid of noise.
%
% tt contains the aligned values (interpolated)
% aa contains the aligned indexes used to create tt


function [ttnew, aa]=getAlignment(bestPath,dd1,dd2);

L1=length(dd1); L2=length(dd2);
gapSymbol=0;

maxNumMoves=L1+L2;
t1=-999*ones(1,maxNumMoves);  t2=-999*ones(1,maxNumMoves); 
a1=-999*ones(1,maxNumMoves);  a2=-999*ones(1,maxNumMoves); 

keepGoing=1; 
seqDone=0;  %keeps track of which sequence finished first
currInd1=L1;  currInd2=L2;  %place in matrix backtracking from
out1=L1;      out2=L2;      %index from sequence that we need to
                            %output next
alignPos=L1+L2; % work backwards, filling in the alignment
while (keepGoing)  
  if (currInd1==0)  %finished aligning this sequence
    keepGoing=0;
    seqDone=1;
    if (currInd2==0)
      seqDone=3;
    end
  elseif (currInd2==0) %finished aligning this sequence
    keepGoing=0;
    seqDone=2;
  end

  if (keepGoing)
    previousPlace=squeeze(bestPath(currInd1,currInd2,:));
    change=[currInd1;currInd2]-previousPlace;
    if (change(1)==1 & change(2)==1)
      %add a symbol from each sequence
      t1(alignPos)=dd1(out1); t2(alignPos)=dd2(out2);
      a1(alignPos)=out1; a2(alignPos)=out2;
      out1=out1-1; out2=out2-1;
    elseif (change(1)==1 & change(2)==0)
      %add a symbol and a gap
      t1(alignPos)=dd1(out1); t2(alignPos)=gapSymbol;
      a1(alignPos)=out1; a2(alignPos)=gapSymbol;
      out1=out1-1; 
    elseif (change(1)==0 & change(2)==1)
      %add a symbol and a gap
      t1(alignPos)=gapSymbol;      t2(alignPos)=dd2(out2);
      a1(alignPos)=gapSymbol;      a2(alignPos)=out2;
      out2=out2-1; 
    else
      change
      previousPlace
      [currInd1;currInd2]
      [out1 out2]
      alignPos
      error('something not working!');
    end
    alignPos=alignPos-1;
    currInd1=previousPlace(1); %tracing backwards
    currInd2=previousPlace(2);
  end
end

if (seqDone==1)
  numLeft=out2;
  t2(alignPos:-1:alignPos-numLeft+1)=d2(out2:-1:1);
  t1(alignPos:-1:alignPos-numLeft+1)=gapSymbol;
  a2(alignPos:-1:alignPos-numLeft+1)=out2:-1:1;
  a1(alignPos:-1:alignPos-numLeft+1)=gapSymbol;
  alignPosNew=alignPos-numLeft+1;
elseif (seqDone==2)
  numLeft=out1;
  t1(alignPos:-1:alignPos-numLeft+1)=d1(out1:-1:1);
  t2(alignPos:-1:alignPos-numLeft+1)=gapSymbol;
  a1(alignPos:-1:alignPos-numLeft+1)=out1:-1:1;
  a2(alignPos:-1:alignPos-numLeft+1)=gapSymbol;
  alignPosNew=alignPos-numLeft+1;
elseif (seqDone==3)
  alignPosNew=alignPos+1;
else
  error('something gone wrong 2');
end
  
t1=t1(alignPosNew:end); t2=t2(alignPosNew:end);
a1=a1(alignPosNew:end); a2=a2(alignPosNew:end);

aa=[a1;a2];

% now interpolate to fill in the missing values
ttnew=interpolateMV([t1;t2],gapSymbol);



% a few sanity checks
if (0)
  clear missVals realVals;
  for seq=1:2
    missVals{seq} = find(tt(seq,:)==0);
    realVals{seq} = find(tt(seq,:)~=0);
    temp=realVals{seq};
    tt(seq,temp([1,end]))
   end

   dd1([1,end])
   dd2([1,end])
end

