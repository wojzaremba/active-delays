function y = mat2cellDefault(x)

%% uses the built-in mat2cell, but instead of having
%% to specify all the row lengths, and all the column lengths,
%% this assumes that x stores only one numeric entry per cell entry

[r,c]=size(x);

rr = ones(1,r);
cc = ones(1,c);
y = mat2cell(x,rr,cc);