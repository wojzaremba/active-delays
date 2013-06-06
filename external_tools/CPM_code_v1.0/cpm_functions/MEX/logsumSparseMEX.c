   #include "mex.h"
   #include "math.h"
 
   /*
    * logsumSparseMEX.c  
    Compute the sum over each row, ignoring the empty values in the
    array (which matlab would treat as zeros)    
    i.e. it is similar to calling logsum(data,1)
   */


/* quick defintion to be able to access two dimensional array representation */
/*#define GTINDEX(I,J, NUMROWS, NUMCOLS) (J * NUMROWS + I)*/

void logsumSparseMEX(double *pr, int *ir, int *jc, int numRows, int numCols, 
		  double* alphas, double *mysum)
     {
       int c, r, j, k;
       double tempSum, infvalue, *alphaPtr, *mysumPtr;

       alphaPtr = alphas;
       mysumPtr = mysum;
       infvalue = -1.0*mxGetInf();
       for (j=0; j<numCols; j++) {
	 tempSum = 0;
	 for (k=jc[j]; k<jc[j+1]; k++) {
	     tempSum += exp(pr[k] - *alphaPtr);
	   }
	 if (tempSum != 0) {
	   *mysumPtr=log(tempSum) + *alphaPtr;
	 } else {
	   *mysumPtr=infvalue;
	 }
	 alphaPtr++;
	 mysumPtr++;
       }
     }

   /***********************/
   /* The gateway routine */
   /* The function should be called as follows:
      mysum = logsumSparseMEX(x,alphas)
      where x is a sparse matrix

    */

   void mexFunction( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
   {

     double *x, *mysum, *pr, *alphas;
     int numRows,numCols, *ir, *jc;
     
     /*  Check for proper number of arguments. */
     if(nrhs!=2) 
       mexErrMsgTxt("Two inputs required.");
     if(nlhs!=1) 
       mexErrMsgTxt("One output required.");
          
     /*  Create a pointer to the input matrixes */
     if (!mxIsSparse(prhs[0]))
       mexErrMsgTxt("Input should be a sparse matrix.");

     /*x = mxGetPr(prhs[0]);*/
     alphas = mxGetPr(prhs[1]);

     /* Set some constants we will need to allocate output memory */
     numRows = mxGetM(prhs[0]);
     numCols = mxGetN(prhs[0]);

     /*
     mexPrintf("size(x)=[%d %d]\n", numRows,numCols);
     mexPrintf("x[1][0]=%f\n", x[GTINDEX(1,0,numRows,numCols)]);
     */

     /*  Set the output pointers to the output matrix. */
     plhs[0] = mxCreateDoubleMatrix(1,numCols,mxREAL);

     /*  Create a C pointer to a copy of the output matrixes. */
     mysum = mxGetPr(plhs[0]);

     /* get data needed to access sparse matrix */
     ir = mxGetIr(prhs[0]);  /* zero-based, entry is a row */
     jc = mxGetJc(prhs[0]);  /* jc array is an integer array having n+1 elements where n is the number of columns in the sparse mxArray*/
     pr = mxGetPr(prhs[0]); /* the sparse matrix entry correspoding to ir array*/

     /*  Call the C subroutine. */
     logsumSparseMEX(pr,ir,jc,numRows,numCols, alphas,mysum);
   }
