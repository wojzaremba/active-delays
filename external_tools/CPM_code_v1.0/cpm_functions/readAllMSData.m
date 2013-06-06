% function [raw,scans,numMass,header,headerAbun]=
%          readAllMSData(filelist)
%
% given a list of files, returns the raw data,
% scan data, numMassPerScan, headerInfo, headerAbund

function [rawF, scansF, numMassF, headerF, headerAbunF]=...
          readAllMSData(filelist)

clear rawF scansF numMassF headerF
for f=1:length(filelist)
  tempFile=filelist{f};
  display(['File ' num2str(f) ') '  tempFile]);
  [rawF{f} scansF{f} numMassF{f}, headerF{f}]...
	  = readMSData(tempFile);        
  headerAbunF{f} = getHeaderAbun(scansF{f});
end
