function mySeed = setRandSeed()

tmp=clock;
mySeed=tmp(end)*1000;
rand('seed',mySeed);

randn('seed',mySeed*100);

