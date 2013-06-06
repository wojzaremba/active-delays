%function st = printStruct(output)
%
% prints structure fields, one to a line, to string, 'st'

function st = printStruct(output)

st='';

if ~isempty(output)
  
  fn=fieldnames(output);

  for jj=1:length(fn)
    tmpNm=fn{jj};
    thisField=getfield(output,tmpNm);
    isTooBig = prod(size(thisField))>5;
    if ((~isTooBig | ischar(thisField)) & ~isempty(thisField))
      if isnumeric(thisField)
	thisField=num2str(thisField(:)');
      end
      nxt=[tmpNm '=' thisField];
      st = [st sprintf('%s\n',nxt)];
    end
  end

end
