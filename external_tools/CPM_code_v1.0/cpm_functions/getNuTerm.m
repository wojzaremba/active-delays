function ll = getNuTerm(G)

%% this is so that when we have numBins>1, we can
%% call this function from z2Function, but have it only
%% operate on one bin, that provided in the variable 'traces'
%% here, in which case we set numBins=1.

traces=G.z;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (G.nu==0)
  ll = 0;
  return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%p%%%%%%%%%%%%%%%%%%
elseif (G.nuType==2) %simple log quadratic term
  error('shouldnt be here');
  ll = 0;
  for bb=1:numBins
    for c1=1:G.numClass
      for c2=1:G.numClass
	if (c2<c1)
	  ll = ll + sum((traces(:,c1,bb)-traces(:,c2,bb)).^2);
	end
      end
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (G.nuType==1) %cauchy-like penalty
  ll=0;
  for bb=1:G.numBins
    tmpVarsigma=G.varsigma(bb);
    for c1=1:G.numClass
      for c2=1:(c1-1)%G.numClass
	%if (c2<c1)
	  myDiff2 = (traces(:,c1,bb)-traces(:,c2,bb)).^2;
	  newTerm = sum(log(1 + myDiff2/tmpVarsigma));
	  ll = ll + newTerm;
	%end
      end
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ll = -G.nu*ll;
