function  newClass=convertToOneClass(class);

tmpClass=class{1};
for j=2:length(class)
    tmpClass=[tmpClass class{j}];
end

newClass{1}=tmpClass;