function yBounds = getYbounds(x);

x=x(:);

ymin = min(x);
ymax = max(x);
mag = ymax-ymin;

fracExtra = 0.01;

y1= ymin - fracExtra*abs(mag);
y2= ymax + fracExtra*abs(mag);

yBounds = [y1 y2+eps];
