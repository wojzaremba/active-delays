% function [files filesWithDir numF] = getFiles(...
%    dirName,fileExt,indexSet,prefix,postfix,ADD_ZEROS)
%
% Returns filelist, a cell array containing the
% name of each file.
%
% fileFilter can optionally be provided to 
% only get back files with that filter.
% eg. fileFilter = '*.dat';
%
% if 'indexSet' is given, for example indexSet=[2 5 6], then
% it will go through looking for '*_indexSet(ii).fileExt' one
% at a time, and only return these
% (adds a zero before a single digit when looking for file)
%
% prefix and postfix are what come before and after the index
% set members, for e.g., prefix='_' and postfix='.' in the example
% above.
%
% display('Warning will not work if .cshrc has echo commands in it');

function [files filesWithDir numF] = getFiles(...
    dirName,fileExt,indexSet,prefix,postfix,ADD_ZEROS)

if ~exist('ADD_ZEROS','var')
    ADD_ZEROS=0;
end

if ~exist('fileExt')==1
    fileExt='*.*';
end

if ~exist('indexSet','var') || isempty(indexSet)
    indexSet=[];
    noIndexSet=1;
else
    noIndexSet=0;
end

indexSetOrig = indexSet;

cwd = pwd;
eval(['cd ' dirName ';']);
eval(['temp= dir(''' fileExt ''');']);
eval(['cd ' cwd ';']);

clear files;
nxt=0;

if ~exist('postfix','var') || strcmp(postfix,'')
    postfix=[];
end

if ~exist('prefix','var') || strcmp(prefix,'')
    prefix=[];
end

%keyboard;

for f=1:length(temp)
    tmpName = temp(f).name;
    foundFile = 0;
    if ~noIndexSet
        for ss=1:length(indexSet)
            if isnumeric(indexSet(ss))
                tmpStr = num2str(indexSet(ss));
            else
                tmpStr = indexSet(ss);
            end
            if length(tmpStr)==1 && isnumeric(indexSet(ss)) && ADD_ZEROS
                tmpStr = ['0' tmpStr];
            end
            foundFile = strfind(tmpName,[prefix tmpStr postfix]);
            if foundFile
                break;
            end
        end
        if foundFile
            %% update so we can see if we were missing any
            indexSet = setdiff(indexSet,indexSet(ss));
        else
            foundFile=0;
        end
    elseif noIndexSet
        if ~isempty(prefix)
            foundFile = strfind(tmpName,prefix);
        else
            foundFile=1;
        end
        if foundFile
            if ~isempty(postfix)
                foundFile = strfind(tmpName,postfix);
            else
                foundFile=1;
            end
        else
            foundFile=0;
        end
    end
    if foundFile
        nxt=nxt+1;
        files{nxt}=tmpName;
        filesWithDir{nxt} = [dirName temp(f).name];
    end
end

if ~isempty(indexSet)
    warning('Did not find all files was looking for');
    disp(['Remaining files are: ' num2str(indexSet)]);
    keyboard;
end

if nxt==0
    dirName
    fileExt
    filelist='';
    disp('No files found')
    keyboard;
end

numF=length(files);

str = ['Found ' num2str(numF) ' file(s)'];
disp(str); %pause;
