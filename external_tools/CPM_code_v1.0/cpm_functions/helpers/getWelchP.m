% function [welchTP welchP] = getWelchP(dat,labels);
%
% Do a 'permutation' test, which in this case is a little non-standard
% and involves taking all of one class, and repeatedly partitioning
% it into two to do a Welch-T test, and then doing this for both
% classes
%
% note - for consistency, we should always make sure that the partions
% are the same size
%
% note that this is a non-conservative/conservative? approximation 
% to picking out significance levels since here we are using 
% only half the number of samples, and (might?) expect to have different
% behaviour, though it isn't clear to me in what direction we might
% expect that behaviour
%
% welchP = {welchP1 welchP2} and
% welchP1 an welchP2 are the resulting welchT statistics, over all
% permutations, within each class
%
% welchTP = {welchTP1 welchTP2} and
% welchTP1 and welchTP2 are the resulting welch T statistics, over
% all real partitions of the data, of the same size as the permtutations
%
% also do real tests of the real 2-class data, multiple times,
% using samples as the same size as the permutation data.
%
%  ASSUMES AN EVEN NUMBER OF SAMPLES IN ANY GIVEN CLASS

function [welchTP welchP] = getWelchP(dat,labels);

classes = unique(labels);
numC = length(classes);

if numC~=2
    error('Expects precisely 2 classes');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% real tests, partitions of the same size
disp(['Working real data']);

%% find all ways to split into two classes, each of
%% same size as partions used for the permutations

for cc=1:numC
    thisClass = find(labels==classes(cc));
    classSize = length(thisClass);
    allGp{cc} = getUniqueGroups(thisClass,classSize/2);
end

%% total number of partitions
len1 = length(allGp{1});
len2 = length(allGp{2});
if len1~=len2
    error('here');
end
numT = len1^2/2 - len1;
%% not feasible to do all of these, so only do up to 
%% maxNum of them, but because of this, want to split
%% up the ones we pick, not consecutive, because otherwise
%% we never touch part of the data

nxt=0;
gp1 = allGp{1};
gp2 = allGp{2};

interval = 10;
rg1 = 1:interval:len1;
rg2 = 1:interval:len2;
maxNum = length(rg1)*length(rg2);
oneSize = size(dat{1});
welchTP = zeros([oneSize maxNum]);

for jj=rg1    
    ind1 = gp1(:,jj);
    for kk=rg2
        ind2 = gp2(:,kk);
        
        nxt=nxt+1;
        disp(['Working on pairing ' num2str(nxt) ' of ' num2str(maxNum)]);
                
        %[ind1 ind2]
        
        [welchTmp m1 m2 v1 v2] = getClassCorr(dat(ind1), dat(ind2));
        welchTP(:,:,nxt) = welchTmp;
    end   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% permutations
for cc=1:numC
    disp(['Working Permutations, class ' num2str(cc)]);
    %% find all ways to split this class into two
    thisClass = find(labels==classes(cc));
    classSize = length(thisClass);
    if mod(classSize,2)~=0
        error('expects even sized class');
    end
    
    splits = getSplits(thisClass);  
    splits = splits(:,:,1:2:end);
    
    welchP{cc} = runWelchOnSplits(dat,splits);    
end
















