% function null = exportCellArrayAndMatrix(filename,cellArray, numberArray);
%
% Exports the cellArray, with one element per line
% If numberArray exists, then it also puts each row of the numberArray next
% to each element of the cellArray
% To use the default filename, just type in 'none' for filename

function nothing = exportCellArrayAndMatrix(filename,cellArray, numberArray)

if (strcmp(filename,'none'))
    filename = 'X:\WGP-Jennifer\Matlab\workspaces\tempCellArray.csv';
end

[FID,message] = fopen(filename,'w');
if (message)
    error(strcat('MESSAGE from fopen: ',message));
end

[numCells,numCols] = size(cellArray);

if (exist('numberArray')~=1)
    numRows=0;
    numCols=0;
    numberArrayExists=0;    
else
    numberArrayExists=1;
    [numRows,numCols] = size(numberArray);
end

if ((numRows==0) | (numCells==numRows))
    for i=1:numCells
        formatString='%s';
        for j=1:numCols
            formatString=strcat(formatString,',%f');
        end
        formatString=strcat(formatString,'\n');
        if (numberArrayExists)
           fprintf(FID,formatString, cellArray{i},numberArray(i,:));
        else
           fprintf(FID,formatString, cellArray{i});
        end
    end    
else
    whos cellArray numberArray
    error ('Size of matrix and cell array do not match');
end
fclose(FID);

display(strcat('Exported to:',filename));