initialize();
% 

iter1 = [10, 28, 54];
iter2 = [2, 19, 59];

texts1 = [{'without'}, {'CPM'}, {'Latent SVM'}];
texts2 = [{'alignment'}, {'alignment'}, {'alignment'}];

Iall = [];
for i = 4:6    
    Itmp = [];
    for j = 1:3        
        if (i < 4)
            [I, map] = imread([getenv('output_images'), '/component_18_interval_0/component_18_interval_0_offset_', int2str(iter1(i)), '_experiment_', int2str(j), '.png'],'png');
        else
            [I, map] = imread([getenv('output_images'), '/component_9_interval_2/component_9_interval_2_offset_', int2str(iter2(i-3)), '_experiment_', int2str(j), '.png'],'png');
        end
        I = double(I) ./ 255.;
        if (i == 1) || (i == 4)
            imgsize = size(I); 
            htxtins1 = vision.TextInserter(texts1{j}, 'Color', [0, 0, 0], 'FontSize', 24, 'Location', [2, imgsize(1)/2 - 25]);
            htxtins2 = vision.TextInserter(texts2{j}, 'Color', [0, 0, 0], 'FontSize', 24, 'Location', [2, imgsize(1)/2 ]);
            info_size = 120;
            imgsize(2) = imgsize(2) + info_size;
            img = double(ones(imgsize));
            img(:, (info_size+1):end, :) = I;                
            I = img;
            I = step(htxtins1, I);        
            I = step(htxtins2, I);        
        end
        Itmp = cat(1, Itmp, I);
    end
    Iall = cat(2, Iall, Itmp);
    

    
end


imgsize = size(Iall); 
% htxtins1 = vision.TextInserter('Component 18, interval 0.0s-0.2s', 'Color', [0, 0, 0], 'FontSize', 30, 'Location', [140, 10]);
htxtins2 = vision.TextInserter('Component 9, interval 0.2s-0.4s', 'Color', [0, 0, 0], 'FontSize', 30, 'Location', [140, 10]);


info_size = 70;
imgsize(1) = imgsize(1) + info_size;
img = ones(imgsize);
img((info_size+1):end, : , :) = Iall;                
% img = step(htxtins1, img);        
img = step(htxtins2, img);   


imshow(img);
colorbar
