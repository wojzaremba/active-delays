%function scales = getScales(neutralScaleOnly)
function scales = getScales(oneScaleOnly)

if (~exist('oneScaleOnly') | ~oneScaleOnly)
  scales=[-0.45:0.15:0.45];
else
  scales=[0];
end

%scales=[-0.15:0.15:0.15];

if (mean(scales)>eps)
  error('Mean scale should be zero');
end

return;



scales'
2.^scales'
length(scales)
