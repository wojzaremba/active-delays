%function newS=adjustS(oldS,maxScaleTrans)
%
% if any values went too large, then the large
% values are set to maxScaleTrans, and everything
% renormalized

function newS=adjustS(oldS,maxScaleTrans)

newS=min(oldS,maxScaleTrans);
