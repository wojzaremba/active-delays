/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      production.c

   Purpose:   To demonstrate how to solve a  linear
              optimization problem using the MOSEK API
              and and modify and re-optimize the problem.
 */
  
#include <stdio.h>

#include "mosek.h" /* Include the MOSEK definition file. */

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

#define  NUMVAR 3
#define  NUMCON 3
#define  NUMANZ 9
  
int main(int argc,char *argv[])
{
  MSKrescodee  r;
  MSKidxt      i,j;
  double       c[]    = {1.5, 2.5, 3.0};
  MSKlidxt     ptrb[] = {0, 3, 6};
  MSKlidxt     ptre[] = {3, 6, 9};

  MSKidxt      asub[] = { 0, 1, 2,
                          0, 1, 2,
                          0, 1, 2};
  
  double       aval[] = { 2.0, 3.0, 2.0,
                          4.0, 2.0, 3.0,
                          3.0, 3.0, 2.0};
 
  MSKboundkeye bkc[]  = {MSK_BK_UP, MSK_BK_UP, MSK_BK_UP    };
  double       blc[]  = {-MSK_INFINITY, -MSK_INFINITY, -MSK_INFINITY};
  double       buc[]  = {100000, 50000, 60000};
  
  MSKboundkeye bkx[]  = {MSK_BK_LO,     MSK_BK_LO,    MSK_BK_LO};
  double       blx[]  = {0.0,           0.0,          0.0,};
  double       bux[]  = {+MSK_INFINITY, +MSK_INFINITY,+MSK_INFINITY};
  
  double       xx[NUMVAR];
               
  MSKenv_t     env;
  MSKtask_t    task;
  MSKintt      numvar,numcon; 

  /* Create the mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

  /* Check if return code is ok. */
  if ( r==MSK_RES_OK )
  {
    /* Directs the env log stream to the 
       'printstr' function. */
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  }

  /* Initialize the environment. */
  r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
  {
    /* Create the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    /* Directs the log task stream to the 
       'printstr' function. */

    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

    /* Give MOSEK an estimate of the size of the input data. This is
       done to increase the efficiency of inputting data, however it is
       optional.*/

    if (r == MSK_RES_OK)
      r = MSK_putmaxnumvar(task,NUMVAR);

    if (r == MSK_RES_OK)
      r = MSK_putmaxnumcon(task,NUMCON);

    if (r == MSK_RES_OK)
      r = MSK_putmaxnumanz(task,NUMANZ);
          
    /* Append the constraints. */
    if (r == MSK_RES_OK)
      r = MSK_append(task,MSK_ACC_CON,NUMCON);

    /* Append the variables. */
    if (r == MSK_RES_OK)
      r = MSK_append(task,MSK_ACC_VAR,NUMVAR);

    /* Put C. */
    if (r == MSK_RES_OK)
      r = MSK_putcfix(task, 0.0);

    if (r == MSK_RES_OK)
      for(j=0; j<NUMVAR; ++j)
        r = MSK_putcj(task,j,c[j]);

    /* Put constraint bounds. */
    if (r == MSK_RES_OK)
      for(i=0; i<NUMCON; ++i)
        r = MSK_putbound(task,MSK_ACC_CON,i,bkc[i],blc[i],buc[i]);

    /* Put variable bounds. */
    if (r == MSK_RES_OK)
      for(j=0; j<NUMVAR; ++j)
        r = MSK_putbound(task,MSK_ACC_VAR,j,bkx[j],blx[j],bux[j]);
                    
    /* Put A. */
    if (r == MSK_RES_OK)
      if ( NUMCON>0 )
        for(j=0; j<NUMVAR; ++j)
          r = MSK_putavec(task,
                          MSK_ACC_VAR,
                          j,
                          ptre[j]-ptrb[j],
                          asub+ptrb[j],
                          aval+ptrb[j]);
           
    if (r == MSK_RES_OK)
      r = MSK_putobjsense(task,
                          MSK_OBJECTIVE_SENSE_MAXIMIZE);

    if (r == MSK_RES_OK)
      r = MSK_optimizetrm(task,NULL);

    if (r == MSK_RES_OK)
      MSK_getsolutionslice(task,
                           MSK_SOL_BAS,       /* Basic solution.       */
                           MSK_SOL_ITEM_XX,   /* Which part of solution.  */
                           0,                 /* Index of first variable. */
                           NUMVAR,            /* Index of last variable+1 */
                           xx);
    
/* Make a change to the A matrix */
    if (r == MSK_RES_OK)
      r = MSK_putaij(task, 0, 0, 3.0);
    if (r == MSK_RES_OK)
      r = MSK_optimizetrm(task,NULL);
    /* Append a new variable x_3 to the problem */
    if (r == MSK_RES_OK)
      r = MSK_append(task,MSK_ACC_VAR,1);
    
    /* Get index of new variable, this should be 3 */
    if (r == MSK_RES_OK)
      r = MSK_getnumvar(task,&numvar);
    
    /* Set bounds on new variable */
    if (r == MSK_RES_OK)
      r = MSK_putbound(task,
                       MSK_ACC_VAR,
                       numvar-1,
                       MSK_BK_LO,
                       0,
                       +MSK_INFINITY);
    
    /* Change objective */
    if (r == MSK_RES_OK)
      r = MSK_putcj(task,numvar-1,1.0);
    
    /* Put new values in the A matrix */
    if (r == MSK_RES_OK)
    {
      MSKidxt acolsub[] = {0,   2};
      double  acolval[] =  {4.0, 1.0};
      
       r = MSK_putavec(task,
                       MSK_ACC_VAR,
                       numvar-1, /* column index */
                       2, /* num nz in column*/
                       acolsub,
                       acolval);
    }
    
    /* Change optimizer to free simplex and reoptimize */
    if (r == MSK_RES_OK)
      r = MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_FREE_SIMPLEX);
    
    if (r == MSK_RES_OK)
      r = MSK_optimizetrm(task,NULL);
    /* Append a new constraint */
    if (r == MSK_RES_OK)
      r = MSK_append(task,MSK_ACC_CON,1);

    /* Get index of new constraint, this should be 4 */
    if (r == MSK_RES_OK)
      r = MSK_getnumcon(task,&numcon);
    
    /* Set bounds on new constraint */
    if (r == MSK_RES_OK)
      r = MSK_putbound(task,
                       MSK_ACC_CON,
                       numcon-1,
                       MSK_BK_UP,
                       -MSK_INFINITY,
                       30000);

    /* Put new values in the A matrix */
    if (r == MSK_RES_OK)
    {
      MSKidxt arowsub[] = {0,   1,   2,   3  };
      double arowval[] =  {1.0, 2.0, 1.0, 1.0};
      
      r = MSK_putavec(task,
                      MSK_ACC_CON,
                      numcon-1, /* row index */
                      4, /* num nz in row*/
                      arowsub,
                      arowval);
    }
    if (r == MSK_RES_OK)
      r = MSK_optimizetrm(task,NULL);
    
    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code: %d (0 means no error occured.)\n",r);

  return ( r );
} /* main */
 
