function [totalScores AUC]=compareBlur(dat,tryTime,tryMz,timeBlur2,mzBlur2,...
    computeROC);

%% see how different blurring to correct for residual misalignment
%% affects the TVD score, and the AUC, using timeBlur2 and mzBlur2
%% amount of blurring on the t-test

numT = length(tryTime);
numM = length(tryMz);

numClass=2; ind{1}=1:7; ind{2}=8:14;
numRep=7;

for tt=1:length(tryTime)
    for mm=1:length(tryMz)
        timeBlur = tryTime(tt);
        mzBlur = tryMz(mm);
        str=['Blurring: mz=' num2str(mzBlur) ', time=' num2str(timeBlur)];
        disp(str);
                      
        %% blur the data, then take one at a time
        %% as the 'anchor' which predicts
        [blurMat timeVec mzVec] = getBlurMat(timeBlur,mzBlur,0);
        global datB;
        datB = blurQmz(dat,timeVec,mzVec);           
     
        for cc=1:numClass
            tmpScores = zeros(numRep,numRep-1);
            thisClassInd = ind{cc};
            for anch=1:numRep
                anchInd = thisClassInd(anch);
                otherInd = setdiff(thisClassInd,anchInd);
                for jj=1:length(otherInd)
                    thisInd = otherInd(jj);
                    tmpScores(anch,jj) = scoreBlur(...
                        datB(:,:,anchInd),...
                        dat{thisInd});                 
                end
            end
            classScore(tt,mm,cc) = sum(tmpScores(:));
        end
        
        if computeROC
            [recall{tt,mm} precision{tt,mm} AUC(tt,mm)] = ...
                getECCBprecisionRecall('',timeBlur2,mzBlur2);
        else
            AUC=0;
        end
        
        if 0
            %% plot the precision/recall curve:
            figure,
            hold on; plot(recall{tt,mm},precision{tt,mm},'k^--');
            title(['Precision/Recall Curve - ' fNameShort{f}]);
            ylabel('Precision');
            xlabel('Recall');
            axis([0 1 0 1]);
            grid on;
            hold on;
        end        
    end
end

%% sum out the classes
totalScores = sum(classScore,3);
