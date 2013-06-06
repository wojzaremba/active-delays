% function showFigs(myDir)
%
% open all matlab .fig files found in the directory 'myDir'

function showFigs(tDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get list of files:
baseName = '*.fig';
[garb fName] = getFiles(tDir,baseName);
numFiles = length(fName);

str = ['Found ' num2str(numFiles) ' file(s)'];
disp(str); 
disp('hit any key to continue');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% now open them one by one

for ff=numFiles:-1:1
    cmd = ['open ' fName{ff}];
    eval(cmd);    
end