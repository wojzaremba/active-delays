function showHeaderAbunB(ha)

%% assumes all ha are the same size
%% displays each bin one figure at a time

[numB,numTime] = size(ha{1});

if numB==1
    figure,showHeaderAbun(ha);
else
    ha2 = cell2mat(ha);
    numExp = length(ha);
    ha2 = reshape(ha2,[size(ha{1}) numExp]);

%     %% just for testing, collapse again
%     keyboard;
%     ha2 = sum(ha2,1);    numB=1;
    
    ha3=cell(1,numExp);
    for bb=1:numB
        for ex=1:numExp            
            ha3{ex} = ha2(bb,:,ex);
        end
        figure,showHeaderAbun(ha3);
        title(['Bin ' num2str(bb) ' of ' num2str(numB)]);
    end
end