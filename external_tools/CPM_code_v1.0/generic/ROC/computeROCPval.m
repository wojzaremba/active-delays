% function p = computeROCPval(y,x,yc,xc)
%
% Use two-sided Wilcox paried rank sign test to see if
% two ROC curves are statistically different.
%
% y,x are data from one ROC, and yc,xc from the other
%
% method: merge together all possible x values (to form a general
% domain), then interpolate where necessary so that each ROC curve
% has a corresponding y-value; then apply the statistical test
%
% however, the smarter thing to do might be to take the intersection of
% the two domains so that we are not artificially obtaining more evidence
%
% to do the latter, make sure USE_INTERSECT=1

function p = computeROCPval(y,x,yc,xc)

USE_INTERSECT=1;

y=y(:);
x=x(:);
yc=yc(:);
xc=xc(:);

unx = unique(x);
unxc = unique(xc);
if ~USE_INTERSECT
    disp('Using union of domains');
    domx = union(unx,unxc);
else
    disp('Using intersection of domains');
    domx = intersect(unx,unxc);
end

%% now for each of these allX we need to have a corresponding
%% y value, using the 'lowest y-values consistent with the
%% discrete points available'
numX = length(domx);

%% now fillin where there are missing domain values
checkPlot=0;
Tinterpy=rocInterp(x,y,domx,checkPlot);
Tinterpyc=rocInterp(xc,yc,domx,checkPlot);
%[Tinterpy Tinterpyc]
%% remove any duplicate pairs
[interpy, interpyc] = getUniquePairs(Tinterpy,Tinterpyc);

%% now calculate the two-sided Wilcox paired rank sign test
p=signrank(interpyc,interpy,'method','exact');
%p=signrank(interpy,interpyc,'method','approximat');
    