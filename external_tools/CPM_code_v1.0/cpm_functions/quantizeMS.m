% function qmz = quantizeMS(scans,header,keepScans,scaleFac)
% 
% Quantize mass spec data, and convert it into
% a 2D matrix (scans,mz)
%
% if keepScans is present, then only those scans are 
% retained  (ie the others are culled)
%
% scaleFac is from preprocessing, and all abundance values
% should be multiplied by scaleFac

function qmz = quantizeMS(scans,header,keepScans,scaleFac)

if (exist('keepScans')==1)
    scans=scans(keepScans);
    header=header(keepScans);
end

%convert it to 2D matrix of dimensions: (numScans x 1200)
LOW=400; HIGH=1600;
% note that numDig represents to what extent we are
% rounding off the nearest decimal place (ie how we are
% quantizing the mz data).
% For example numDigits=2 means that every mass is of 
% the form XYZ.5  or XYZ.0
numDigits=2;
%numQuantizedMasses = (HIGH-LOW+1)*numDigits; %% SLIGHTLY WRONG
numQuantizedMasses = mzToCoord(HIGH)-mzToCoord(LOW)+1;
data = zeros(length(header),numQuantizedMasses);
for s=1:length(scans)
%     if (mod(s,100)==0)
%         display(strcat('Working on:',num2str(s)));
%     end
    temp=scans{s};
    abundance=temp(:,3);
    mz=temp(:,4);
    %round mz to nearest 0.5  
    mzr=round(mz*numDigits)/numDigits;
    %check for mz collisions:
    collisions=[diff(mzr)];
    colInd = find(collisions==0);
    if (length(colInd)>0)
        %merge collisions
        s
        error('still getting collisions');
        %         currentCol = 1;
        %         %are there every more than 2 collisions?
        %         bigCollisions = collisions(1:end-1)+collisions(2:end);
        %         areBigCol = find(bigCollisions==0);
        %         if (length(areBigCol>0))
        %             error('must change code to handle larger collisions');
        %         end
        %
        %         newAbund = abundance(1:colInd(1)-1);
        %         newmzr = mzr(1:colInd(1)-1);
        %         for col=1:length(colInd)
        %             tempInd = colInd(col);
        %             mergeAbun = sum(abundance(tempInd:(tempInd+1)));
        %             newAbund = cat(1,newAbund,mergeAbun);
        %             newmzr   = cat(1,newmzr,mzr(tempInd));
        %         end
        %         data(newmzr-LOW+1,s)=newAbund;
    else
        %need to map mzr into correct matrix index
        %mzInd = (mzr-LOW+1)*numDigits; %% OLD, and *slightly* wrong:
        mzInd = mzToCoord(mzr,LOW,numDigits); %% NEW
                
        if (min(mzr)<LOW) | (max(mzr)>HIGH)
            imstats(mzr);
            error('out of range, must remove high or low values');
        end

        data(s,mzInd)=abundance';
    end
end

qmz=data;
qmz=qmz*scaleFac;
