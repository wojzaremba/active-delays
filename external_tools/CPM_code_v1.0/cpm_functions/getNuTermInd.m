function ll = getNuTermInd(G,traces,binNum)

%% need trace here because we do NOT want G.z
%%
%%  seems that this has no dependence on u as currently written.
%%  that is ok.
%%
%% Same as getNuTerm, but works only one of the bins, as 
%% specified by binNum.  Only the one bin exists in the variable
%% traces

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if G.nu==0
  ll = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif G.nuType==2 %simple log quadratic term

  ll = 0;
  bb=1
  for c1=1:G.numClass
    for c2=1:G.numClass
      if (c2<c1)
	ll = ll + sum((traces(:,c1,bb)-traces(:,c2,bb)).^2);
      end
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif G.nuType==1 %cauchy-like penalty
  ll=0;
  bb=1;
  tmpVarsigma=G.varsigma(binNum);
  for c1=1:G.numClass
    for c2=1:(c1-1)
      myDiff2 = (traces(:,c1,bb)-traces(:,c2,bb)).^2;
      newTerm = sum(log(1 + myDiff2/tmpVarsigma));
      ll = ll + newTerm;
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ll = -G.nu*ll;
