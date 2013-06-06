% function r = inv2(m)
%
% Quickly compute the inverse of a 2x2 matrix.

% If ad-bc \neq 0 then the matrix is nonsingular; 
% in this case its inverse is given by:
%
% inv   ( a b ) =  (d -b) * 1/(ad-bc)
%       ( c d )    (-c a)
    	
function r = inv2(m)

c = m(1,1)*m(2,2)-m(1,2)*m(2,1);
% if c<eps
%     error('Matrix is nearly singular');
% end
r=zeros(2);
r(1,1)=m(2,2);
r(1,2)=-m(1,2);
r(2,2)=m(1,1);
r(2,1)=-m(2,1);
r=r/c;

%r = [m(2,2) -m(1,2);
%    -m(2,1) m(1,1)]/c;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% test out how much faster it is

numTest=1e5;
for j=1:numTest
    a{j}=rand(2);
end

t=cputime;
for j=1:numTest
    inv(a{j});
end
tt=cputime;
disp(['Elapsed CPU time for built-in inv=' num2str(tt-t)]);


t=cputime;
for j=1:numTest
    inv2(a{j});
end
tt=cputime;
disp(['Elapsed CPU time for special inv=' num2str(tt-t)]);

