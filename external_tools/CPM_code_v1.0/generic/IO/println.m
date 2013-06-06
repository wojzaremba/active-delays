function r = println(fid,str,TEST)

if ~(exist('TEST')==1)
    TEST=0;
end

if ~TEST
    r = fprintf(fid,'%s\n',str);
else
    r=[];
end