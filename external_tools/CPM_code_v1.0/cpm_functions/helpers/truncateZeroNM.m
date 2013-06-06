function [dat nm] = truncateZeroNM(dat,nm)

% remove all nm wavelengths that have no signal
% such that all data has the same number of 
% wavelengths

keyboard;

%% find common nm zero region
maxNM = 1;
for jj=1:length(dat)
    %% check that nms read in are all the same to start
    thisNM = nm{jj};
    if ~all(thisNM==nm{1})
        error('NMs dont match up');
    end
    
    thisDat = dat{jj};
    sumDat = sum(thisDat,1);
end   
    
    