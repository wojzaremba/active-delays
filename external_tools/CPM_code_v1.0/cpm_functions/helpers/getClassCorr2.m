%function [stat m1 m2 v1 v2] = ...
%    getClassCorr(ms1,ms2,i1,i2,statType,doBlur,timeBlur,mzBlur,minStd,minDiff)
% 
%% ms1 and ms2 are STRING variables which should be global
%% variables in the workspace
%%
%% this saves memory (I think?)
%%
%% given aligned MS spectra (one per cell array), compute
%% the class-dependent correlation
%%
%% sets any NaN values to zero.
%% 
%% statType denotes what kind of statistic to return and can
%% be equal so far to 'welchT', 'mutualInf'.
%%
%% NOTES: 
%% 'welchT' uses the Welch t-test, which is like a t-test,
%% except that equal variances in each class are not assumed.
%%
%% 'mutualInf' uses mutual information (same as information gain)

function [stat m1 m2 v1 v2] = ...
    getClassCorr(ms1,ms2,i1,i2,statType,doBlur,...
    timeBlur,mzBlur,minStd,minDiff,minRelDiff)


if ~exist('minStd','var')
    minStd=0;
end

global datB;

%% convert to multi-d array
% cmd = ['numSamples1 = length(' ms1 ');']; 
% eval(cmd);
% cmd = ['numSamples2 = length(' ms2 ');']; 
% eval(cmd);
%cmd = ['[numTaus numMZ] = size(getCellEntry(' ms1 ',1));']; 
cmd = ['[numTaus numMZ,numSamples1] = size(' ms1 ');']; 
eval(cmd);
cmd = ['[numTaus numMZ,numSamples2] = size(' ms2 ');']; 
eval(cmd);

%cmd = ['x1 = ' ms1 ';']; eval(cmd);
%cmd = ['x2 = ' ms2 ';']; eval(cmd);

cmd = ['v1 = varonline(permute(' ms1 ',[3 1 2]));']; eval(cmd);
cmd = ['v2 = varonline(permute(' ms2 ',[3 1 2]));']; eval(cmd);

% if length(size(x1))>2
%    v1 = varonline(permute(x1,[3 1 2]));
%    v2 = varonline(permute(x2,[3 1 2]));
%    %vv1 = permute(var(permute(x1,[3 1 2])),[2 3 1]);
%    %vv2 = permute(var(permute(x2,[3 1 2])),[2 3 1]);
% else
%    %% just use the same thing for everytyhing and which
%    %% will give us results of similar scale to what
%    %% we might otherwise have expected.
%    
%    keyboard; %% need to fix this
%    
%    tmpDat = zeros(2,size(x1,1),size(x1,2));
%    tmpDat(1,:,:)=x1;    tmpDat(2,:,:)=x2;
%    tmpVar=permute(var(tmpDat),[2 3 1]);
%    v1 = mean(tmpVar(:))*ones(size(tmpVar));
%    v2=v1;
% end

%% compute basic statistics taht we'll likely need
% m1 = mean(x1,3);
% m2 = mean(x2,3);
cmd = ['m1 = mean(' ms1 ',3);']; eval(cmd);
cmd = ['m2 = mean(' ms2 ',3);']; eval(cmd);

%% make very small variances be zero
if any(v1(:)<-eps) || any(v2(:)<-eps)
    error('negative variance');
else
    v1(find(v1<0))=0;
    v2(find(v2<0))=0;
end

if strcmp(statType,'varOnly')
    stat = [];
    return;
end

%% make up some minimum std, minStd so that we don't get
%% large t-statistics when m1 is very close to m2
%% we can pick say the 5th percentile of non-zero variances
%% or some such thing
%% [I saw something like this in the microarray literature
%%  where instead of s12 below, they use s12 +s_fudge, see
%% Lonnstead and Speed, http://www.stat.berkeley.edu/users/terry/zarray/TechReport/mareview.pdf

if strcmp(statType,'welchT')
    %% compute the welch T statistic
    s12 = sqrt(v1/numSamples1 + v2/numSamples2);
    stat = (m1 - m2)./(s12 + minStd);%+eps);
    stat(find(isnan(stat)))=0;
    stat(find(isinf(stat)))=0;
    stat(find(abs(m1-m2)<minDiff))=0;
    %return;
elseif strcmp(statType,'mutualInf')
    %% compute mutual information
    %% assumes now that features are real-valued, with
    %% a gaussian density
    keyboard;
    %return;
else
    error('need to select welchT or mutualInf for statType');
end
    
if ~isreal(stat)
    error('stat is not all real-valued');
end

%% 'coherence' blur
if doBlur
    [blurMat timeVec mzVec] = getBlurMat(timeBlur,mzBlur,0);
    stat = blurQmz({stat},timeVec,mzVec);   
    %stat=conv2(timeVec,mzVec,stat,'same');
end

if ~isreal(stat)
    error('stat is not all real-valued');
end

return;




keyboard;

if 0
    figure,show(welchT); colorbar;
    figure,show(~isnan(welchT)); colorbar;    
    goodT = welchT(goodInd);
    numGood = length(goodT);
    %numBad  = 
end