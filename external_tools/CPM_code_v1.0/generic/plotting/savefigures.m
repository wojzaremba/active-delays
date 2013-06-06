% function nothing = savefigures(figInd,startInd,basename,imageType,myDir,blackAndWhite)
%
% Saves figures with numbers in vector figInd
% /h/11/jenn/temp/
% as 'imageType' figure, where imageType=jpg,psc2,eps,
% of if imageType='all2', then it saves it as the three above
%    if imageType='all', then as 'jpg' and 'eps' (much less room than 'all2')
%
% startInd is the first number it will use to save the figures
% imageType can be:
% jpg tif fig eps,psc2 (colour) etc. consult saveas help


function nothing = savefigures(figInd,labelInd,basename,imageType,mydir,blackAndWhite)


if (~exist('basename'))
  basename = 'figure';
end

if ~exist('blackAndWhite')
    blackAndWhite=0;
end

if ~exist('imageType')
  imageType = 'jpg';
end

if (strcmp(imageType,'psc2'))
  myext='eps';
else
  myext=imageType;
end

if ~exist('mydir','var') || isempty(mydir)
    %mydir = [getRootDir() '\Figures\'];
    %mydir = fixSlashes(mydir);
    %mydir = ['/h/42/jenn/phd/MS/matlabCode/figures/'];
    mydir = ['/h/42/jenn/phd/thesis/figs/miscFigures/'];
end

disp(['saving to: ' mydir]);

if strcmp(imageType,'all2')
    imT={'jpg','fig','psc2'};
    myext={'jpg','fig','eps'};
elseif strcmp(imageType,'all')
    imT={'jpg','psc2'};
    myext={'jpg','eps'};
else
    imT = {imageType};
    myext={myext};
end

ct=1;
for ii=figInd 
  H=figure(ii);
  if (labelInd(ct)<10)
    useLabel = ['0' num2str(labelInd(ct))];
  else
    useLabel = num2str(labelInd(ct));
  end      
  
  for jj=1:length(imT)
      filename = [mydir basename '.' useLabel '.' myext{jj}];
      %filename
      if strcmp(imT{jj},'psc2') & blackAndWhite
          imT{jj}='eps';
      end
      cmd='saveas(H,filename,imT{jj})';
      eval(cmd);
  end
  ct=ct+1;
end


