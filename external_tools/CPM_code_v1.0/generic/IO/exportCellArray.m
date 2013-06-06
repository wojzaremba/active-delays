% function null = exportCellArray(filename,cellArray,noNan,useFullPath);
%
% Exports the cellArray, containing either a string or number in
% each position.
% To use the default filename, just type in '' for filename
% If 'nonNan' is provided, then all NaNs are turned into the string
% provided by noNan
%
% if useFullPath is provided, than filename contains a full path to 
% a file, rather than just the base name

function nothing = exportCellArray(filename,cellArray,noNan,useFullPath)

if ~exist('useFullPath')
    useFullPath=0;
end

%delimiter ='\t';
delimiter =',';

tmpDir = getRootDir();
tmpDir = [tmpDir  '\Figures\'];
tmpDir = fixSlashes(tmpDir);


if isempty(filename)    
    filename = 'cellArray.csv';
else
    filename = [filename '.csv'];
end

if ~useFullPath
    filename = [tmpDir filename];
end

display(filename)
[FID,message] = fopen(filename,'w');
if (message)
    filename
    error(strcat('MESSAGE from fopen: ',message));
end

if exist('noNan')==1
    useNullString=1;
    numEmpty=0;
else
    useNullString=0;
end

[numRows,numCols] = size(cellArray);
display(strcat(num2str(numRows),' rows'));
display(strcat(num2str(numCols),' columns'));
disp('Writing...');

delimLength = size(delimiter,2);

for i=1:numRows
    formatString='';
    clear tempData;
    ind=1;
    for j=1:numCols
        tempEntry=cellArray{i,j};
        if (iscell(tempEntry))
            tempEntry=tempEntry{1};
        end
        if (useNullString & isnan(tempEntry))
                numEmpty=numEmpty+1;
                %formatString=strcat(formatString,delimiter);        
                %formatString=[formatString '%s' delimiter];                
                %if ~ischar(nonNan)
                %    warning('here'); keyboard;
                %end
                %tmpData{ind}=noNan;                
                %ind=ind+1;
                tempEntry=noNan;
        end        
        if (max(size(tempEntry))==0)
            formatString=strcat(formatString,delimiter);
        elseif(ischar(tempEntry))
            formatString=strcat(formatString,strcat('%s',delimiter));
            tempData{ind}=tempEntry;
            ind=ind+1;
        elseif (isnumeric(tempEntry))
            %formatString=strcat(formatString,strcat('%f',delimiter));
            formatString=strcat(formatString,strcat('%e',delimiter));
            tempData{ind}=tempEntry;
            ind=ind+1;        
        else
            tempEntry
            error('Cell array contains something that is not a string or numeric');
        end
    end
    %% remove last delimiter since we don't need it
    formatString=strcat(formatString(1:end-delimLength),'\n');
    %fprintf(FID,formatString, cellArray{i,:});
    if (exist('tempData')==1)
       fprintf(FID,formatString, tempData{:});       
    else
        fprintf(FID,formatString);
    end
    if mod(i,100)==0
        disp(['Printing line ' num2str(i)]);
    end
end
fclose(FID);

display(strcat('Exported to:',filename));
%open(filename);
