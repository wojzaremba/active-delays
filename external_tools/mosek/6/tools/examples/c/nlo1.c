/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      nlo1.c

   Purpose:   Demonstrate how to solve the following
              optimization problem

              minimize    f(x) + c^T x
              subject to  l^c <= a x <= u^c
                          l^x <=  x  <= u^x
              where f is a nonlinear (convex) function.

              The program solves the example:

              minimize    - x_0 - ln(x_1 + x_2)
              subject to  x_0 + x_1 + x_2 = 1
                          x_0, x_1, x_2 >= 0.

 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>


#include "mosek.h"   /* Include the MOSEK definition file. */

#define NUMCON   1   /* Number of constraints.             */
#define NUMVAR   3   /* Number of variables.               */
#define NUMANZ   3   /* Number of nonzeros i A.            */

static int MSKAPI
nlspar(void *nlhandle,
       int  *numgrdobjnz,
       int  *grdobjsub,
       int  i,
       int  *convali,
       int  *grdconinz,
       int  *grdconisub,
       int  yo,
       int  numycnz,
       int  ycsub[],
       int  maxnumhesnz,
       int  *numhesnz,
       int  *hessubi,
       int  *hessubj)
/* Purpose: Provide information to MOSEK about the problem
            structure and sparsity.
 */
{
  if ( numgrdobjnz )
  {
    numgrdobjnz[0] = 2; /* There are two nonlinear
                         * variables in the objective.
                         */

    if ( grdobjsub )
    {
      /* Store indicies of nonlinear variable in the
       * objective.
       */

      grdobjsub[0] = 1; /* x_1 appears nonlinearly
                         * in the objective.
                         */

      grdobjsub[1] = 2; /* x_2 appears nonlinearly
                         * in the objective.
                         */
    }
  }

  if ( convali )
    convali[0] = 0;    /* Zero because no nonlinear
                        * expression in the first constraint.
                        */

  if ( grdconinz )
    grdconinz[0] = 0;  /* Zero because no nonlinear
                        * expression in the first constraint.
                        */

  if ( numhesnz )
  {
    if ( yo )
      numhesnz[0] = 3; /* There are 3 non-zeros
                        * the lower triangular part
                        * of the Hessian.
                        */
    else
      numhesnz[0] = 0;
  }

  if ( maxnumhesnz )
  {
    /* Should return information about the Hessian too. */

    if ( maxnumhesnz<3 )
    {
      /* Not enough space have been allocated for
       * storing the Hessian.
       */

      return ( 1 );
    }
    else
    {
      if ( yo )
      {
        if  ( hessubi && hessubj )
        {
          /* Sparsity pattern of the non-zeros in the Hessian. */
          hessubi[0] = 1; hessubj[0] = 1;
          hessubi[1] = 2; hessubj[1] = 1;
          hessubi[2] = 2; hessubj[2] = 2;
        }
      }
    }
  }

  return ( 0 );
} /* nlspar */

static int MSKAPI
nleval(void   *nlhandle,
       double *xx,
       double yo,
       double *yc,
       double *objval,
       int    *numgrdobjnz,
       int    *grdobjsub,
       double *grdobjval,
       int    numi,
       int    *subi,
       double *conval,
       int    *grdconptrb,
       int    *grdconptre,
       int    *grdconsub,
       double *grdconval,
       double *grdlag,
       int    maxnumhesnz,
       int    *numhesnz,
       int    *hessubi,
       int    *hessubj,
       double *hesval)
/* Purpose: Evalute the nonlinear function and return the
            requested information to MOSEK.
 */
{
  int k;     

  if ( objval )
  {
    /* f(x) is computed and stored in objval[0]. */
    objval[0] = -log(xx[1] + xx[2]);
  }

  if ( numgrdobjnz )
  {
    /* Compute and store the gradient of the f. */
    numgrdobjnz[0] = 2;  /* Number non-zeros
                          * in gradient of f(x)
                          */

    /* First non-zero entry. */
    grdobjsub[0]   = 1;  grdobjval[0] = -1.0 / ( xx[1] + xx[2] );

    /* Second non-zero entry. */
    grdobjsub[1]   = 2;  grdobjval[1] = -1.0 / ( xx[1] + xx[2] );
  }

  if ( conval )
    for(k=0; k<numi; ++k)
      conval[k] = 0.0;

  if ( grdlag )
  {
    /* Compute and store the gradiant of the Lagrangian.
     * Note it is stored as a dense vector.
     */

    grdlag[0] = 0.0;
    grdlag[1] = -yo / ( xx[1] + xx[2] );
    grdlag[2] = -yo / ( xx[1] + xx[2] );
  }

  if ( maxnumhesnz )
  {
    /* Compute and store the Hessian of the Lagrangien
     * which in this case is identical to the gradient
     * of f.
     */

    if ( yo==0.0 )
    {
      numhesnz[0] = 0;
    }
    else
    {
      if ( maxnumhesnz<3 )
        return ( 0 );

      numhesnz[0] = 3;

      if ( hessubi && hessubj && hesval )
      {
        hessubi[0]  = 1; hessubj[0] = 1;
        hesval[0]   = yo / (( xx[1] + xx[2] )*( xx[1] + xx[2] ));

        hessubi[1]  = 2; hessubj[1] = 1;
        hesval[1]   = yo / (( xx[1] + xx[2] )*( xx[1] + xx[2] ));

        hessubi[2]  = 2; hessubj[2] = 2;
        hesval[2]   = yo / (( xx[1] + xx[2] )*( xx[1] + xx[2] ));
      }
    }
  }

  return ( 0 );
} /* nleval */

static void MSKAPI printlog(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printlog */

int main(void)
{
  MSKrescodee
    r;
  MSKboundkeye
    bkc[NUMCON],bkx[NUMVAR];
  int       
    ptrb[NUMVAR],ptre[NUMVAR],sub[NUMANZ];
  double
    blc[NUMCON],buc[NUMCON],
    c[NUMVAR],blx[NUMVAR],bux[NUMVAR],val[NUMANZ];
  MSKenv_t  env;
  MSKtask_t task;

  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  if ( r==MSK_RES_OK )
  {
    /* Make link so output is send to stdout. */
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printlog);
  }

  /* Initialize the environment. */   
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
  { 
    /* Make the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);
    if ( r==MSK_RES_OK )
      r = MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printlog);

    if ( r==MSK_RES_OK )
    {
      /* Define bounds for the constraints. */

      /* Constraint: 0 */
      bkc[0] = MSK_BK_FX;
      blc[0] = 1.0;
      buc[0] = 1.0;

      /* Define information for the variables. */

      /* Variable: x_0 */
      c[0]     = -1.0;

      ptrb[0]  = 0;  ptre[0] = 1;
      sub[0]   = 0;  val[0]  = 1.0;

      bkx[0]   = MSK_BK_LO;
      blx[0]   = 0.0;
      bux[0]   = MSK_INFINITY;

      /* Variable: x_1 */
      c[1]     = 0.0;

      ptrb[1]  = 1;  ptre[1] = 2;
      sub[1]   = 0;  val[1]  = 1.0;

      bkx[1]   = MSK_BK_LO;
      blx[1]   = 0.0;
      bux[1]   = MSK_INFINITY;

      /* Variable: x_2 */
      c[2]     = 0.0;

      ptrb[2]  = 2;  ptre[2] = 3;
      sub[2]   = 0;  val[2]  = 1.0;

      bkx[2]   = MSK_BK_LO;
      blx[2]   = 0.0;
      bux[2]   = MSK_INFINITY;

      r = MSK_inputdata(task,
                        NUMCON,NUMVAR,
                        NUMCON,NUMVAR,
                        c,0.0,
                        ptrb,
                        ptre,
                        sub,
                        val,
                        bkc,
                        blc,
                        buc,
                        bkx,
                        blx,
                        bux);

      if ( r==MSK_RES_OK )
      {
        /* Input nonlinear function information */

        r = MSK_putnlfunc(task,NULL,nlspar,nleval);
      }

      if ( r==MSK_RES_OK )
      {
        /* Perform optimization */
        r = MSK_optimize(task);
      }
    }

    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code: %d (0 means no error occured.)\n",r);

  return ( r );
} /* main */

