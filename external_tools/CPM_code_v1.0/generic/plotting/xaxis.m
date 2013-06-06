% function garb = xaxis(a)
%
% Similar to axis, but keeps -axis the same, and only changes
% y-axis, for current figure,

function garb = xaxis(a)

ax = axis;
ax(1:2) = a(:)';
axis(ax);

garb='';
return;
