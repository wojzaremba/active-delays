% function [dat scans numMass header]
%
% Read in the mass spec data file which is of
% format:
%
% 'scan line'   'time'  'abundance' 'mass/Z'
%  6 0.134167 847.000000 1049.235352
%  21 0.515333 1581.000000 1296.312012
%  29 0.718833 2209.000000 1116.733887
%  30 0.744167 1663.000000 877.181030
%
% returns data -> the raw data 4xnumLines double 
% scans -> cell(1,numScans)
% numMass -> number of mass/z entries per scan
% header -> contains header number and time for each
%           scan (numScans x 2 double)

function [raw,scans,numMass,header] = ...
    readMSData(file)

%%%for testing
%dir = '/u/jenn/phd/data/emilie/';
%f = 'AE220703_Serum4_p10799_MSonly_run02.dat';
%f='test.dat'
%file = strcat(dir,f);
%%%

tic
%display(file);
display('reading in data file (~ 60 seconds)');
raw = dlmread(file);
toc

%get data for each scan header (ie all m/z, intensity for one
%time point/scan number
display('getting scan info');
scanData = raw(:,1);
uniqueScans = unique(scanData);
numScans = length(uniqueScans);
numMass = zeros(1,numScans);
scans = cell(1,numScans);
numUsed=0;
header=zeros(numScans,2);
tic
%find breakpoint of each scan (0 denotes new run)
brkpts = scanData(2:end)==scanData(1:end-1);
brkpts = [1; brkpts];
%get indexes of breakpoints
brkptInd = find(brkpts==0);
currentBrk = 1;
ind1=1;

for s=1:numScans-1
%     if (mod(s,10)==0)
%         display(strcat('Working on scan:',num2str(s)));
%     end
    ind2=brkptInd(s);
    scanInd = [ind1:ind2-1];
 
    numMass(s)=length(scanInd);
    tempData = raw(scanInd,:);
    scans{s}=tempData;
    header(s,1)=tempData(1,1);
    header(s,2)=tempData(1,2);    
    ind1=ind2;
        
    %% inefficient technique without breakpoint
%     scanInd = find((scanData(numUsed+1:end)==oneScan)==1);
%     scanInd = scanInd+numUsed; %must adjust for shifting
%     numUsed = numUsed + numMass(s);
    %%
end
% tack on the last scan
s=numScans;
ind2=length(scanData);
scanInd = [ind1:ind2];

numMass(s)=length(scanInd);
tempData = raw(scanInd,:);
scans{s}=tempData;
header(s,1)=tempData(1,1);
header(s,2)=tempData(1,2);    
ind1=ind2;

toc

%make sure each scan is unique
if (length(unique(header(:,1)))~=length(header(:,1)))
    error('Scan headers were not in order!');
end
