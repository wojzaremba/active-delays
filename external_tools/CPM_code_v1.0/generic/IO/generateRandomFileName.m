function randFileName = generateRandomFileName()

randomNum = num2str(rand*1000000000,9);


randFileName = ['randFile_' randomNum];