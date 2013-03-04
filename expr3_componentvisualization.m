initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y', 'channels', 'icawinv', 'pca_reconstruct');
setenv('log_level', '1');
cacheName = 'componentsSeparatelySingleFold';

% 12.11.24 19:05:47 Component 18 interval 0
% 12.11.24 19:05:47 Component 58 interval 0
% 12.11.24 19:05:47 Component 9 interval 2
% 12.11.24 19:05:48 Component 2 interval 4
component = 2;
interval = 4;
firsts = getOffset(interval);
last = getOffset(interval + 2);
len = last - firsts + 1;
C = 2 * 10^4;

nrExperiments = 3;
Xinput = {};
for k = 1:nrExperiments
    Xinput{k} = zeros(size(X, 1), size(X, 2), size(X, 3));   
end

Xinput{1}(:, component, firsts:last) = X(:, component, firsts:last);
Xinput{2}(:, component, firsts:last) = alignWithCPM(X(:, component, firsts:last));

value = retriveCacheValue(struct('window', 3, 'component', component, 'interval', interval, 'C', C), cacheName);
for i = 1:size(X, 1)
    h = value.H(i);
    Xinput{3}(i, component, firsts:last) = X(i, component, (firsts + h):(last + h));
end

oneClassAmount = min(sum(Y == 1), sum(Y == -1));
oneClass1 = find(Y == 1);
oneClass2 = find(Y == -1);    
for k = 1:nrExperiments
    tmp = Xinput{k}(:, component, firsts:last);
    Xinput{k}(:, component, firsts:last) = Xinput{k}(:, component, firsts:last) - mean(tmp(:));
    Xinput{k}(:, component, firsts:last) = Xinput{k}(:, component, firsts:last) ./ std(tmp(:));
end

offsets = 1:60;
allValues = [];
for k = 1:nrExperiments
        % makes number of elements in both classes equal and negate one class.
        Xin = cat(1, -Xinput{k}(oneClass1(1:oneClassAmount), :, :), Xinput{k}(oneClass2(1:oneClassAmount), :, :));
        tmp = permute(Xin, [2, 1, 3]);    
        data = pca_reconstruct * icawinv * tmp(:, :);
        data = reshape(data, [size(data, 1), size(Xin, 1), size(Xin, 3)]);
        data = permute(data, [2, 1, 3]);
        data = squeeze(mean(data, 1));
        
        quality = 0.010;

        xrange = -1.05:quality:1.05;
        yrange = -0.8:quality:0.95;

        xrangeall = repmat(xrange, size(yrange, 2), 1)';
        yrangeall = repmat(yrange, size(xrange, 2), 1); 
        image{k} = {};
        for offsetIdx = 1:size(offsets, 2)
            writelnLog(1, 'Processing offsetIdx %d of %d experiment', offsetIdx, k);
            F = TriScatteredInterp(channels(:, 1), channels(:, 2), abs(data(:, firsts + offsets(offsetIdx))));
            img = F(xrangeall, yrangeall);    
            allValues = [allValues; img(~isnan(img))];                        
            image{k}{offsetIdx} = img;
        end
end

cmap = colormap;
imageRGB = {};
for k = 1:nrExperiments
    imageRGB{k} = {};
    for offsetIdx = 1:size(offsets, 2)
        img = image{k}{offsetIdx};
        img = img - min(allValues);
        img = floor(1 + (63*img / max(allValues - min(allValues))));
        imageRGB{k}{offsetIdx} = zeros(size(img, 1), size(img, 2), 3);
        for i = 1:size(img, 1)
            for j = 1:size(img, 2)
                if (isnan(img(i, j)))
                    imageRGB{k}{offsetIdx}(i, j, :) = [1, 1, 1]';
                else
                    imageRGB{k}{offsetIdx}(i, j, :) = cmap(img(i, j), :);
                end
            end
        end        
    end
end

chunkRange = 6;
texts1 = [{'without'}, {'CPM'}, {'Latent SVM'}];
texts2 = [{'alignment'}, {'alignment'}, {'alignment'}];
for chunk = 1:chunkRange;
    idx = 1;
    row = (10 * (chunk - 1) + 1):1:(10 * chunk);
    fig = figure('Position',[0, 0, 1600, 500]);
    k = 1;
    entireImage = [];
    for k = 1:nrExperiments
        rowImage = [];
        for rowIdx = 1:size(row, 2);
            imginput = imageRGB{k}{row(rowIdx)};            
            if (k == 1)
                imgsize = size(imginput);                                
                htxtins = vision.TextInserter(sprintf('%.3f s', (firsts + row(rowIdx)) / floor(781/2.6) - 0.2), 'Color', [0, 0, 0], 'FontSize', 26, 'Location', [imgsize(2)/2 - 40 2]);
                header_size = 24;
                imgsize(1) = imgsize(1) + header_size;
                img = ones(imgsize);
                img((header_size+1):end, :, :) = imginput;
                imginput = step(htxtins, img);
            end
            if (rowIdx == 1)
                imgsize = size(imginput);                
                htxtins1 = vision.TextInserter(texts1{k}, 'Color', [0, 0, 0], 'FontSize', 28, 'Location', [2, imgsize(1)/2 - 25]);
                htxtins2 = vision.TextInserter(texts2{k}, 'Color', [0, 0, 0], 'FontSize', 28, 'Location', [2, imgsize(1)/2 ]);
                info_size = 140;
                imgsize(2) = imgsize(2) + info_size;
                img = ones(imgsize);
                img(:, (info_size+1):end, :) = imginput;
                imginput = step(htxtins1, img);                
                imginput = step(htxtins2, imginput);  
            end            
            rowImage = cat(2, rowImage, imginput);                                   
        end
        entireImage = cat(1, entireImage, rowImage);
    end
    img = imagesc(entireImage);
    imwrite(get(img,'cdata'), sprintf('%s/suplement/component_%d_interval_%d_chunk_%d_out_%d.png', getenv('output_images'), component, interval, chunk, chunkRange), 'png');
end

for offset = 1:60
    for k = 1:nrExperiments
        img = imagesc(imageRGB{k}{offset});
        imwrite(get(img,'cdata'), sprintf('%s/component_%d_interval_%d/component_%d_interval_%d_offset_%d_experiment_%d.png', getenv('output_images'), component, interval, component, interval, offset, k), 'png');
    end
end


for k = 1:nrExperiments
    writelnLog(0, 'Sum of square derivatives %f for experiment %d', getSumOfSquareDerivatives( Xinput{k}, Y, zeros(size(Xinput{k}, 1), 1), component, firsts, len ), k); 
end

% this shows how stable is my meassure.
folds = 5;
meassure = zeros(folds, 1);
for fold = 1:folds
    meassure(fold) = getSumOfSquareDerivatives( Xinput{1}, Y, randi(7, size(Xinput{k}, 1), 1), component, firsts, len );
end
writelnLog(0, 'Average of meassure for random alignment is %f and std = %f', mean(meassure), std(meassure));