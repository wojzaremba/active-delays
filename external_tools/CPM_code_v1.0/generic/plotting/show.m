% function myhandle = show(matrix,myTitle,clmap)
%
% Display a matrix as a heat map.
%
% clmap should be a string, for eg. 'hot(15)'
%
% if no clmap is given, then defaults to hot(15)
%
% if the clmap given is the empty string, then it
% will not set a new colourmap at all, but will use
% the current one

function myhandle = show(matrix,myTitle,colmap)

if 0%~(exist('colmap')==1)
  colmap='hot(15)';  
end

myhandle= image(matrix,'CDataMapping','scaled'); 
xlabel('');   
if exist('colmap')==1 && ~isempty(colmap)
    eval(['colormap(' colmap ');']);
    %colormap(colmap);
end
%colorbar;

if (exist('myTitle'))
  title(myTitle);
end

