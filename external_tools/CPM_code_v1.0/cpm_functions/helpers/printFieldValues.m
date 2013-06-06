function tmpStr = printFieldValues(G,fieldList)

tmpStr='';
for ff=1:length(fieldList)
  if (isfield(G,fieldList{ff}))
    newStr = ['G.' fieldList{ff} '=' num2str(getfield(G,fieldList{ff}),5)];
    tmpStr = [tmpStr newStr '\n'];
  end
end
