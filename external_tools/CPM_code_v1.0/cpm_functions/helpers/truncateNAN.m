function [dat newBounds] = truncateNAN(dat)

%% remove the beginning and ends, if there is any single
%% sample that doesn't have 'stuff' there.

%% add them all up so that nans collapse
temp2 = dat{1};
for jj=2:length(dat)
    temp2=temp2 + dat{jj};
end

if size(dat{1},2)>1
    hasNoStuff = any(temp2');
else
    hasNoStuff=isnan(temp2);
end
breakPt = find(diff(hasNoStuff));

%% case for when it goes right to end for all traces
if length(breakPt)==2
    newBounds = [breakPt(1)+1, breakPt(2)-1];
elseif length(breakPt)==1
    newBounds = [breakPt(1)+1, size(temp2,1)];
else
    error('shouldt be here');
end
newRg = newBounds(1):newBounds(2);
for jj=1:length(dat)
    %disp(['truncating ' num2str(jj)]);
    temp = dat{jj};
    dat{jj}=temp(newRg,:);
end


for jj=1:length(dat)
    temp = dat{jj};
    if any(isnan(temp(:)))
        error('still has a NaN');
    end
end




return;




%% this causes memory problems
temp = mycell2mat(dat);
%temp = cell2mat(dat);
temp2 = squeeze(sum(temp,2))==0;
hasNoStuff = any(temp2');
breakPt = find(diff(hasNoStuff));
newBounds = [breakPt(1)+1, breakPt(2)-1];
newRg = newBounds(1):newBounds(2);
temp = temp(newRg,:,:);
for jj=1:size(temp,3)
    dat{jj}=temp(:,:,jj);
end
