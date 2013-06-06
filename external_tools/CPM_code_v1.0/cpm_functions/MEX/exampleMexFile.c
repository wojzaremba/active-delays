   #include "mex.h"
   #include "nan.h"

   /*
    * zeroEqHes.c  this is the same as zeroEq.c, but also computes the Hessian
    */

  #define GTINDEX(I,J, NUMROWS, NUMCOLS) (J * NUMROWS + I)

   void zeroEqJac(double *a, double *I, double *U, double sigma, int basisSize, 
	int numPixels, double* L, double* M, double* J)
   {
     int pix,i,j;
     double res2,wght, res;
     double oneOverDenom, *Uptr, *Aptr, *Iptr, *Lptr, *U2ptr, *Mptr, *Jptr;
     const double sigma2=sigma*sigma;
     double wghtdI, wghtdU, wuu;

     //initialize L and M to be all zero (done with mxCreateArray)
    
     Iptr=I;
     //now do the computation
     for (pix=0; pix<numPixels; pix++,Iptr++) {
	//first calculate the residual
	res=*Iptr;
	Uptr=&(U[pix]); Aptr=a;
	for (j=0;j<basisSize;j++,Aptr++,Uptr+=numPixels)
	  //res-=U[GTINDEX(pix,j,numPixels,basisSize)]*a[j];
	  res-=*Uptr * *Aptr;

	res2=res*res;
	oneOverDenom=res2+sigma2;
	oneOverDenom=1.0/oneOverDenom; //i.e. this equals 1/(res^2 + sig^2);
	//wght=2.0*sigma2/(res2+sigma2)/(res2+sigma2);
	//wght=2.0*sigma2/(denom*denom);
	wght=2.0*sigma2 *oneOverDenom*oneOverDenom;

	//now calculate L
	Uptr=&(U[pix]); Mptr=M;
	wghtdI=wght * *Iptr;

	for (i=0;i<basisSize;i++,Uptr+=numPixels, Mptr++) {
	  *Mptr+=*Uptr * wghtdI;
	  Lptr=&(L[i]);
	  wghtdU=wght * *Uptr;
	  U2ptr=&(U[pix]); Jptr=&(J[i]);
	  for (j=0;j<basisSize;j++,Lptr+=basisSize,U2ptr+=numPixels,Jptr+=basisSize){
	    wuu= wghtdU * *U2ptr;
	    *Lptr += wuu;
	    *Jptr += wuu * (4.0 * res * -res * oneOverDenom + 1.0);
	    //J[GTINDEX(i,j,basisSize,basisSize)] 
	    //+= wuu * (4.0 * res * (*Iptr-res) * oneOverDenom + 1.0);
	  }
	}	
     }
   }

   /* The gateway routine */
   void mexFunction( int nlhs, mxArray *plhs[],
                     int nrhs, const mxArray *prhs[])
   {
     double *L,*M,*a,*I,*U, *J;
     double sigma;
     int  basisSize,numPixels,i,j,max,min,count;
     
     /*  Check for proper number of arguments. */
     if(nrhs!=6) 
       mexErrMsgTxt("Six inputs required.");
     if(nlhs!=3) 
       mexErrMsgTxt("Three output required.");
          
     /*  Create a pointer to the input matrixes a,I,U. */
     a = mxGetPr(prhs[0]);
     I = mxGetPr(prhs[1]);
     U = mxGetPr(prhs[2]);

     /*  Get the scalar inputs, basisSize,numPixels. */
     sigma= mxGetScalar(prhs[3]);
     basisSize = mxGetScalar(prhs[4]);
     numPixels = mxGetScalar(prhs[5]);
	
     /*  Set the output pointers to the output matrix. */
     plhs[0] = mxCreateDoubleMatrix(basisSize,basisSize, mxREAL);  //L e x e
     plhs[1] = mxCreateDoubleMatrix(basisSize,1, mxREAL);  //M e x 1
     plhs[2] = mxCreateDoubleMatrix(basisSize,basisSize, mxREAL);  //Jacobian/Hessian

     /*  Create a C pointer to a copy of the output matrixes. */
     L = mxGetPr(plhs[0]);
     M = mxGetPr(plhs[1]);
     J = mxGetPr(plhs[2]);

     
     /*  Call the C subroutine. */
     zeroEqJac(a,I,U,sigma,basisSize,numPixels,L,M,J);
     
   }
