function dat=changeAlignedMatToCell(x)

% change from multi-dim array to cell so that can
% use blurQmz()

K=size(x,3);
for k=1:K
    dat{k}=squeeze(x(:,:,k));
end