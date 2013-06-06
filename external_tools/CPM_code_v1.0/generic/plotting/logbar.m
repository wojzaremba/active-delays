function bh=logbar(x,y)
% Bar vertices have 0-values, this is no good when taking
% log...
% Find them and replace with a small value.
bh=bar(x,y);
v=get(get(bh,'Children'),'Vertices');
v(v==0)=.01; % You may want to change the value 0.01
set(get(bh,'Children'),'Vertices',v);
set(gca,'YScale','log') 