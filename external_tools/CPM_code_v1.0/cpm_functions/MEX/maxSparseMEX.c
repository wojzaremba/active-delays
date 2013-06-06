   #include "mex.h"
   #include "math.h"
 
   /*
    * maxSparseMEX.c  
    Compute the max over each row, ignoring the empty values in the
    array (which matlab would treat as zeros)    
   */


/* quick defintion to be able to access two dimensional array representation */
/*#define GTINDEX(I,J, NUMROWS, NUMCOLS) (J * NUMROWS + I)*/
/*#define MAX(a,b) (((a)>(b))?(a):(b))*/

void maxSparseMEX(double *pr, int *ir, int *jc, int numRows, int numCols, 
		  double *mymax, double* maxInd)
     {

       int c, r, j, k;
       double tempMax, infvalue;

       infvalue = mxGetInf();

       for (j=0; j<numCols; j++) {
	 tempMax = -infvalue;
	 maxInd[j] = 1.0; /* so as to behave like max in matlab*/
	 for (k=jc[j]; k<jc[j+1]; k++) {
	   if (pr[k]>tempMax){
	     tempMax = pr[k];
	     maxInd[j] = ir[k] + 1;
	   }
	 }
	 mymax[j]=tempMax;
       }
     }

   /***********************/
   /* The gateway routine */
   /* The function should be called as follows:
      mymax = maxSparseMEX(x)
      where x is a sparse matrix

    */

   void mexFunction( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
   {

     double *x, *mymax, *pr, *maxind;
     int numRows,numCols, *ir, *jc;
     
     /*  Check for proper number of arguments. */
     if(nrhs!=1) 
       mexErrMsgTxt("One inputs required.");
     if(nlhs!=2) 
       mexErrMsgTxt("Two output required.");
          
     /*  Create a pointer to the input matrixes */
     if (!mxIsSparse(prhs[0]))
       mexErrMsgTxt("Input should be a sparse matrix.");

     /*x = mxGetPr(prhs[0]);*/

     /* Set some constants we will need to allocate output memory */
     numRows = mxGetM(prhs[0]);
     numCols = mxGetN(prhs[0]);

     /*
     mexPrintf("size(x)=[%d %d]\n", numRows,numCols);
     mexPrintf("x[1][0]=%f\n", x[GTINDEX(1,0,numRows,numCols)]);
     */

     /*  Set the output pointers to the output matrix. */
     plhs[0] = mxCreateDoubleMatrix(1,numCols,mxREAL);
     plhs[1] = mxCreateDoubleMatrix(1,numCols,mxREAL);

     /*  Create a C pointer to a copy of the output matrixes. */
     mymax = mxGetPr(plhs[0]);
     maxind = mxGetPr(plhs[1]);

     /* get data needed to access sparse matrix */
     ir = mxGetIr(prhs[0]);  /* zero-based, entry is a row */
     jc = mxGetJc(prhs[0]);  /* jc array is an integer array having n+1 elements where n is the number of columns in the sparse mxArray*/
     pr = mxGetPr(prhs[0]); /* the sparse matrix entry correspoding to ir array*/

     /*  Call the C subroutine. */
     maxSparseMEX(pr,ir,jc,numRows,numCols, mymax,maxind);
   }
