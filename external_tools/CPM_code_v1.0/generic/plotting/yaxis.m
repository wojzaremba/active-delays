% function garb = yaxis(a)
%
% Similar to axis, but keeps -axis the same, and only changes
% y-axis, for current figure,

function garb = yaxis(a)

ax = axis;
ax(3:4) = a(:)';
axis(ax);

garb='';
return;
