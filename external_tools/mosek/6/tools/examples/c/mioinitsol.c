/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      mioinitsol.c

   Purpose:   To demonstrate how to solve a MIP with a start guess.
 
 */

#include "mosek.h"
#include <stdio.h>

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

#define NUMVAR     4
#define NUMCON     1
#define NUMINTVAR  3


int main(int argc,char *argv[])
{
  char         buffer[512];

  MSKrescodee  r;
  
  MSKenv_t     env;
  MSKtask_t    task;

  double       c[] = { 7.0, 10.0, 1.0, 5.0 };
  
  MSKboundkeye bkc[] = {MSK_BK_UP};
  double       blc[] = {-MSK_INFINITY};
  double       buc[] = {2.5};
  
  MSKboundkeye bkx[] = {MSK_BK_LO, MSK_BK_LO, MSK_BK_LO,MSK_BK_LO};
  double       blx[] = {0.0,       0.0,       0.0,      0.0      };
  double       bux[] = {MSK_INFINITY,MSK_INFINITY,MSK_INFINITY,MSK_INFINITY};
      
  MSKlidxt     ptrb[] = {0,1,2,3};
  MSKlidxt     ptre[] = {1,2,3,4};
  double       aval[] = {1.0, 1.0, 1.0, 1.0};
  MSKidxt      asub[] = {0,   0,   0,   0  };
  MSKidxt      intsub[] = {0,1,2};
  MSKidxt      j;
   
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); 
  
  if ( r==MSK_RES_OK )
  { 
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  }

  r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
    r = MSK_maketask(env,0,0,&task);
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

  if (r == MSK_RES_OK)
    r = MSK_inputdata(task,
                      NUMCON,NUMVAR,
                      NUMCON,NUMVAR,
                      c,
                      0.0,
                      ptrb,
                      ptre,
                      asub,
                      aval,
                      bkc,
                      blc,
                      buc,
                      bkx,
                      blx,
                      bux);

  if (r == MSK_RES_OK)
    MSK_putobjsense(task,MSK_OBJECTIVE_SENSE_MAXIMIZE);
          
  for(j=0; j<NUMINTVAR && r == MSK_RES_OK; ++j)
    r = MSK_putvartype(task,intsub[j],MSK_VAR_TYPE_INT);

        
  /* Construct an initial feasible solution from the
     values of the integer variables specified */
  
  if (r == MSK_RES_OK)
    r = MSK_putintparam(task,MSK_IPAR_MIO_CONSTRUCT_SOL,MSK_ON);

  /* Set status of all variables to unknown */
  if (r == MSK_RES_OK)
    r = MSK_makesolutionstatusunknown(task, MSK_SOL_ITG);

  /* Assign values 1,1,0 to integer variables */
   
  if (r == MSK_RES_OK)
    r = MSK_putsolutioni (
                          task,
                          MSK_ACC_VAR,
                          0,
                          MSK_SOL_ITG, 
                          MSK_SK_SUPBAS, 
                          0.0,
                          0.0,
                          0.0,
                          0.0);

  if (r == MSK_RES_OK)
    r = MSK_putsolutioni (
                          task,
                          MSK_ACC_VAR,
                          1,
                          MSK_SOL_ITG, 
                          MSK_SK_SUPBAS, 
                          2.0,
                          0.0,
                          0.0,
                          0.0); 

  if (r == MSK_RES_OK)
    r = MSK_putsolutioni (
                          task,
                          MSK_ACC_VAR,
                          2,
                          MSK_SOL_ITG, 
                          MSK_SK_SUPBAS, 
                          0.0,
                          0.0,
                          0.0,
                          0.0);
    
  /* solve */
    
  if (r == MSK_RES_OK)
    r = MSK_optimize(task); 
  
  /* Did mosek construct a feasible initial solution ? */
 
  {
    int isok;
     
    if (r == MSK_RES_OK)
      r = MSK_getintinf(task,MSK_IINF_MIO_CONSTRUCT_SOLUTION,&isok);

    if ( isok>0 && r == MSK_RES_OK)
      printf("MOSEK constructed a feasible initial soulution.\n");    
  }
  /* Delete the task. */
  
  MSK_deletetask(&task);
  
  MSK_deleteenv(&env);
  
  printf("Return code: %d\n",r);
  if ( r!=MSK_RES_OK )
  {
    MSK_getcodedisc(r,buffer,NULL);
    printf("Description: %s\n",buffer);
  }

  return (r);
}
 

