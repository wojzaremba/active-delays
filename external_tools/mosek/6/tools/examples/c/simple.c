/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    simple.c

  Purpose: To demonstrate a very simple example using MOSEK by
           reading a problem file, solving the problem and
           writing the solution to a file.
*/

#include "mosek.h"

int main (int argc, char * argv[])
{
  MSKtask_t   task = NULL;
  MSKenv_t    env  = NULL;
  MSKrescodee res  = MSK_RES_OK;

  if (argc <= 1)
  {
    printf ("Missing argument. The syntax is:\n");
    printf (" simple inputfile [ solutionfile ]\n");
  }
  else
  {
    /* Create the mosek environment. 
       The `NULL' arguments here, are used to specify customized 
       memory allocators and a memory debug file. These can
       safely be ignored for now. */
    
    res = MSK_makeenv(&env, NULL, NULL, NULL, NULL);
      
    /* Initialize the environment */
    if ( res==MSK_RES_OK )
      MSK_initenv (env);

    /* Create a task object linked to the environment env.
       Initially we create it with 0 variables and 0 columns, 
       since we do not know the size of the problem. */ 
    if ( res==MSK_RES_OK )
      res = MSK_maketask (env, 0,0, &task);
      
    /* We assume that a problem file was given as the first command
       line argument (received in `argv'). */
    if ( res==MSK_RES_OK )   
      res = MSK_readdata (task, argv[1]);

    /* Solve the problem */
    if ( res==MSK_RES_OK )
      MSK_optimize(task);

    /* Print a summary of the solution. */
    MSK_solutionsummary(task, MSK_STREAM_MSG);
        
    /* If an output file was specified, write a solution */
    if ( res==MSK_RES_OK && argc>2 )
    {
      /* We define the output format to be OPF, and tell MOSEK to
         leave out parameters and problem data from the output file. */
      MSK_putintparam (task,MSK_IPAR_WRITE_DATA_FORMAT,    MSK_DATA_FORMAT_OP);
      MSK_putintparam (task,MSK_IPAR_OPF_WRITE_SOLUTIONS,  MSK_ON);
      MSK_putintparam (task,MSK_IPAR_OPF_WRITE_HINTS,      MSK_OFF);
      MSK_putintparam (task,MSK_IPAR_OPF_WRITE_PARAMETERS, MSK_OFF);
      MSK_putintparam (task,MSK_IPAR_OPF_WRITE_PROBLEM,    MSK_OFF);
      MSK_writedata(task,argv[2]);
    }
  
    MSK_deletetask(&task);
    MSK_deleteenv(&env);
  }
  return res;
}
