function  datB = blurQmz(dat,timeVec,mzVec,filtType);

if ~exist('timeVec','var') || isempty(timeVec)
    timeVec=1;
end

if ~exist('mzVec','var') || isempty(mzVec)
    mzVec=1;
end

if ~exist('filtType')
    filtType='regular';
end

if iscell(dat)
    numSamp = length(dat);
    [numTime,numMZ]=size(dat{1});
    datB = zeros(numTime,numMZ,numSamp);
else
    [numTime,numMZ]=size(dat);
    numSamp=1;
    datB = zeros(numTime,numMZ);
end

if strcmp(filtType,'regular')
    for jj=1:numSamp
        if iscell(dat)
            datB(:,:,jj)=conv2(timeVec,mzVec,dat{jj},'same');
        else
            datB(:,:,jj)=conv2(timeVec,mzVec,dat,'same');
        end
    end
elseif strcmp(filtType,'median')
    for jj=1:numSamp
        if iscell(dat)
            datB(:,:,jj)=medfilt2(dat{jj},...
                [length(timeVec),length(mzVec)]);
        else
            datB(:,:,jj)=medfilt2(dat,...
                [length(timeVec),length(mzVec)]);
        end
    end
elseif strcmp(filtType,'medianXY')
    %% this does 1D median in x vertical direction first, then
    %% in y direction (not commutative, or the same as doign 2D)
    for jj=1:numSamp
        if iscell(dat)
            tmp=medfilt1(dat{jj},length(mzVec));
        else
            tmp=medfilt1(dat,length(mzVec));
        end
        tmp2=medfilt1(tmp',length(mzVec))';
        datB(:,:,jj)=medfilt1(tmp',length(mzVec))';
    end
end
