function displayLatentTraces(z,str1,str2)

numClass = size(z,2);

if numClass==2

    myAx=splitAxes(3,1);

    axes(myAx{1});
    plot(z(:,1),'r-');
    hold on;
    plot(z(:,2),'g-');
    legend(str1,str2);

    axes(myAx{2});
    plot(z(:,1),'r-');
    legend(str1);

    axes(myAx{3});
    plot(z(:,2),'g-');
    legend(str2);

    myAx{1};
elseif numClass==1
    figure,plot(z,'k-');
    legend(str1);
end