initialize();
% subjects = [8, 9];
subjects = [9];

data = cell(max(subjects), 1);
for s = 1:length(subjects)
    data{subjects(s)} = load([getenv('data_path'), 'processed0', num2str(subjects(s)), '_pca.mat'], 'X', 'Y');
end
setenv('log_level', '2');
len = getOffset(4) - getOffset(2) + 1;
folds = 5;
cacheName = 'allComponentsTogether';
C = 2 * 10^4;
windowRange = 0:5;
while (true)
    idx = getCacheIndex(struct('window', windowRange, 'fold', 1:folds, 'C', C, 'subject', subjects), cacheName);
    if idx.done, break; end;
    X = data{idx.subject}.X;
    Y = data{idx.subject}.Y;
    firsts = ones(size(X, 2), 1) * getOffset(2);    
    [ XTrain, YTrain, XTest, YTest ] = drawData(X, Y, idx.fold, folds);
    if (idx.window ~= 0)   
        % Initializing based on result for smaller window.
        model_ = retriveCacheValue(struct('window', idx.window - 1, 'fold', idx.fold, 'C', idx.C, 'subject', subjects), cacheName);
        if (~model_.cached)
            continue;
        end
        model_ = model_.model;
    else
        model_ = [];
    end
	[ model, H ] = latentsvmTrain( XTrain, YTrain, firsts, len, idx.window, idx.C, model_ );
    acc = latentsvmClassify(model, XTest, YTest, firsts, len, idx.window);
    writelnLog(0, [getCacheKey(idx), ' acc = %f'], acc);
    updateCache(idx, struct('model', model, 'H', H, 'acc', acc));
end

subject = 9;
acc = zeros(folds, size(windowRange, 2));
for windowIdx = 1:size(windowRange, 2)
    for fold = 1:folds
        value = retriveCacheValue(struct('window', windowRange(windowIdx), 'fold', fold, 'C', C, 'subject', subject), cacheName);
        acc(fold, windowIdx) = value.acc;    
    end
end

[~, p] = ttest(acc(:, 1), acc(:, 4));
writelnLog(0, 'paired ttest value for no alignment and alignment in 5-folds settings is %f. It is smaller than 5 percent', p); 

% results visualization

% we do not present plot after 5. We set acc(6, :) = acc(5, :) to avoid
% white strip on the right most part of the plot.
acc(:, 7) = acc(:, 6);
hold on;
macc = mean(acc) * 100;
hFig = figure(1);
fig = shadedErrorBar((0:6) * 3.33, acc * 100, {@mean, @(x) std(x)  }, {'-ob','markerfacecolor',[0,0,0]}, 0);
set(hFig, 'Position', [0 0 1200 700])
text(0, macc(1) - 0.3, sprintf('%0.2f%%', macc(1)), 'FontSize', 22);
text(3* 3.3 - 0.5, macc(4) + 0.3, sprintf('%0.2f%%', macc(4)), 'FontSize', 22);
set(fig.mainLine,'linewidth', 3);
set(gca,'FontSize',22)
% axis([0 16.67 63 72.5])
l=legend([fig.mainLine, fig.patch], '\mu', '\sigma');
leg = findobj(l,'type','text');
set(leg,'FontSize',22)
ylabel('prediction accuracy', 'FontSize', 22);
xlabel('considered misalignment', 'FontSize', 22);
xticks = {};
for i = 0:6
    xticks{i+1} = sprintf('%.1f ms', i * 3.33);
end
yticks = {};
for i = 64:2:72
    yticks{ceil((i-63)/2)} = sprintf('%d%%', i);
end
set(gca,'XTick', [0:6]*3.33);
set(gca,'XTickLabel', xticks);
set(gca,'YTick', 64:2:72);
set(gca,'YTickLabel', yticks);