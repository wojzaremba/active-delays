function x = cell2matDefault(d)

[r c] = size(d{1});

f = length(d);

x = zeros(r,c,f);

for jj=1:f
    x(:,:,jj)=d{jj};
end