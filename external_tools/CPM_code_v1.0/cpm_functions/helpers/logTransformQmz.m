function qmz=logTransformQmz(qmz)

for k=1:length(qmz)
	tmp=qmz{k};
    tmp(find(tmp<=0))=eps;
    qmz{k}=log(tmp);
end


