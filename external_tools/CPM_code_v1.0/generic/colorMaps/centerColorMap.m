function centerColorMap(data,trimFrac)

%% center the colours so that zero is the central color on the
%% colormap
%%
%% trimFrac help avoid outlier problems.  the larger the data set
%% the higher this should be in general
%% eg. trimFrac=0.9999
%%
%% need to call colorbar again to update it

%% center the zero color:
sortVals = sort(abs(data(:)));
%% take 95th percentile
maxVal = sortVals(floor(trimFrac*length(sortVals)));
myclim = [-maxVal maxVal];
%myclim
caxis(myclim);
