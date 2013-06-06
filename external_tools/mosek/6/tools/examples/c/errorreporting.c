/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File: errorreporting.c

   Purpose:   To demonstrate how the error reporting can be customized.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "mosek.h"

MSKrescodee MSKAPI handleresponse(MSKuserhandle_t handle,
                                  MSKrescodee     r,
                                  MSKCONST char   msg[])
/* A custom response handler. */                            
{
  if ( r==MSK_RES_OK )
  { 
    /* Do nothing */
  }
  else if ( r<MSK_FIRST_ERR_CODE )
  { 
    printf("MOSEK reports warning number %d: %s\n",r,msg);
  }
  else
  {
    printf("MOSEK reports error number %d: %s\n",r,msg);
  }  

  return ( MSK_RES_OK );
  
} /* handlerespone */


int main(int argc, char *argv[])
{
  MSKenv_t    env;
  MSKrescodee r; 
  MSKtask_t   task;
  
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);
    
  if ( r==MSK_RES_OK ) 
  { 

    r = MSK_makeemptytask(env,&task);
    
    if ( r==MSK_RES_OK ) 
    {
      /*
       * Input a custom warning and error handler function.
       */
       
      MSK_putresponsefunc(task,handleresponse,NULL); 

      /* User defined code goes here */
      /* This will provoke an error */

      if (r == MSK_RES_OK)
        r = MSK_putaij(task,10,10,1.0);
      
    }  
    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code - %d\n",r);

  if (r == MSK_RES_ERR_INDEX_IS_TOO_LARGE)
    return ( MSK_RES_OK);
  else
    return (-1);
} /* main */
