% function [f,d] = zFunction(z,G,offDiag,diagX,b,lambda,nu)
%
% calculates the vector function, f, for fsolve in order to solve
% the non-linear system of equations
% 
% In terms of our specific problem, this function is computing
% the partial derivative and the Hessian of the expected
% complete log likelihood during the M-Step
%
% d is the jacobian of f, to be given to fsolve
% f has dimensions [1,M]
% d has dimensions [M,M]


%function [f,d] = zFunction(z,G,offDiag,diagX,b,lambda,nu,binNum)
%function [f] = zFunction(z,G,offDiag,diagX,b,lambda,nu,ubar2,binNum)
function [f, allTerms] = zFunction(z,G,offDiag,diagX,b,lambda,nu,ubar2,binNum)

% if G.useLogZ==1, then we are *still* passing z from z2Function, 
% so no need to exponentiate

C=G.numClass;
M=G.numTaus;
varsigma=G.varsigma;
%index goes c1m1, c1m2, ..., c1mM, ..., cCm1, ..., cCmM
z=reshape(z,[M,C]); 

f=zeros(M,C); %string the out into a column vector afterwards

for cc=1:C
  baseTerm  = b(:,cc) + z(:,cc).*diagX(:,cc);
  %oneUpTerm = z(2:end,cc)*offDiag(1,cc);
  %oneDownTerm = z(1:(end-1),cc)*offDiag(1,cc);
  offDiagTerm = z(:,cc)*offDiag(1,cc);
  
  f(1,cc) = baseTerm(1) + offDiagTerm(2);
  f(M,cc) = baseTerm(M) + offDiagTerm(M-1);
  f(2:(M-1),cc) = baseTerm(2:(M-1)) + offDiagTerm(3:M) + offDiagTerm(1:(M-2));

  %% the nu terms:
  nextTerm = zeros(M,1);
  nextTerm2=0; %% new as of Aug. 28, 2006.
  for c2=[(1:(cc-1)) ((cc+1):C)] %setdiff(1:C,cc)
    zDiff = z(:,cc)-z(:,c2);
    zDiff2=zDiff.*zDiff;
    nextTerm  = nextTerm + (1 + zDiff2./varsigma(binNum)).^(-1);
    nextTerm2 = (2.*zDiff./varsigma(binNum));
  end
  nt = -nu*(nextTerm.*nextTerm2);

  %% the lambda terms:  (This is ALREADY calculated, inside of diagX, offDiag
  %% use for debugging
  if (1)
  %if (cc==2)
    lambdaTerm = zeros(M,1);
    lambdaTerm(2:(M-1)) = 4*z(2:(M-1),cc) -2*z(3:M,cc) -2*z(1:(M-2),cc);
    %% correct boundaries
    lambdaTerm([1 M])=  2*z([1,M],cc) -2*z([2,(M-1)],cc);
    %% multiply by rest
    lambdaTerm = -G.lambda*ubar2(cc)*lambdaTerm;
  
    %% figure out pressure from each part:
    %% actually want negative of these derivatives (see z2Function)
    totalWght = -(f(:,cc) + nt);
    mainFrac = -(f(:,cc) - lambdaTerm);
    lambdaFrac = -lambdaTerm ;
    nuFrac = -nt;
  
    allTerms{cc,1}=totalWght;
    allTerms{cc,2}=mainFrac;
    allTerms{cc,3}=lambdaFrac;
    allTerms{cc,4}=nuFrac;

    if (0)
        rg{2} = [540 600];
        %rg{2} = [569 571];
        rg{1} = [1 1632];

        for gg=1:2
            allAx = splitAxes(6,1,'',0.05);
            axes(allAx{1}); plot(totalWght,'MarkerSize',2); title('total');
            xaxis(rg{gg});
            axes(allAx{2}); plot(mainFrac,'MarkerSize',2); title('main');
            xaxis(rg{gg});
            axes(allAx{3}); plot(lambdaFrac,'MarkerSize',2); title('lambda');
            xaxis(rg{gg});
            axes(allAx{4}); plot(nuFrac,'MarkerSize',2); title('nu');
            xaxis(rg{gg});
            axes(allAx{5}); plot(z(:,2),'MarkerSize',2); title('z,class 2');
            xaxis(rg{gg});
            axes(allAx{6}); plot(z(:,1),'MarkerSize',2); title('z,class 1');
            xaxis(rg{gg});
        end
        warning('zFunction'); keyboard;
    end
  end

  f(:,cc) = f(:,cc) + nt;
end

f=f(:);


%if (G.useLogZ)
  q=log(z(:));
  vecZ=z(:);
  %% because of change of variables, z=log(q)
  %display('line 89 zFunction'); keyboard;
  f2=f.*vecZ;
%else
%  f2=f;
%end

f=f2;

%if (any(~isfinite(f)))
%  display('zFunction not returning all finite values for f');
  %keyboard;
%end







return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OLD, inefficient way
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=zeros(M,C); %string the out into a column vector afterwards
if (needHess)
  error('Have not updated u^{f2} type stuff');
  d=sparse(M*C,M*C);
end

for cc=1:C
  for jj=1:M
    %% Stuff for f %% objective function (gradient)
    f(jj,cc) = b(jj,cc) + z(jj,cc)*diagX(jj,cc);

    if (jj<M)
      %% NOTE that we use offDiag(1,cc) because unique(offDiag(:,cc))=1
      f(jj,cc) = f(jj,cc) + z(jj+1,cc)*offDiag(1,cc);
    end
    
    if (jj>1)
      f(jj,cc) = f(jj,cc) + z(jj-1,cc)*offDiag(1,cc);
    end
    
    %% Stuff for d - Jacobian of f (Hessian of original problem)
    if (needHess)
      eqInd  = (cc-1)*M + jj;    
      d(eqInd,eqInd) = diagX(jj,cc);
      if (jj>1)
	d(eqInd,eqInd-1) = 2*lambda;
      end
      if (jj<M)
	d(eqInd,eqInd+1) = 2*lambda;
      end
    end
    
    nt=0;
    newDiagTerm = 0;
    for c2=setdiff(1:C,cc)
      %if (c2~=cc)
	%% Stuff for f 
	zDiff=z(jj,cc)-z(jj,c2);
	zDiff2=zDiff*zDiff;
	
	%display('zFunction'); keyboard;
	
	nextTerm  = (1 + zDiff2/varsigma(binNum))^(-1);
	nextTerm2 = (2*zDiff/varsigma(binNum));
	nt=nt + nextTerm*nextTerm2;
      
	%% Stuff for d
	if (needHess)
	  t1 = nextTerm;
	  t2 = 2/varsigma(binNum);
	  t3 = -1*nextTerm2^2;
	  t4 = t1^2;
	  newDiagTerm = newDiagTerm + (t1*t2 + t3*t4);	
	  classInd = (c2-1)*M + jj;
	  d(eqInd,classInd) = -nu*(t1*-t2 - t3*t4);
	end
      %end
    end
    nt=nt*-nu; %for f
    f(jj,cc) = f(jj,cc) + nt;
    if (needHess)
      newDiagTerm = newDiagTerm*-nu;
      d(eqInd,eqInd) = d(eqInd,eqInd) + newDiagTerm;
    end
  end
end

f=f(:);

%keyboard;

if (G.useLogZ)
  q=log(z(:));
  vecZ=z(:);
  %% because of change of variables, z=log(q)
  %display('line 89 zFunction'); keyboard;
  f2=f.*vecZ;

  if (needHess)
    changeVarBoth = vecZ'*vecZ;
    d = d.*changeVarBoth + sparse(diag(f.*vecZ));
  end
else
  f2=f;
end

f=f2;

if (any(~isfinite(f)))
  display('zFunction not returning all finite values for f');
  %keyboard;
end
