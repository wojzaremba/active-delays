/* 
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      mskscopt.c


   Purpose:   Solves the problem

              minimize    x_1 - log(x_3)
              subject to  x_1^2 + x_2^2 <= 1
                          x_2 + 2*x_2 - x_3 = 0
                          x_3 >=0
 */

#include <string.h>

#include "scopt.h"

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int  argc,
         char *argv[])
{
  char        buffer[MSK_MAX_STR_LEN],fn[2048];
  int         i;
  MSKenv_t    env;
  MSKrescodee r;
  MSKtask_t   task;
  schand_t    sch;

  printf("Starting mskscopt\n"); 

  if ( argc<=1 )
  {
    printf("At least one argument is required.\n");
  }
  else
  {
    /* Make the mosek environment. */
    r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

    /* Check whether the return code is ok. */
    if ( r==MSK_RES_OK && argc>1 )
    {
      /* Directs the log stream to the user
         specified procedure 'printstr'. */
      MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
    }
  
    if ( r==MSK_RES_OK )
    { 
      /* Initialize the environment. */   
      r = MSK_initenv(env);
    }
  
    if ( r==MSK_RES_OK )
    {  
      /* Make the task. */
      r = MSK_makeemptytask(env,&task);

      if ( r==MSK_RES_OK )
        MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

      MSK_putintparam(task,MSK_IPAR_READ_DATA_FORMAT,MSK_DATA_FORMAT_EXTENSION);
  
      if ( r==MSK_RES_OK )
         r = MSK_scread(task,&sch,argv[1]);
    
      if ( r==MSK_RES_OK )
      {
        for(i=1; i<argc; ++i)
        {
          if ( 0==strcmp(argv[i],"-p") && i+1<argc )
          {
            MSK_putstrparam(task,MSK_SPAR_PARAM_READ_FILE_NAME,argv[i+1]);
            MSK_readparamfile(task);
            ++ i;
          }
          else if ( 0==strcmp(argv[i],"-min") )
            MSK_putobjsense(task,MSK_OBJECTIVE_SENSE_MINIMIZE);
          else if ( 0==strcmp(argv[i],"-max") )
            MSK_putobjsense(task,MSK_OBJECTIVE_SENSE_MAXIMIZE);
        }
        
        printf("Start optimizing\n");
  
        r = MSK_optimize(task);
  
        printf("Done optimizing\n");
  
        MSK_solutionsummary(task,MSK_STREAM_MSG);
  
        strcpy(fn,argv[1]);
        MSK_replacefileext(fn,"sol");
        MSK_writesolution(task,MSK_SOL_ITR,fn);
      }
    
      /* The nonlinear expressions are no longer needed. */
      MSK_scend(task,&sch);
  
      /* Delete the task. */
      MSK_deletetask(&task);
    }
  
    MSK_deleteenv(&env);
  
    printf("Return code: %d\n",r);
    if ( r!=MSK_RES_OK )
    {
      MSK_getcodedisc(r,buffer,NULL);
      printf("Description: %s\n",buffer);
    }
  }
} /* main */
