function fname = filenameStamp()

clear myhost;
[garb,myhost]=system('hostname'); 
myhost=myhost(1:(end-4));
dateCode = datestr(datevec(now),31);
dateCode(11)='.';

fname = [dateCode '.' myhost];
