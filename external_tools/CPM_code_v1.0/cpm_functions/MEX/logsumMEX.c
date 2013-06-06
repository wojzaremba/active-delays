   #include "mex.h"
   #include "math.h"
 
   /*
    * logsum.c.c  
    returns the log of sum of logs, summing over dimension dim
    computes ls = log(sum(exp(x),dim))
    but in a way that tries to avoid underflow/overflow
    
    basic idea: shift before exp and reshift back
    log(sum(exp(x))) = alpha + log(sum(exp(x-alpha)));
    
   */



/* quick defintion to be able to access two dimensional array representation */
#define GTINDEX(I,J, NUMROWS, NUMCOLS) (J * NUMROWS + I)

void logsumMEX(double *x, double *mysum, int numRows, int numCols, 
	       double *alphas)
     {
       int c, r;
       double tempSum, temp, nanvalue, infvalue, realmax, nullvalue;
       double *xPtr, *alphaPtr, *mysumPtr;

       /*nanvalue = mxGetNaN();*/
       /*infvalue = mxGetInf();*/
       realmax = -1.7e+308;
       nullvalue=realmax;
       /*mexPrintf("%f\n", nanvalue);*/

       alphaPtr = alphas;
       xPtr = x;
       mysumPtr = mysum;
       for (c=0; c<numCols; c++) {	 
	 tempSum=0;
	 for (r=0; r<numRows; r++) {
	   /*mexPrintf("%f %d\n", *xPtr,isinf(*xPtr));*/
	   if (!(-isinf(*xPtr))){
	     tempSum = tempSum + 
	       exp(*xPtr - *alphaPtr);
	   }
	   xPtr++;
	 }	 
	 if (tempSum!=0) {
	   tempSum = log(tempSum) + *alphaPtr;   
	 } else {
	   tempSum = nullvalue;
	 }
	 *mysumPtr = tempSum;
	 alphaPtr++;
	 mysumPtr++;
       }
       /* READABLE VERSION OF CODE ABOVE /*
       /*
       for (c=0; c<numCols; c++) {	 
	 tempSum=0;
	 for (r=0; r<numRows; r++) {
	   tempSum = tempSum + exp(x[GTINDEX(r,c,numRows,numCols)] - alphas[c]);
	 }	 
	 tempSum = log(tempSum) + alphas[c];   
	 mysum[c]=tempSum;
       }
       */
     }

   /***********************/
   /* The gateway routine */
   /* The function should be called as follows:
      mysum = logsum(data,alphas)
      
      It doesn't take a dim variable as the .m function does
      because this is taken care of in a matlab interface to
      this function.  Instead, this function always sums over
      the first dimension.  Alpha is the rescaling factor.
    */

   void mexFunction( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
   {

     double *x, *mysum, *alphas;
     int numRows,numCols;
     
     /*  Check for proper number of arguments. */
     if(nrhs!=2) 
       mexErrMsgTxt("Two inputs required.");
     if(nlhs!=1) 
       mexErrMsgTxt("One output required.");
          
     /*  Create a pointer to the input matrixes */
     x = mxGetPr(prhs[0]);
     alphas = mxGetPr(prhs[1]);

     /* Set some constants we will need to allocate output memory */
     numRows = mxGetM(prhs[0]);
     numCols = mxGetN(prhs[0]);
     /*
     mexPrintf("size(x)=[%d %d]\n", numRows,numCols);
     mexPrintf("x[1][0]=%f\n", x[GTINDEX(1,0,numRows,numCols)]);
     mexPrintf("alphas(2)=%f\n", alphas[1]);
     */

     /*  Set the output pointers to the output matrix. */
     plhs[0] = mxCreateDoubleMatrix(1,numCols,mxREAL);

     /*  Create a C pointer to a copy of the output matrixes. */
     mysum = mxGetPr(plhs[0]);

     /*  Call the C subroutine. */
     logsumMEX(x,mysum,numRows,numCols,alphas);
   }
