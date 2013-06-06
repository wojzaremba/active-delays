% function h = drawbox(lims, sty);
%
%lims = [xmin xmax ymin ymax];
%sty = line style (default is '-k');

function h = drawbox(lims, sty);
if nargin == 1; sty = '-k'; end;

hold on;
h1 = hline(lims(3:4), sty, lims(1:2));
h2 = vline(lims(1:2), sty, lims(3:4));
hold off;

if nargout == 1;
  h = [h1; h2];
end

