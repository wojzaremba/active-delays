function  dat=reverseLogTransformQmz(dat)

for k=1:length(dat)
	tmp=dat{k};
    dat{k}=exp(tmp);
end

