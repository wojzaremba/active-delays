%function interpy=rocInterp(x,y,domx);
%
% given ROC points, x,y, use David's 'least value consistent with'
% method to get y values for all points at domx
%
% this is essentially a kind of weird interpolation, but not linear
%
% if one plots, plot(x,y,'-+'), then plots (domx,interpy,'*') on top of it,
% it should perfectly intersect (i.e. all *s should fall on lines)
%
% double check that it is doing what you want by plotting somethign like
% the above

function interpy=rocInterp(x,y,domx,checkWithPlot)


interpy = 2*ones(size(domx));
%% tolerance on how close we have to be in x
tol = 1e-5;

for jj=1:length(domx)
    thisX = domx(jj);
    foundInd = find(abs(x-thisX)<tol);
    if ~isempty(foundInd)
        %% we already have it, get the lowest possible value
        minVal = min(y(foundInd));
        interpy(jj) = minVal;
    else
        %% need to 'interpolate', i.e. find the point x to the left
        %% (or the right of thisX if there is no left point)
        
        %% the left most x-value(s)
        [leftXval leftXind]= max(x(find(x<thisX)));
        if ~isempty(leftXind)
            %% now get the lowest amount at this Value
            interpval = min(y(leftXind));
        else %% need right-most point
            [rightXval rightXind]= max(x(find(x>thisX)));
            interpval = min(y(rightXind));
        end
        interpy(jj)=interpval;
    end
end

if checkWithPlot
    figure,plot(x,y,'b-+');
    hold on;
    plot(domx,interpy,'r*');
    legend('Original Data','Interpolated Data');
    title('Checking least-val-consistent-with interpolation');
end

return;