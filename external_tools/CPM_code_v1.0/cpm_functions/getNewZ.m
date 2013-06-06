% function [newZ,output,options,changeFlag] = getNewZ(G,ubar,lambda,nu,gammas,samples,allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2)
% 
% Computes update for latent trace(s).
% trainModel(1,1e-15,1e-15);

function [newZ,output,options,changeFlag] = getNewZ(G,samplesMat,...
    allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,...
    gammaSum5,gammaSum6,scalesExp,scalesExp2,binNum);

ubar2 = getUbar2(G,G.u); %% good for CPM2 as well

options=''; output='';
changeFlag=1;

ZTYPE=G.nuType;
%display(['ZTYPE=' num2str(ZTYPE)]);

binTrace = squeeze(G.z(:,:,binNum)); %start guess in EM
tmpSamples = squeeze(samplesMat(binNum,:,:));
tempSigs = G.sigmas(binNum,:).^(-2);

[diagX offDiag b] = getZterms(G,ubar2,samplesMat,allValidStates,...
    scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,binNum,tempSigs);

badFlag=0;

%% sometimes the 'exact' solver crashes, because the unconstrained ends of
%% the trace (unconstrained when lambda==0 and when no data gets mapped
%% there) and the solution matrix is singular.  A solution is to use a
%% very small, but non-zero value for lambda, or if not, then the code here
%% will move on to the iterative solver, which doesn not crash, and
%% presumably just doesn't give particularly meaningful (whatever that
%% means) results for these unconstrained ends.

%%%%%%%%%%%%%%%%%
useIterative=1; %% in case tridiag1 finds singular matrix
if G.numClass==1
    useIterative=0;
    [newZ, badFlag] = tridiag1(offDiag,diagX,offDiag,-b);
    if badFlag
        warning('tridiag1 found singular matrix, using iterative solver instead');
        useIterative=1;        
    end
elseif (G.nu==0) %then still analytic, each class seperately
    useIterative=0;
    newZ = zeros(size(binTrace));
    for cc=1:G.numClass
        [newZ(:,cc), badFlag] = tridiag1(offDiag(:,cc),diagX(:,cc),offDiag(:,cc),-b(:,cc));
        if badFlag           
            warning('tridiag1 found singular matrix, using iterative solver instead');
            useIterative=1;
            break;
        end
    end
    clear output;
    output.newZ=newZ;
    output.algorithm='analytic update';
    options='';
    return;
end

% if badFlag
%     error('Probably need to use lambda~=0 because some hiddne time states have no weight');
% end

if ZTYPE==1 && useIterative	%% cauchy-like penalty
  startGuess = binTrace(:);
  %startGuess = startGuess(randperm(length(startGuess)));    
  if G.useLogZ
    startGuess=log(startGuess);
  end
  
  scalesExpRep  = repmat(scalesExp,[G.numSamples 1]);
  scalesExp2Rep = repmat(scalesExp2,[G.numSamples 1]);

  if ~G.USE_CPM2
      u2=G.u.^2;
      u=G.u;
  else
      u2 = G.uMat.^2;
      u=G.uMat;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% check gradient with gracheck
  if 0
      e=1e-8;
      testZ = startGuess;
      %testZ=addNoise(startGuess);
      %testZ=addNoise(testZ);
      %% shouldn't be accessing this shit, so make it weird so
      %% that it crashes if it does
      tmpG=G;
      if 0
          tmpG.uMat=NaN*rand(99,99);
          tmpG.u=NaN*rand(99,99);
          tmpG.z=NaN*rand(99,99);
      end
      [d anal fd] = ...
          checkgrad('z2Function',testZ,e,...
          tmpG,offDiag,diagX,b,...
          tmpSamples,gammaSum1,gammaSum2,gammaSum5,gammaSum6,...
          tempSigs,u,u2,scalesExpRep,scalesExp2Rep,ubar2,binNum);
      dbstack;
      %keyboard;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if 0
      myTol=1e-5; %anything stricter 1e-1 gives error due to tiny steps
      options = optimset('GradObj', 'on', 'DerivativeCheck','off',...
          'TolFun',myTol,'Display','off','TolX',myTol,...
          'LargeScale',G.LargeScaleOn,'Diagnostics', 'off',...
          'TypicalX',binTrace(:),'MaxIter',G.fminuncMaxIter,...
          'MaxFunEvals',realmax,'Hessian',...
          G.HessianOn,'HessPattern',G.Jsparse);


      [newZ2, fval2, exitflag,output,grad]=...
          fminunc(@(z)z2Function(z,G,offDiag,diagX,b,...
          tmpSamples,gammaSum1,gammaSum2,gammaSum5,gammaSum6,...
          tempSigs,u,u2,scalesExpRep,scalesExp2Rep,ubar2,binNum),...
          startGuess,options);
  else
      numIter=50;
      [newZ, fval] = minimize(startGuess,'z2Function',numIter,...
          G,offDiag,diagX,b,...
          tmpSamples,gammaSum1,gammaSum2,gammaSum5,gammaSum6,...
          tempSigs,u,u2,scalesExpRep,scalesExp2Rep,ubar2,binNum);          
  end

  
  
  if G.useLogZ
    newZ=exp(newZ);
  end

  
  %keyboard; display('getNewZ ln 35');
  
  if max(abs(newZ-startGuess))==0
    %imstats(abs(newZ-startGuess));
    display('newZ is same as startGuess'); %keyboard;
    %output
    changeFlag=0;
  end
  
  %output
  
  if (exist('exitflag') & exitflag<0)% & exitflag~=-3) %-3 means trust region is too small
    exitflag
    display('Error flag from fsolve not good, see help fsolve');
    keyboard;
  elseif   (exist('exitflag') & exitflag==0)
    %warning('Exitflag==0, max iterations reached');
  end
  %[newZ, fval, exitflag,output,jacob]=fsolve2(@zFunction,startGuess,options,G,offDiag,diagX,b,G.lambda,nu);
  
  newZ = reshape(newZ,size(binTrace));
  %imstats(abs(newZ-binTrace));
  
elseif (ZTYPE==2) && useIterative %% simple log-quadratic penalty
  %% set up a system of equations by stacking the MxC stuff into
  %% vectors
  %
  % diagX:   numTaux X numClass
  % b:       numTaux X numClass
  % binTrace:   numTaux X numClass
  % offDiag: numTaus-1 X numClass, repeats along first dimension

  %display('getNewZ'); keyboard;
  numVar = G.numTaus*G.numClass;
  B = b(:); %stacks one on top of the other in right way
  X = sparse(numVar,numVar);
  for cc=1:G.numClass
    %% do all jj=1:M at once
    tmpM = sparse(G.numTaus,G.numTaus);
    tmpM = diag(diagX(:,cc));
    tmpM = tmpM + diag(offDiag(:,cc),1);
    tmpM = tmpM + diag(offDiag(:,cc),-1);
    nuConst = -G.nu*2*(G.numClass-1);
    tmpM = tmpM + diag(nuConst.*ones(1,G.numTaus));
    startInd = ((cc-1)*G.numTaus + 1);
    tempRange = startInd:(startInd+G.numTaus-1);
    X(tempRange,tempRange) = tmpM;
    for c2=1:G.numClass
      if (~(c2==cc))
	startInd2 = ((c2-1)*G.numTaus + 1); %first time
	tempRange2 = startInd2:(startInd2+G.numTaus-1);
	myInd = sub2ind(size(X),tempRange,tempRange2);
	X(myInd) = G.nu*2*ones(1,G.numTaus);
      end
    end
  end  
  % spy(X); %show(X)
  mysoln = (X\(-B));
  newZ = reshape(mysoln,[G.numTaus,G.numClass]); 
  %newZ2=newZ(:);  
end


%if (any(newZ(:)<=0) | any(~isfinite(newZ(:))))
if  any(~isfinite(newZ(:)))
  error('Some of new trace is zero, negative or infinite');
  if (0)
    imstats(newZ);
    figure, plot(binTrace,'-+','MarkerSize',2); title('traces');
    figure, plot(newZ,'-+','MarkerSize',2); 
    legend('1','2','3','4','5');
    title(['newZ \G.lambda=' num2str(G.lambda) '  \nu=' num2str(G.nu)]);
    
    negVals = any(newZ'<0);
    figure, bar(negVals); title('negative parts of newZ');
    figure, plot(newZ<0); title('negative parts of newZ');
    display('getNewZ error');
    find(newZ==0)
  end
elseif (any(isnan(newZ(:))))
  keyboard;
  display('NaNs in trace');
  imstats(newZ);
  imstats(b)
  figure, plot(newZ,'-+');
  display('getNewZ error');
  find(isnan(newZ))
end

return;
