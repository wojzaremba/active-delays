%function myPrint(FP,str);
function myPrint(FP,str);

%% print str both to the screen, and to the file given by FP
fprintf([str '\n']);
if FP>0
    fprintf(FP,[str '\n']);
end

