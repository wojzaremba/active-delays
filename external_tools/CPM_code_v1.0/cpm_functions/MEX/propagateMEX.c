   #include "mex.h"
   #include <math.h>
 
   /*
    * propagate.c.c  Perform the forward, backward and viterbi on a sequence,
                     given a latent trace, a sample, and model constants.

      propagate.c(oneSample, latentTrace, taus, scales, stMap, 
      stateToScale,stateToTau,scaleTransLog, timeTransLog, stateLogPrior, 
      maxTimeSteps, maxScaleSteps,scaleAndTime,alphaslog,betaslog)
      
      There is a difficulty in indexing everything since C is zero-based, and
      Matlab is 1-based (for arrays).  We will still call the states by the same
      names/numbers, but the relevant arrays have had one subtraced off them when
      called from matlab, and also, things like scales, taus, latentTrace, etc. need
      to be called with (state-1).

      Allocation of space for all local arrays is performed only in propagateMEX
   */

/* Returns the number of elements in the array */
#define NumElm(array) (sizeof (array) / sizeof ((array)[0]))

/* quick defintion to be able to access two dimensional array representation */
#define GTINDEX(I,J, NUMROWS, NUMCOLS) (J * NUMROWS + I)

#define MAX(x,y)  ( (x)>(y) ? (x) : (y) )
#define MIN(x,y)  ( (x)<(y) ? (x) : (y) )

/* Global variables */
int numTaus, numScales, numStates, numRealTimes;
int maxTimeSteps, maxScaleSteps;
double *oneSample, *latentTrace, *taus, *scales, *stMap, scaleSigma;
double *scaleTransLog, *timeTransLog, *stateLogPrior;
double *stateToScale, *stateToTau;
double *scaleAndTime, *alphaslog, *betaslog, *vitlog;
double emissionSigma;

/* print out inmt array */
void printIntArray(int *someArray, int length) {
  int j;
  mexPrintf("--START-----\n");
  for (j=0; j<length; j++) {
    mexPrintf("%d\n", someArray[j]);
  }
  mexPrintf("**END*******\n");
}

/* print out double array */
void printDouArray(double *someArray, int length) {
  int j;
  mexPrintf("--START-----\n");
  for (j=0; j<length; j++) {
    mexPrintf("%f\n", someArray[j]);
  }
  mexPrintf("**END*******\n");
}



/* expects that myScaleInd and myTau are indexed for C */
void getStateTransIn(int myScaleInd, int myTau, int *precStates, int *precTaus, int *precScales, int *numPrecStates) {

  int maxTau, minTau, maxScale, minScale, numPrecTaus, numPrecScales, st, s, t;
  int *allowedScaleInd, *allowedTaus;

  maxTau = (myTau-1);
  /*mexPrintf("maxTau:%d\n", maxTau); */
  minTau = MAX(0,(myTau-maxTimeSteps));

  maxScale = MIN(numScales-1, myScaleInd+maxScaleSteps);
  minScale = MAX(0,(myScaleInd-maxScaleSteps));

  *numPrecStates = (maxTau-minTau+1)*(maxScale-minScale+1);

  for (st=0, t=minTau; t<=maxTau; t++) {
    for (s=minScale; s<=maxScale; s++) {
      precScales[st] = s;
      precTaus[st] = t;
      precStates[st++]= stMap[GTINDEX(s,t,numScales,numTaus)];
    }
  }

}

/* expects that myScaleInd and myTau are indexed for C */
void getStateTransOut(int myScaleInd, int myTau, int *succStates, int *succTaus, int *succScales, int *numSuccStates) {

  int maxTau, minTau, maxScale, minScale, numSuccTaus, numSuccScales, st, s, t;
  int *allowedScaleInd, *allowedTaus;

  maxTau = MIN(myTau+maxTimeSteps,numTaus-1);
  /*mexPrintf("maxTau:%d\n", maxTau); */
  minTau = MIN(numTaus+1-1,myTau+1);

  maxScale = MIN(numScales-1,(myScaleInd+maxScaleSteps));
  minScale = MAX(0,(myScaleInd-maxScaleSteps));

  *numSuccStates = (maxTau-minTau+1)*(maxScale-minScale+1);

  for (st=0, t=minTau; t<=maxTau; t++) {
    for (s=minScale; s<=maxScale; s++) {
      succScales[st] = s;
      succTaus[st] = t;
      succStates[st++]= stMap[GTINDEX(s,t,numScales,numTaus)];
    }
  }

}


/* Calculate the log probability of a sample trace value for one state
   OUTPUT: vector 'result'.  State=5 here means state=6 in matlab */
double traceLogProb(double val, int oneState) {

  int j, tempTauInd;
  double tempMu, firstPart, thirdPart, result, traceLogConstant;


  /* firstPart = log((sqrt(2*pi)*emissionSigma)^-1); */
  /* mexPrintf("emissionSigma = %f\n", emissionSigma); */
     /* mexPrintf("numTaus = %d\n", numTaus); */
  firstPart = log(M_2_SQRTPI*M_SQRT1_2/2*(1/emissionSigma));
  /*mexPrintf("firstPart = %f\n", firstPart); */
  thirdPart = 2*pow(emissionSigma,2);
  /* mexPrintf("thirdPart: %f\n", thirdPart); */
  traceLogConstant = pow(2,scales[(int) (stateToScale[oneState])]);
  mexPrintf("state: %d\n", oneState);
  mexPrintf("stateToScale[oneState]=%f %d\n",  stateToScale[oneState], oneState);
  /*
  mexPrintf("traceLogConstant %f\n", traceLogConstant);*/
  
  tempTauInd = stateToTau[oneState];
  tempMu = traceLogConstant*latentTrace[tempTauInd];
  /*result = lognormpdf() */
  result = firstPart - pow((val-tempMu),2)/thirdPart;
  result = result;

  /* mexPrintf("%f\n", result);*/
  
  
  return result;
}


void propagateMEX()
     /* alphas, betas: numTaus x numRealTimes*/
     {
       /* variables for getStateTransIn */
       int myScaleInd, myTau, temp;
       int *precStates, *precTaus, *precScales;
       int *numPrecStates;

       /* variables for getStateTransOut */
       int *succStates, *succTaus, *succScales;
       /* st=state, rt=realTime, bt=backwardTime */
       int *numSuccStates, st, rt, bt;

       /* other variables */
       double emissionProb, stateTransProb, tempSum;

       /* allocate memory for local computations */
       precStates = malloc(numStates*sizeof(int));
       precScales = malloc(numStates*sizeof(int));
       precTaus   = malloc(numStates*sizeof(int));
       numPrecStates = malloc(1*sizeof(int));

       succStates = malloc(numStates*sizeof(int));
       succScales = malloc(numStates*sizeof(int));
       succTaus   = malloc(numStates*sizeof(int));
       numSuccStates = malloc(1*sizeof(int));

       /* INITIALIZATION for alphas, betas, etc.*/
       /*
       for (st=0; st<numStates; st++) {
	 alphaslog[GTINDEX(st,0,numStates,numRealTimes)]=stateLogPrior[st] + traceLogProb(oneSample[0],st);
	 betaslog[GTINDEX(st,numRealTimes-1,numStates,numRealTimes)]=0;
	 vitlog[GTINDEX(st,0,numStates,numRealTimes)]=stateLogPrior[st] + traceLogProb(oneSample[0],st);
       }
       */

       /* DYNAMIC PROGRAMMING */
       for (rt=1; rt<numRealTimes; rt++) {
	 for (st=0; st<numStates; st++) {
	   /*myScaleInd = (int) (stateToScale[st]);*/
	   /*
	   myTau = stateToTau[st];
	   */

	   /* FORWARD */
	   /*
	   getStateTransIn(myScaleInd, myTau, precStates, precTaus, precScales, numPrecStates);
	   */
	   
	   /*
	   stateTransProb = 
	   tempSum = ();
	   alphaslog[GTINDEX(st,rt,numStates,numRealTimes)]=stateLogPrior[st] + traceLogProb(oneSample[rt],st);
	   */

	   /* VITERBI */

	   /* BACKWARD */
	   /*
	   bt=numRealTimes-rt-1;
	   */

	 }
       }
       




       /*
       alphaslog[GTINDEX(0,0,numTaus,numRealTimes)] = traceLogProb(10001.0,5);
       */

       myScaleInd=numScales-1; myTau=numTaus-1;       

       /*
       getStateTransIn(myScaleInd, myTau, precStates, precTaus, precScales, numPrecStates);
       mexPrintf("numPrecStates:%d\n", *numPrecStates);
       mexPrintf("precTaus\n");
       printIntArray(precTaus,*numPrecStates);
       mexPrintf("precScales\n");
       printIntArray(precScales,*numPrecStates);
       */



       /*
       getStateTransOut(myScaleInd, myTau, succStates, succTaus, succScales, numSuccStates);
       mexPrintf("numSuccStates:%d\n", *numSuccStates);
       mexPrintf("succTaus\n");
       printIntArray(succTaus,*numSuccStates);
       mexPrintf("succScales\n");
       printIntArray(succScales,*numSuccStates);       
       */


       free(precStates); free(precTaus); 
       free(precScales); free(numPrecStates);
       free(succStates); free(succTaus); 
       free(succScales); free(numSuccStates);

     }

   /***********************/
   /* The gateway routine */
   /* The function should be called as follows:
      [scaleAndTime, alphaslog, betaslog] = propagateMEX(oneSample, latentTrace, 
                   taus, scales, stMap, stateToScale,stateToTau, scaleTransLog, 
                   timeTransLog, stateLogPrior, maxTimeSteps, maxScaleSteps, scaleSigma)

      For full description of these items, please go to bottom of the file
   */

   void mexFunction( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
   {

     int temp;
     
     /*  Check for proper number of arguments. */
     if(nrhs!=13) 
       mexErrMsgTxt("Thirteen inputs required.");
     if(nlhs<3) 
       mexErrMsgTxt("Min of three output required.");
          
     /*  Create a pointer to the input matrixes */
     oneSample = mxGetPr(prhs[0]);
     latentTrace = mxGetPr(prhs[1]);
     taus = mxGetPr(prhs[2]);
     scales = mxGetPr(prhs[3]);
     stMap = mxGetPr(prhs[4]);
     stateToScale = mxGetPr(prhs[5]);
     stateToTau = mxGetPr(prhs[6]);
     scaleTransLog = mxGetPr(prhs[7]);
     timeTransLog = mxGetPr(prhs[8]);
     stateLogPrior = mxGetPr(prhs[9]);

     /*  Get the scalar inputs */
     maxTimeSteps = mxGetScalar(prhs[10]);
     maxScaleSteps = mxGetScalar(prhs[11]);
     scaleSigma = mxGetScalar(prhs[12]);

     /* Set some constants we will need to allocate output memory */
     numTaus = mxGetN(prhs[2]);
     numScales = mxGetN(prhs[3]);
     numStates = numTaus*numScales;
     numRealTimes = mxGetN(prhs[0]);

     /*
     temp = mxGetN(prhs[5]);
     mexPrintf("mxGetN(stateToScale)=%d\n",temp);
     */
     
     /*  Set the output pointers to the output matrix. */
     plhs[0] = mxCreateDoubleMatrix(numRealTimes,2, mxREAL);  /*scaleAndTime*/
     plhs[1] = mxCreateDoubleMatrix(numTaus,numRealTimes, mxREAL);  /*alphaslog*/
     plhs[2] = mxCreateDoubleMatrix(numTaus,numRealTimes, mxREAL);  /*betaslog*/
     plhs[3] = mxCreateDoubleMatrix(numTaus,numRealTimes, mxREAL);  /*vitlog*/

     /*  Create a C pointer to a copy of the output matrixes. */
     scaleAndTime = mxGetPr(plhs[0]);
     alphaslog = mxGetPr(plhs[1]);
     betaslog = mxGetPr(plhs[2]);
     vitlog = mxGetPr(plhs[3]);
     
     emissionSigma = 2.0767e+08;
     /* mexPrintf("emissionSigma = %f\n", emissionSigma); */
     
     
     /*  Call the C subroutine. */
     propagateMEX();     
   }


/*  OUTPUT:
    scaleAndTime   numRealTimes x 2, scale and time factors from viterbi path
    alphaslog      numTaus x numRealStates, logged alphas 
    betaslog       numTaus x numRealStates, logged betas

    INPUT:
    oneSample      1 x numRealTimes, a sample trace
    latentTrace    1 x numTaus, the latent trace
    taus           1 x numTaus, the labels for the fake time points (time states)
    scales         1 x numScales, the scales used (eg. -0.5:0.1:0.5)
    maxTimeSteps   1 x 1, the maximum number of time steps allowed (forward only)
    maxScaleSteps  1 x 1, the maximum number of scale steps allowed (forw/back)
    stMap          numScales x numTaus, mapping from (scale,tau)->state
    stateToScale numStates x 1, mapping from state->(scale)
    stateToTau numStates x 1, mapping from state->(tau)
    scaleTransLog  numScales x numScales, log of scale transition probs
    timeTransLog   numTau x numTau, log of time transition probs
    stateLogPrior  1 x numScales, prior for beginning states
*/
