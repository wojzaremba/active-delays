% function myClass = getClass(G,ss)
% 
% returns the class that sample ss belongs to, given the field
% G.class

function myClass = getClass(G,ss)

myClass = 0;

for cc=1:G.numClass
  if (ismember(ss,G.class{cc}))
    myClass=cc;
  end
end

if ~myClass
  G.class{:}
  ss
  error('No class found');
end
