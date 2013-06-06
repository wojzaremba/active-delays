#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      callback.c

   Purpose:   To demonstrate how to use the progress 
              callback. 

              Compile and link the file with  MOSE, then 
              it is used as follows:

              callback psim 25fv47.mps
              callback dsim 25fv47.mps
              callback intpnt 25fv47.mps

              The first argument tells which optimizer to use
              i.e. psim is primal simplex, dsim is dual simplex
              and intpnt is interior-point. 
 */


#include "mosek.h"


/* Note: This function is declared using MSKAPI,
         so the correct calling convention is
         employed. */
static int MSKAPI usercallback(MSKtask_t        task,
                               MSKuserhandle_t  handle,
                               MSKcallbackcodee caller)
{
  int    iter;
  double pobj,dobj,opttime=0.0,stime=0.0,
         *maxtime=(double *) handle;

  switch ( caller )
  {
    case MSK_CALLBACK_BEGIN_INTPNT:
      printf("Starting interior-point optimizer\n");
      break;
    case MSK_CALLBACK_INTPNT:
      MSK_getintinf(task,
                    MSK_IINF_INTPNT_ITER,
                    &iter);
      MSK_getdouinf(task,
                    MSK_DINF_INTPNT_PRIMAL_OBJ,
                    &pobj);
      MSK_getdouinf(task,
                    MSK_DINF_INTPNT_DUAL_OBJ,
                    &dobj);
      MSK_getdouinf(task,
                    MSK_DINF_INTPNT_TIME,
                    &stime);
      MSK_getdouinf(task,
                    MSK_DINF_OPTIMIZER_TIME,
                    &opttime);

      printf("Iterations: %-3d  Time: %6.2f(%.2f)  ",
             iter,opttime,stime);
      printf("Primal obj.: %-18.6e  Dual obj.: %-18.6e\n",
              pobj,dobj);
      break;
    case MSK_CALLBACK_END_INTPNT:
      printf("Interior-point optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_PRIMAL_SIMPLEX:
      printf("Primal simplex optimizer started.\n");
      break;
    case MSK_CALLBACK_UPDATE_PRIMAL_SIMPLEX:
      MSK_getintinf(task,
                    MSK_IINF_SIM_PRIMAL_ITER,
                    &iter);
      MSK_getdouinf(task,
                    MSK_DINF_SIM_OBJ,
                    &pobj);
      MSK_getdouinf(task,
                    MSK_DINF_SIM_TIME,
                    &stime);
      MSK_getdouinf(task,
                    MSK_DINF_OPTIMIZER_TIME,
                    &opttime);

      printf("Iterations: %-3d  ",iter);
      printf("  Elapsed time: %6.2f(%.2f)\n",
             opttime,stime);
      printf("Obj.: %-18.6e\n",pobj);
      break;
    case MSK_CALLBACK_END_PRIMAL_SIMPLEX:
      printf("Primal simplex optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_DUAL_SIMPLEX:
      printf("Dual simplex optimizer started.\n");
      break;
    case MSK_CALLBACK_UPDATE_DUAL_SIMPLEX:
      MSK_getintinf(task,
                    MSK_IINF_SIM_DUAL_ITER,
                    &iter);
      MSK_getdouinf(task,
                    MSK_DINF_SIM_OBJ,
                    &pobj);
      MSK_getdouinf(task,
                    MSK_DINF_SIM_TIME,
                    &stime);
      MSK_getdouinf(task,
                    MSK_DINF_OPTIMIZER_TIME,
                    &opttime);

      printf("Iterations: %-3d  ",iter);
      printf("  Elapsed time: %6.2f(%.2f)\n",
             opttime,stime);
      printf("Obj.: %-18.6e\n",pobj);
      break;
    case MSK_CALLBACK_END_DUAL_SIMPLEX:
      printf("Dual simplex optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_BI:
      printf("Basis identification started.\n");
      break;
    case MSK_CALLBACK_END_BI:
      printf("Basis identification finished.\n");
      break;
  }

  if ( opttime>=maxtime[0] )
  {
    /* mosek is spending too much time.
       Terminate it. */
    return ( 1 );
  }
  
  return ( 0 );
} /* usercallback */

static void MSKAPI printtxt(void *info,
                            char *buffer)
{
  printf("%s",buffer); 
} /* printtxt */

int main(int argc, char *argv[])
{
  double    maxtime,
            *xx,*y;
  int       r,j,i,numcon,numvar;
  FILE      *f;
  MSKenv_t  env;
  MSKtask_t task;

  if ( argc<3 )
  {
    printf("Too few input arguments. mosek intpnt myfile.mps\n");
    exit(0);
  }

  /*
   * It is assumed that we are working in a
   * windows environment.
   */

  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

  /* Check the return code. */
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);

  /* Check the return code. */
  if ( r==MSK_RES_OK )
  {
    /* Create an (empty) optimization task. */
    r = MSK_makeemptytask(env,&task);
    
    if ( r==MSK_RES_OK )
    {
      MSK_linkfunctotaskstream(task,MSK_STREAM_MSG,NULL, printtxt);
      MSK_linkfunctotaskstream(task,MSK_STREAM_ERR,NULL, printtxt);
    }

    /* Specifies that data should be read from the
       file argv[2].
     */

    if ( r==MSK_RES_OK )
      r = MSK_readdata(task,argv[2]);

    if ( r==MSK_RES_OK )
    {
      if ( 0==strcmp(argv[1],"psim") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_PRIMAL_SIMPLEX);
      else  if ( 0==strcmp(argv[1],"dsim") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_DUAL_SIMPLEX);
      else  if ( 0==strcmp(argv[1],"intpnt") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_INTPNT);
        

      /* Tell mosek about the call-back function. */
      maxtime = 3600;
      MSK_putcallbackfunc(task,
                          usercallback,
                          (void *) &maxtime);

      /* Turn all MOSEK logging off. */  
      MSK_putintparam(task,
                      MSK_IPAR_LOG,
                      0);

      r = MSK_optimize(task);

      MSK_solutionsummary(task,MSK_STREAM_MSG);
    }


    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code - %d\n",r);

  return ( r );
} /* main */
