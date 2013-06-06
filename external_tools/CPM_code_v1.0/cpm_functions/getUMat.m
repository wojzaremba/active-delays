% function uMat = getUMat(G,u)
%
% only used when USE_CPM2=1
%
% given the u_kt control points, and the splineVals associated
% with them, apply a simple linear spline
% to get a value at each of the G.numTaus 'fake time points'.
%
% if 'u' is not provided, gets it from G.u
% want this flexibility when updating u parameter, for eg.

function uMat = getUMat(G,u)

%% too slow like this
% if ~exist('u')
%     u=G.u;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% use of a linear spline %%%
%% just use linear interpolate between all the control pt. values
%% for now, make it the same for each bin, might change later
uMat = zeros(G.numSamples,G.numTaus);

for kk=1:G.numSamples
    
    %% interpolate between cntrl pts using interp1q
    xi = 1:G.numTaus;
    x = G.cntrlPts;
    %y2 = squeeze(u(kk,:));   
    %keyboard;
    y = u(kk,:);
    %if ~all(size(y)==size(y2))
    %    keyboard;
    %end
    f = interp1q(x',y',xi');
    uMat(kk,xi) = f;
end

return;
