% function clmaps = getColorMaps(strList)
% 
% load up the colormaps listed in strList
% from the directory /u/jenn/matlab/colormaps/
% strList={'blackToRed' 'blackToGreen'};

function clmaps = getColorMaps(strList)

mydir = '/u/jenn/matlab/colormaps/';
%mydir = '~/matlab/colormaps/';

clmaps = cell(1,length(strList));

for mp=1:length(clmaps)
  if ~exist(['''' strList{mp} ''''])
    cmd1 = ['load ''' mydir strList{mp} '.mat'''];
    %display(['The command: ' cmd1]);

    eval(cmd1);
    cmd2 = ['clmaps{' num2str(mp) '}=' strList{mp} ';'];
    eval(cmd2);
  end
end
