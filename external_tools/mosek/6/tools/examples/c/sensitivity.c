/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      sensitivity.c

  Purpose:   To demonstrate how to perform sensitivity
             analysis from the API on a small problem:

  minimize

  obj: +1 x11 + 2 x12 + 5 x23 + 2 x24 + 1 x31 + 2 x33 + 1 x34
  st
  c1:   +  x11 +   x12                                           <= 400
  c2:                  +   x23 +   x24                           <= 1200
  c3:                                  +   x31 +   x33 +   x34   <= 1000
  c4:   +  x11                         +   x31                   = 800
  c5:          +   x12                                           = 100
  c6:                  +   x23                 +   x33           = 500
  c7:                          +   x24                 +   x34   = 500

  The example uses basis type sensitivity analysis.
*/ 

#include <stdio.h>

#include "mosek.h" /* Include the MOSEK definition file. */

#define NUMCON 7   /* Number of constraints.             */
#define NUMVAR 7   /* Number of variables.               */
#define NUMANZ 14  /* Number of non-zeros in A.           */

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKrescodee  r;
  MSKidxt      i,j;
  MSKboundkeye bkc[] = {MSK_BK_UP, MSK_BK_UP, MSK_BK_UP, MSK_BK_FX,
                        MSK_BK_FX, MSK_BK_FX,MSK_BK_FX};
  MSKboundkeye bkx[] = {MSK_BK_LO, MSK_BK_LO, MSK_BK_LO,
                        MSK_BK_LO, MSK_BK_LO, MSK_BK_LO,MSK_BK_LO};
  MSKlidxt     ptrb[]= {0,2,4,6,8,10,12};
  MSKlidxt     ptre[]= {2,4,6,8,10,12,14};
  MSKidxt      sub[] = {0,3,0,4,1,5,1,6,2,3,2,5,2,6};
  MSKrealt     blc[] = {-MSK_INFINITY,-MSK_INFINITY,-MSK_INFINITY,800,100,500,500};
  MSKrealt     buc[] = {400,          1200,         1000,         800,100,500,500};
  MSKrealt     c[]   = {1.0,2.0,5.0,2.0,1.0,2.0,1.0};
  MSKrealt     blx[] = {0.0,0.0,0.0,0.0,0.0,0.0,0.0};
  MSKrealt     bux[] = {MSK_INFINITY,MSK_INFINITY,MSK_INFINITY,MSK_INFINITY,
                        MSK_INFINITY,MSK_INFINITY,MSK_INFINITY};
  MSKrealt     val[] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};
  
  MSKenv_t     env;
  MSKtask_t    task;

  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

  /* Check if return code is ok. */
  if ( r==MSK_RES_OK )
  {
    /* Directs the env log stream to the user
       specified procedure 'printstr'. */
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  }

  /* Initialize the environment. */
  r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
  {
    /* Send a message to the MOSEK Message stream. */
    MSK_echoenv(env,
                MSK_STREAM_MSG,
                "Making the MOSEK optimization task\n");

    /* Make the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    if ( r==MSK_RES_OK )
    {
      /* Directs the log task stream to the user
         specified procedure 'printstr'. */

      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

      MSK_echotask(task,
                   MSK_STREAM_MSG,
                   "Defining the problem data.\n");

      /* Append the constraints. */
      if ( r==MSK_RES_OK )
        r = MSK_append(task,MSK_ACC_CON,NUMCON);

      /* Append the variables. */
      if ( r==MSK_RES_OK )
        r = MSK_append(task,MSK_ACC_VAR,NUMVAR);

      /* Put C. */
      if ( r==MSK_RES_OK )
        r = MSK_putcfix(task,0.0);

      for(j=0; j<NUMVAR && r==MSK_RES_OK; ++j)
      {
        r = MSK_putcj(task,j,c[j]);
        printf("%f\n",c[j]);
      }
      
      /* Put constraint bounds. */
      for(i=0; i<NUMCON && r==MSK_RES_OK; ++i)
        r = MSK_putbound(task,MSK_ACC_CON,i,bkc[i],blc[i],buc[i]);

      /* Put variable bounds. */
      for(j=0; j<NUMVAR && r==MSK_RES_OK; ++j)
        r = MSK_putbound(task,MSK_ACC_VAR,
                         j,bkx[j],blx[j],bux[j]);

      /* Put A. */
      if ( NUMCON>0 )
      {
        for(j=0; j<NUMVAR && r==MSK_RES_OK; ++j)
          r = MSK_putavec(task,MSK_ACC_VAR,
                          j,ptre[j]-ptrb[j],sub+ptrb[j],val+ptrb[j]);
      }

      if ( r==MSK_RES_OK )
      {
        MSK_putobjsense(task,MSK_OBJECTIVE_SENSE_MINIMIZE);

        MSK_echotask(task,
                     MSK_STREAM_MSG,
                     "Start optimizing\n");

        r = MSK_optimize(task);

      }
    }
    
    if (r == MSK_RES_OK)
    {
      /* Analyze upper bound on c1 and the equality constraint on c4 */ 
      MSKidxt subi[]  = {0,3};         
      MSKmarke marki[] = {MSK_MARK_UP,MSK_MARK_UP};

      /* Analyze lower bound on the variables x12 and x31 */ 
      MSKidxt subj[]  = {1,4};
      MSKmarke markj[] = {MSK_MARK_LO,MSK_MARK_LO};
       
      MSKrealt leftpricei[2];   
      MSKrealt rightpricei[2];
      MSKrealt leftrangei[2];
      MSKrealt rightrangei[2];
      MSKrealt leftpricej[2];   
      MSKrealt rightpricej[2];
      MSKrealt leftrangej[2]; 
      MSKrealt rightrangej[2];
        
      r = MSK_primalsensitivity( task,
                                 2,  
                                 subi, 
                                 marki,  
                                 2,
                                 subj,
                                 markj, 
                                 leftpricei,   
                                 rightpricei,
                                 leftrangei, 
                                 rightrangei,
                                 leftpricej,   
                                 rightpricej,
                                 leftrangej, 
                                 rightrangej);

      printf("Results from sensitivity analysis on bounds:\n");

      printf("For constraints:\n");
      for (i=0;i<2;++i)
        printf("leftprice = %e, rightprice = %e,leftrange = %e, rightrange =%e\n",
               leftpricei[i], rightpricei[i], leftrangei[i], rightrangei[i]);

      printf("For variables:\n");
      for (i=0;i<2;++i)
        printf("leftprice = %e, rightprice = %e,leftrange = %e, rightrange =%e\n",
               leftpricej[i], rightpricej[i], leftrangej[i], rightrangej[i]);   
    }

    if (r == MSK_RES_OK)
    {
  
      MSKidxt subj[]  = {2,5};
       
      MSKrealt leftprice[2];   
      MSKrealt rightprice[2];
      MSKrealt leftrange[2];
      MSKrealt rightrange[2];
      
      r = MSK_dualsensitivity(task,
                              2,
                              subj,
                              leftprice,
                              rightprice,
                              leftrange,
                              rightrange
                              );

      printf("Results from sensitivity analysis on objective coefficients:\n");
    
      for (i=0;i<2;++i)
        printf("leftprice = %e, rightprice = %e,leftrange = %e, rightrange =%e\n",
               leftprice[i], rightprice[i], leftrange[i], rightrange[i]);               
    }   
    
    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code: %d (0 means no error occured.)\n",r);
  
  return ( r );
} /* main */
