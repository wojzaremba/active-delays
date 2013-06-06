function [diagX, offDiag, b] = getZterms(G,ubar2,samplesMat,...
    allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,...
    binNum,tempSigs);

%%%%%%%%%%%%%%%%%
if ~G.USE_CPM2
    u2=G.u.^2;
else
    u2 = G.uMat.^2;
end

M=G.numTaus;
C = G.numClass;
diagX = -4*G.lambda*ones(M,C);
%% correct the boundary conditions
diagX(1,:) = diagX(1,:) +2*G.lambda;
diagX(M,:) = diagX(M,:) +2*G.lambda;
diagX = diagX.*repmat(ubar2,[M 1]);

b = zeros(M,C);
offDiag = zeros(M-1,C);
for cc=1:C
  offDiag(:,cc) = 2*G.lambda*ubar2(cc);
end        

if ~G.USE_CPM2

    for cc=1:G.numClass
        for kk=G.class{cc} %these are the data sets in that class
            for jj=1:G.numTaus
                validStates=allValidStates{jj};
                numVal=length(validStates);

                %%%% X(j,j)
                termJJ = u2(kk)*tempSigs(kk)*(scaleFacsSq{jj}*gammaSum1{kk,jj});
                diagX(jj,cc) = diagX(jj,cc) - termJJ;

                %%%% b
                termJM = G.u(kk)*tempSigs(kk)*(scaleFacs{jj}*gammaSum2{kk,jj});
                b(jj,cc) = b(jj,cc) + termJM;
            end
        end
    end

else
    %% USING CPM2, u_k become u_kt (uMat)    
    for cc=1:G.numClass
        for kk=G.class{cc} %these are the data sets in that class
            for jj=1:G.numTaus
                validStates=allValidStates{jj};
                numVal=length(validStates);
                %% for CPM2,there will only be one 'valid' state
                %% because only one state maps to a particular hidden
                %% time state                
                
                %%%% X(j,j)
                %termJJ = u2(kk,binNum,validStates)*tempSigs(kk)*...
                termJJ = u2(kk,validStates)*tempSigs(kk)*...
                    (scaleFacsSq{jj}*gammaSum1{kk,jj});
                diagX(jj,cc) = diagX(jj,cc) - termJJ;

                %%%% b                               
                %termJM = G.uMat(kk,binNum,validStates)*tempSigs(kk)*...
                termJM = G.uMat(kk,validStates)*tempSigs(kk)*...
                    (scaleFacs{jj}*gammaSum2{kk,jj});
                b(jj,cc) = b(jj,cc) + termJM;
            end
        end
    end

end


