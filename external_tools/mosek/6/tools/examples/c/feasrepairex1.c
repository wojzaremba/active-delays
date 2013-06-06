     
/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      feasrepairex1.c

  Purpose:   To demonstrate how to use the MSK_relaxprimal function to
             locate the cause of an infeasibility. 

  Syntax: On command line
          feasrepairex1 feasrepair.lp
          feasrepair.lp is located in mosek\<version>\tools\examples.
*/


#include <math.h>
#include <stdio.h>

#include "mosek.h"


static void MSKAPI printstr(void *handle,
                            char str[])
{
  fputs(str,stdout);
} /* printstr */

int main(int argc, char** argv)
{
  
  double      wlc[4] = {1.0,1.0,1.0,1.0};
  double      wuc[4] = {1.0,1.0,1.0,1.0};
  double      wlx[2] = {1.0,1.0};
  double      wux[2] = {1.0,1.0};
  double      sum_violation;
  MSKenv_t    env;
  MSKintt     i;  
  MSKrescodee r = MSK_RES_OK;
  MSKtask_t   task  = NULL, task_relaxprimal = NULL;
  char        buf[80];
  char        buffer[MSK_MAX_STR_LEN],symnam[MSK_MAX_STR_LEN];

  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  
  if (r == MSK_RES_OK)
    MSK_initenv(env);
  
  if ( r == MSK_RES_OK )  
    r = MSK_makeemptytask(env,&task);

  if ( r==MSK_RES_OK )
    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);
  
  /* Read file from current dir */
  if ( r == MSK_RES_OK )
    r = MSK_readdata(task,argv[1]);

  /* Set type of relaxation */ 

  if (r == MSK_RES_OK)
    r = MSK_putintparam(task,MSK_IPAR_FEASREPAIR_OPTIMIZE,MSK_FEASREPAIR_OPTIMIZE_PENALTY);

  /* Call relaxprimal, minimizing sum of violations */
  
  if (r == MSK_RES_OK) 
    r = MSK_relaxprimal(task,
                        &task_relaxprimal,
                        wlc,
                        wuc,
                        wlx,
                        wux);

  if ( r==MSK_RES_OK )
    MSK_linkfunctotaskstream(task_relaxprimal,MSK_STREAM_LOG,NULL,printstr);

  if (r == MSK_RES_OK)
    r = MSK_getprimalobj(task_relaxprimal,MSK_SOL_BAS,&sum_violation);

  if (r == MSK_RES_OK)
  {
    printf ("Minimized sum of violations = %e\n",sum_violation);
    
    /* modified bound returned in wlc,wuc,wlx,wux */

    for (i=0;i<4;++i)
    {
      if (wlc[i] == -MSK_INFINITY)
        printf("lbc[%d] = -inf, ",i);
      else
        printf("lbc[%d] = %e, ",i,wlc[i]);
      
      if (wuc[i] == MSK_INFINITY)
        printf("ubc[%d] = inf\n",i);
      else
        printf("ubc[%d] = %e\n",i,wuc[i]);
    }

    for (i=0;i<2;++i)
    {
      if (wlx[i] == -MSK_INFINITY)
        printf("lbx[%d] = -inf, ",i);
      else
        printf("lbx[%d] = %e, ",i,wlx[i]);
      
      if (wux[i] == MSK_INFINITY)
        printf("ubx[%d] = inf\n",i);
      else
        printf("ubx[%d] = %e\n",i,wux[i]);
    }

  }

  printf("Return code: %d\n",r);
  if ( r!=MSK_RES_OK )
  { 
    MSK_getcodedisc(r,symnam,buffer);
    printf("Description: %s [%s]\n",symnam,buffer);
  }

  return (r);
}
