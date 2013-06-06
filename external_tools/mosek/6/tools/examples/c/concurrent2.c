/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      concurrent2.c

  Purpose:   To demonstrate a more flexible interface for concurrent optimization. 
*/


#include "mosek.h"

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("simplex: %s",str);
} /* printstr */

static void MSKAPI printstr2(void *handle,
                             char str[])
{
  printf("intrpnt: %s",str);
} /* printstr */

#define NUMTASKS 1

int main(int argc,char **argv)
{
  MSKintt   r=MSK_RES_OK,i;
  MSKenv_t  env;
  MSKtask_t task;
  MSKtask_t task_list[NUMTASKS];  
    
  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); 
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr); 

  /* Initialize the environment. */
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);

  /* Create a task for each concurrent optimization.
     The 'task' is the master task that will hold the problem data.
  */ 

  if ( r==MSK_RES_OK )
    r = MSK_maketask(env,0,0,&task);

  if (r == MSK_RES_OK)
    r = MSK_maketask(env,0,0,&task_list[0]); 
     
  if (r == MSK_RES_OK)
    r = MSK_readdata(task,argv[1]);

  /* Assign different parameter values to each task. 
     In this case different optimizers. */
  
  if (r == MSK_RES_OK)
    r = MSK_putintparam(task,
                        MSK_IPAR_OPTIMIZER,
                        MSK_OPTIMIZER_PRIMAL_SIMPLEX);
  
  if (r == MSK_RES_OK)
    r = MSK_putintparam(task_list[0],
                        MSK_IPAR_OPTIMIZER,
                        MSK_OPTIMIZER_INTPNT);

  
  /* Assign call-back functions to each task */
  
  if (r == MSK_RES_OK)
    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);
 
  if (r == MSK_RES_OK)
    MSK_linkfunctotaskstream(task_list[0],
                             MSK_STREAM_LOG,
                             NULL,
                             printstr2);
  
  if (r == MSK_RES_OK)
    r = MSK_linkfiletotaskstream(task,
                                 MSK_STREAM_LOG,
                                 "simplex.log",
                                 0);
  
  if (r == MSK_RES_OK)
    r = MSK_linkfiletotaskstream(task_list[0],
                                 MSK_STREAM_LOG,
                                 "intpnt.log",
                                 0);
  

  /* Optimize task and task_list[0] in parallel.
     The problem data i.e. C, A, etc. 
     is copied from task to task_list[0].
   */
   
  if (r == MSK_RES_OK)
    r = MSK_optimizeconcurrent (
                                task, 
                                task_list, 
                                NUMTASKS);

  printf ("Return Code = %d\n",r);
  
  MSK_solutionsummary(task,
                      MSK_STREAM_LOG);
  return r;
}
