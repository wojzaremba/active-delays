function r = scoreBlur(blurD,dat)

%% score how 'likely' the data d is in being 'generated' from 
%% blurD, according to the "total variation distance".

%% normalize each set of data so that it looks like
%% a probability distribution

dat = dat/sum(sum(dat));
blurD = blurD/sum(sum(blurD));

%% use total variation distance (except for factor of 2)
r = sum(sum(abs(dat-blurD)));
