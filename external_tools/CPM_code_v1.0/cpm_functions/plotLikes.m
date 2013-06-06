function nothing=plotLikes(myLikes)

plot(myLikes(1:end),'-+');
title('Log likelihood during training');
xlabel('Iteration');
ylabel('Log likelihood');
mydiff = [0 diff(myLikes)];
badInds = find(mydiff<0);
hold on;
plot(badInds,myLikes(badInds),'ro','MarkerFaceColor','r');
legend('Likelihood','Decreased Likelihood',3);
maxDiff = max(abs(mydiff(badInds)));
meanDiff = mean(abs(mydiff(badInds)));
mytxt = ['Maximum drop in log likelihood=' sprintf(' %.3e',maxDiff)];
text(0.3, 0.5, mytxt, 'Units', 'Normalized','FontSize',11);
mytxt = ['Mean drop in log likelihood=' num2str(meanDiff)];
text(0.3, 0.45, mytxt, 'Units', 'Normalized','FontSize',11);
mytxt=['Number of drops = ' num2str(length(badInds))];
text(0.3, 0.25, mytxt, 'Units', 'Normalized','FontSize',11);
