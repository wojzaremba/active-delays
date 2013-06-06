/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      concurrent1.c

   Purpose:   To demonstrate how to solve a problem 
              with the concurrent optimizer. 
 */

#include <stdio.h>

#include "mosek.h" 

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKenv_t  env;
  MSKtask_t task;
  MSKintt r = MSK_RES_OK;
  
  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); 

  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);

  /* Initialize the environment. */   
  r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
    r = MSK_maketask(env,0,0,&task);
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

  if (r == MSK_RES_OK)
    r = MSK_readdata(task,argv[1]);

  MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_CONCURRENT);
  MSK_putintparam(task,MSK_IPAR_CONCURRENT_NUM_OPTIMIZERS,2);

  if (r == MSK_RES_OK)
    r = MSK_optimize(task);

  MSK_solutionsummary(task,MSK_STREAM_LOG);

   
  MSK_deletetask(&task);
  MSK_deleteenv(&env);

  printf("Return code: %d (0 means no error occured.)\n",r);

  return ( r );
} /* main */

 
