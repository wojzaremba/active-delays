function setMySeed(mySeed)

%% set the seed -- matlab seems to do this in a screwy way, once
%% for rand and once for randn and all other functions...

randn('seed',mySeed);
rand('seed',mySeed);


%% note that lightspeed has some functions which will bypass this and
%% always be random, such as sample_hist.m, for example