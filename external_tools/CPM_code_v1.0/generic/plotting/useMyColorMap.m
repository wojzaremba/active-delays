function useMyColorMap(str)

strList = {str};
clmaps = getColorMaps(strList);

%% now set the colormap to one of these
clMap = clmaps{1};
colormap(clMap);

