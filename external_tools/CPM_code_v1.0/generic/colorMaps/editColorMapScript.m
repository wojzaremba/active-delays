%% Need to have java enabled on this Matlab session,
%% i.e. cannot use -nojava (or possibly -nodesktop)

%% set colormap back to default
colormap('default');

%% open the colormap editor
colormapeditor;

%% make up some name for this colormap
%% eg. greenToWhiteToRed
thisName = 'test';
%thisName = 'greenToWhiteToRed';
%thisName = 'whiteToRed4';
%thisName = 'whiteToGreen4';

%% set this variable name equal to the colormap
cmd = [thisName '= colormap;'];
eval(cmd);

%% save this variable it to my colormap directory
myDir = '/u/jenn/matlab/colormaps/';
cmd = ['save ' myDir thisName '.mat ' thisName ';'];
eval(cmd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USAGE AFTERWARDS:
%%
%% to retrieve this colormap, use the following commands, using
%% for example, the map called 'greenToWhiteToRed'

%% or just say:
% thisMap = 'greenToWhiteToRed';
%thisMap = 'whiteToRed4'
%thisMap ='whiteToGreen4';
useMyColorMap(thisMap);

%% see if it is what you expect;
colormapeditor;

%% OR, if want more than one

%strList = {'greenToWhiteToRed'};
strList = {'test','greenToWhiteToRed'};
clmaps = getColorMaps(strList);

%% now set the colormap to one of these
clMap = clmaps{1};
colormap(clMap);

%% see if it is what you expect;
colormapeditor;

