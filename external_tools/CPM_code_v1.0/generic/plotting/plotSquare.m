% function plotSquare(corners,ls)
% 
% plot out a square using the specified corners, and the given
% line spec
%
% corners is 1x4 (or 4x1) and goes in the followin order
% [yLow yHigh xLow xHigh], where y is on the vertical axis

function plotSquare(corners,ls)

error('incomplete');

if ~(exist('ls')==1)
    ls = 'k-';
end



%tmpX = [
plot(tmpX,tmpY,ls);
hold on;
