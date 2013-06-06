function hstnm = getHostName()

%DOS_BASED=0;
%DOS_BASED=1;

DOS_BASED = ~UT;

oldDir = pwd;

if DOS_BASED
  cd C:
end
[garb hstnm] = system('hostname');
if DOS_BASED
system(['cd ' oldDir]);
end

hstnm=deblank(hstnm);

if UT
    hstnm = hstnm(1:(end-3));
end

return;
