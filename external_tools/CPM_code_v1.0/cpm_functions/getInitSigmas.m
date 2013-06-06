function [sigmas,varsigma,minSigma] = getInitSigmas(G,samplesMat)

%% for the vector emission case, should have a different sigma
%% for each m/z bin

%display('getInitSigmas'); keyboard;

sigmas = zeros(G.numBins,G.numSamples);
varsigma = zeros(1,G.numBins);
minSigma = zeros(1,G.numBins);

for bb=1:G.numBins
  tmpSamp = samplesMat(bb,:,:);
  %tmpSamp = sort(tmpSamp(:));
  
  %% OBSOLETE%%%%%%%%%%%%%%%%%%%%%%%
  %% first set minSigma based on scale separation 
  %medVal = median(tmpSamp);
  if ~G.oneScaleOnly
    minSigma(bb) = NaN;%max(diff(medVal*(2.^G.scales)));
  else
    minSigma(bb) = NaN;%max(diff(medVal*(2.^G.scales)));
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %% now initialize sigmas from this
  magick=1*G.numBins; %% having problems with larger number of bins,
                      %% perhaps due to small initial variance?
  %sigmas(bb,:)=minSigma(bb)*magick;
  %sigmas(bb,:)=std(tmpSamp(:))*magick;
  sigmas(bb,:)=std(tmpSamp(:))*magick;
  varsigma(bb)=sigmas(bb,1)^2;
end

%keyboard;

%% make same for all bins:
if 0 %% seesm to mess up for large number of bins
    sigmas = mean(sigmas(:))*ones(size(sigmas));
    varsigma = mean(varsigma)*ones(size(varsigma));
end

%str=['Initial sigmas are: ' sprintf('%3.3d ',sigmas)];
%warning(str); 

%%% hack here
%warning('MAKING SIGMAS = MINSIGMA!!!!!!!!!!!!!!!!!');
%sigmas = G.minSigma*ones(size(sigmas));

return;













%% doesn't make sense for it to depend on how we initilzed latent trace

for cc=1:G.numClass
  for bb=1:G.numBins
    adHocConst =  max(latentTrace(:,cc,bb))-min(latentTrace(:,cc,bb));
    adHocConst=0.3*adHocConst;
    sigmas(bb,G.class{cc}) =  adHocConst;
    varsigma(bb,G.class{cc}) =  sigmas(bb,G.class{cc}).^2;
  end
end


%% now make the sigmas all the same within a class
sigmas=mean(sigmas,2)*ones(size(sigmas));
%varsigma=sqrt(mean(varsigma));
varsigma=mean(varsigma,2);


