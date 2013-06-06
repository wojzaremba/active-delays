%function [expSet,newGKeep,useThese,newTrace,likes]=preAlign(expSet,setSize)
%
% Load up the spiked data set, and train the model
% using expSet \in [1 2 3 4 5], each of which consists
% of 4 repeats.  
%
% setSize is the number of replicates to train at at time
% (perahps less than numReplicates if corss-validating)
% expSet is which experiment to work on


function [expSet,newGKeep,useThese,newTrace,likes]=preAlign(expSet,setSize)

%myDir = '/u/jenn/phd/MS/data/cocktail16/';
myDir = '/u/jenn/phd/MS/data/spikedInData/';

eval(['load ' '''' myDir 'data.mat''']); 

%%For testing%%%%%%%%%%%%%%%%%%%%%%%
if (0)%HERE
  %expSet=2; 
  keepMe=1:20
  for ii=1:length(headerAbun)
    temp=headerAbun{ii};
    headerAbun{ii}=temp(keepMe);
    temp=qmz{ii};
    qmz{ii}=temp(keepMe,1:100);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numReplicate=4;
%% DATA TO USE
if (~exist('setSize'))
  setSize=4;
end

numPerm = choose(numReplicate,setSize);

% log files, etc.
savedir = '/u/jenn/phd/MS/matlabCode/workspaces/spiked/';
basename = [savedir 'spikedData_PREL_Exp' num2str(expSet) 'setSize' num2str(setSize) '.' filenameStamp];

logfile = [basename '.LOG'];
savefile = [basename '.mat'];
savefileFINISHED = [basename '.FINISHED'];

savevars = 'latentTrace expSet repSet setSize newGKeep useThese newTrace likes scaleAndTimes';

cmd1 = ['save ''' savefile ''' expSet;'];
cmd2 = ['save ''' savefile ''' ' savevars ];
cmd3 = ['save ''' savefileFINISHED ''' savefileFINISHED ;'];

eval(cmd1);

display(['Will save results to: ' savefile]);

useThese=cell(1,numPerm);

for repSet=1:numPerm
  %expSet=4; repSet=4; setSize=3;
  firstInd=(expSet-1)*numReplicate +1;
  tempSet = mod((repSet-1):(repSet+setSize-1-1),numReplicate)+1;
  useThese{repSet} = tempSet+firstInd-1;
  %useThese=firstInd:(firstInd+numReplicate-1);
  allSamp = headerAbun(useThese{repSet});

  [scaleAndTimes,newTrace,newG,likes,latentTrace] = translateAlign(allSamp,logfile);
  
  newGKeep{repSet}.D=newG.D;
  newGKeep{repSet}.S=newG.S;
  newGKeep{repSet}.sigmas=newG.sigmas;

  eval(cmd2);
end


eval(cmd3);

return;




%% look at results
figure, plot(likes,'-^'); title('Likelihood Over Iterations of Training');

%% show final and initial
figure, plot(latentTrace,'r-*','MarkerSize',2); hold on;
plot(allTraces(end,:), 'k-*','MarkerSize',2);
legend('Initial Trace', 'Final Trace');
title('Initial Versus Converged Latent Trace Using FB');
%savefigures(1,1,'initialVSfinalTrace');

%%%%%% View Viterbi alignments to final trace

% display all before alignments
figure,subplot(2,1,1),showHeaderAbun(allSamp);
title('Replicate Total Ion Counts, Uncallibrated and Callibrated');
xlabel('');
% display all after alignments, with the latent trace
subplot(2,1,2),showAlignedAll(G,allSamp,scaleAndTimes,newTrace);
%title('Aligned Experimental TICs');
title(''); ylabel(''); xlabel('Time');
%savefigures(1,1,'allTraces','psc2');
%savefigures(1,1,'allTraces'); closefigures(1);

%% Display the alignment with final trace:
[H,allAxes]=getAxes;
for ii=1:G.numSamples
  st = squeeze(scaleAndTimes(ii,:,:));
  mytitle=['Replicate ' num2str(ii)];
  displayAlignment(G,allAxes,newTrace,st,allSamp{ii},mytitle);
  filename = '/u/jenn/temp/matlabFigures/'
  %saveas(H,[filename 'viterbiAlignment' num2str(ii) '.eps'],'psc2');
  %saveas(H,[filename 'viterbiAlignment' num2str(ii) '.jpg']);
  pause;
end

