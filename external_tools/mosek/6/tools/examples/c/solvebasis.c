/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      solvebasis.c

  Purpose:   To demonstrate the usage of
             MSK_solvewithbasis on the problem:
 
             maximize  x0 + x1
             st. 
                     x0 + 2.0 x1 <= 2
                     x0  +    x1 <= 6
                     x0 >= 0, x1>= 0

               The problem has the slack variables
               xc0, xc1 on the constraints
               and the variables x0 and x1.

               maximize  x0 + x1
               st. 
                  x0 + 2.0 x1 -xc1       = 2
                  x0  +    x1       -xc2 = 6                     
                  x0 >= 0, x1>= 0,
                  xc1 <=  0 , xc2 <= 0


             problem data is read from basissolve.lp.

  Syntax:    solvebasis basissolve.lp     
                  
 */
#include "mosek.h"

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char **argv)
{
  MSKenv_t  env;
  MSKtask_t task;
  MSKintt NUMCON = 2;
  MSKintt NUMVAR = 2;
  
  double       c[]    = {1.0, 1.0};
  MSKintt      ptrb[] = {0, 2};
  MSKintt      ptre[] = {2, 3};
  MSKidxt      asub[] = {0, 1,
                        0, 1};
  double aval[] = {1.0, 1.0,
                   2.0, 1.0};
  MSKboundkeye bkc[]  = {MSK_BK_UP,
                       MSK_BK_UP};
  
  double blc[]  = {-MSK_INFINITY,
                   -MSK_INFINITY};
  double buc[]  = {2.0,
                   6.0};
  
  MSKboundkeye  bkx[]  = {MSK_BK_LO,
                          MSK_BK_LO};
  double  blx[]  = {0.0,
                    0.0};
  
  double  bux[]  = {+MSK_INFINITY,
                    +MSK_INFINITY};
  
  
  MSKrescodee       r = MSK_RES_OK;
  MSKidxt       i,nz;
  double    w1[] = {2.0,6.0};
  double    w2[] = {1.0,0.0};
  MSKidxt   sub[] = {0,1};
  MSKidxt   *basis;
    
  if (r == MSK_RES_OK)
    r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);
  
  if ( r==MSK_RES_OK )
    r = MSK_makeemptytask(env,&task);
  
  if ( r==MSK_RES_OK )
      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);  

  if ( r == MSK_RES_OK)
    r = MSK_inputdata(task, NUMCON,NUMVAR, NUMCON,NUMVAR, c, 0.0,
                      ptrb, ptre, asub, aval, bkc, blc, buc, bkx, blx, bux);

  if (r == MSK_RES_OK)
    r = MSK_putobjsense(task,MSK_OBJECTIVE_SENSE_MAXIMIZE); 

  
 
  if (r == MSK_RES_OK)
    r = MSK_optimize(task);

  if (r == MSK_RES_OK)
    basis = MSK_calloctask(task,NUMCON,sizeof(MSKidxt));
  
  if (r == MSK_RES_OK)
    r = MSK_initbasissolve(task,basis);

  /* List basis variables corresponding to columns of B */
  for (i=0;i<NUMCON && r == MSK_RES_OK;++i)
  {
    printf("basis[%d] = %d\n",i,basis[i]);   
    if (basis[sub[i]] < NUMCON)
      printf ("Basis variable no %d is xc%d.\n",i, basis[i]);
    else
      printf ("Basis variable no %d is x%d.\n",i,basis[i] - NUMCON); 
  }
  
  nz = 2;
  /* solve Bx = w1 */
  /* sub contains index of non-zeros in w1.
     On return w1 contains the solution x and sub 
     the index of the non-zeros in x. 
   */
  if (r == MSK_RES_OK)
    r = MSK_solvewithbasis(task,0,&nz,sub,w1);

  if (r == MSK_RES_OK)
  {
    printf("\nSolution to Bx = w1:\n\n");

    /* Print solution and b. */

    for (i=0;i<nz;++i) 
    {    
      if (basis[sub[i]] < NUMCON)     
        printf ("xc%d = %e\n",basis[sub[i]] , w1[sub[i]] );     
      else   
        printf ("x%d = %e\n",basis[sub[i]] - NUMCON , w1[sub[i]] );   
    }
  } 
    /* Solve B^Tx = c */
  nz = 2;
  sub[0] = 0;
  sub[1] = 1;

  if (r == MSK_RES_OK)  
    r = MSK_solvewithbasis(task,1,&nz,sub,w2);

  if (r == MSK_RES_OK)
  {
    printf("\nSolution to B^Tx = w2:\n\n");
    /* Print solution and y. */
    for (i=0;i<nz;++i) 
    {    
      if (basis[sub[i]] < NUMCON)     
        printf ("xc%d = %e\n",basis[sub[i]] , w2[sub[i]] );    
      else   
        printf ("x%d = %e\n",basis[sub[i]] - NUMCON , w2[sub[i]] );   
    }
  }
   
   printf("Return code: %d (0 means no error occurred.)\n",r);
   
   return ( r );
   
}/* main */
