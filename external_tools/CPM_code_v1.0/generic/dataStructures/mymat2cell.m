function c = mymat2cell(m,rowSizes,colSizes)
%MYMAT2CELL.M Break matrix up into a cell array of matrices.
%
%	Synopsis
%
%	  mymat2cell.m(M,R,C);
%
%	Description
%
%	  MYMAT2CELL.M(M,R,C) takes three arguments,
%	    M - ROWxCOL Matrix.
%	    R - Vector of row sizes (should sum to ROW).
%	    C - Vector of col sizes (should sum to COL).
%	  and returns a cell array of matrices, found using R and C.
%
%	Example
%
%	   M = [1 2 3 4; 5 6 7 8; 9 10 11 12];
%	   C = mymat2cell.m(M,[1 2],[2 2])
%	    
%	See also CELL2MAT

switch nargin

  case 1,
    c = {m};
  
  case 2,
    rows = length(rowSizes);
    c = cell(rows,1);
    rowStart = 0;
    for i=1:rows
      c{i,1} = m(rowStart+[1:rowSizes(i)],:);
      rowStart = rowStart + rowSizes(i);
    end
	
  case 3,
    rows = length(rowSizes);
	cols = length(colSizes);
    c = cell(rows,cols);
    rowStart = 0;
    for i=1:rows
	  colStart = 0;
	  for j=1:cols
        c{i,j} = m(rowStart+[1:rowSizes(i)],colStart+[1:colSizes(j)]);
        colStart = colStart + colSizes(j);
	  end
      rowStart = rowStart + rowSizes(i);
    end

end
