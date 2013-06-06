/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      lo2.c

  Purpose:   To demonstrate how to solve a small linear
             optimization problem using the MOSEK C API.
*/

#include <stdio.h>
#include "mosek.h" 

/* This function prints log output from MOSEK to the terminal. */
static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

#define NUMVAR 4
#define NUMCON 3
#define NUMANZ 9

int main(int argc,char *argv[])
{
  MSKrescodee  r;
  MSKidxt i,j;
  double       c[]    = {3.0, 1.0, 5.0, 1.0};

  /* Below is the sparse representation of the A
     matrix stored by row. */
  MSKlidxt     aptrb[] = {0, 3, 7};
  MSKlidxt     aptre[] = {3, 7, 9};
  MSKidxt      asub[] = { 0,1,2,
                          0,1,2,3,
                          1,3};    
  double       aval[] = { 3.0, 1.0, 2.0,
                          2.0, 1.0, 3.0, 1.0,
                          2.0, 3.0};  
  /* Bounds on constraints. */
  MSKboundkeye bkc[]  = {MSK_BK_FX, MSK_BK_LO,     MSK_BK_UP    };
  double       blc[]  = {30.0,      15.0,          -MSK_INFINITY};
  double       buc[]  = {30.0,      +MSK_INFINITY, 25.0         };
  /* Bounds on variables. */
  MSKboundkeye bkx[]  = {MSK_BK_LO,     MSK_BK_RA, MSK_BK_LO,     MSK_BK_LO     };
  double       blx[]  = {0.0,           0.0,       0.0,           0.0           };
  double       bux[]  = {+MSK_INFINITY, 10.0,      +MSK_INFINITY, +MSK_INFINITY };

  double xx[NUMVAR];               
  MSKenv_t     env  = NULL;
  MSKtask_t    task = NULL; 
  
  /* Create the mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  
  /* Directs the env log stream to the 'printstr' function. */
  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  
  /* Initialize the environment. */
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);
  
  if ( r==MSK_RES_OK )
  {
    /* Create the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    /* Directs the log task stream to the 'printstr' function. */
    if ( r==MSK_RES_OK )
      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

    /* Give MOSEK an estimate of the size of the input data. 
     This is done to increase the speed of inputting data. 
     However, it is optional. */
    if (r == MSK_RES_OK)
      r = MSK_putmaxnumvar(task,NUMVAR);
  
    if (r == MSK_RES_OK)
      r = MSK_putmaxnumcon(task,NUMCON);
    
    if (r == MSK_RES_OK)
      r = MSK_putmaxnumanz(task,NUMANZ);

    /* Append 'NUMCON' empty constraints.
     The constraints will initially have no bounds. */
    if ( r == MSK_RES_OK )
      r = MSK_append(task,MSK_ACC_CON,NUMCON);

    /* Append 'NUMVAR' variables.
     The variables will initially be fixed at zero (x=0). */
    if ( r == MSK_RES_OK )
      r = MSK_append(task,MSK_ACC_VAR,NUMVAR);

    /* Optionally add a constant term to the objective. */
    if ( r ==MSK_RES_OK )
      r = MSK_putcfix(task,0.0);
    for(j=0; j<NUMVAR && r == MSK_RES_OK; ++j)
    {
      /* Set the linear term c_j in the objective.*/  
      if(r == MSK_RES_OK)
        r = MSK_putcj(task,j,c[j]);

      /* Set the bounds on variable j.
       blx[j] <= x_j <= bux[j] */
      if(r == MSK_RES_OK)
        r = MSK_putbound(task,
                         MSK_ACC_VAR, /* Put bounds on variables.*/
                         j,           /* Index of variable.*/
                         bkx[j],      /* Bound key.*/
                         blx[j],      /* Numerical value of lower bound.*/
                         bux[j]);     /* Numerical value of upper bound.*/
    }

    /* Set the bounds on constraints.
       for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
    for(i=0; i<NUMCON && r==MSK_RES_OK; ++i)
    {  
      r = MSK_putbound(task,
                       MSK_ACC_CON, /* Put bounds on constraints.*/
                       i,           /* Index of constraint.*/
                       bkc[i],      /* Bound key.*/
                       blc[i],      /* Numerical value of lower bound.*/
                       buc[i]);     /* Numerical value of upper bound.*/
      /* Input column j of A */   
      if(r == MSK_RES_OK)
        r = MSK_putavec(task,
                        MSK_ACC_CON,       /* Input row of A.*/
                        i,                 /* Row index.*/
                        aptre[i]-aptrb[i], /* Number of non-zeros in row i.*/
                        asub+aptrb[i],     /* Pointer to column indexes of row i.*/
                        aval+aptrb[i]);    /* Pointer to Values of row i.*/      
    }

    /* Maximize objective function. */
    if (r == MSK_RES_OK)
      r = MSK_putobjsense(task,
                          MSK_OBJECTIVE_SENSE_MAXIMIZE);

    if ( r==MSK_RES_OK )
    {
      MSKrescodee trmcode;
    
      /* Run optimizer */
      r = MSK_optimizetrm(task,&trmcode);

      /* Print a summary containing information
       about the solution for debugging purposes. */
      MSK_solutionsummary (task,MSK_STREAM_LOG);
     
      if ( r==MSK_RES_OK )
      {
        MSKsolstae solsta;
        int j;
        MSK_getsolutionstatus (task,
                               MSK_SOL_BAS,
                               NULL,
                               &solsta);
        switch(solsta)
        {
          case MSK_SOL_STA_OPTIMAL:   
          case MSK_SOL_STA_NEAR_OPTIMAL:
            MSK_getsolutionslice(task,
                                 MSK_SOL_BAS,    /* Request the basic solution. */
                                 MSK_SOL_ITEM_XX,/* Which part of solution.     */
                                 0,              /* Index of first variable.    */
                                 NUMVAR,         /* Index of last variable+1.   */
                                 xx);
      
            printf("Optimal primal solution\n");
            for(j=0; j<NUMVAR; ++j)
              printf("x[%d]: %e\n",j,xx[j]);
          
            break;
          case MSK_SOL_STA_DUAL_INFEAS_CER:
          case MSK_SOL_STA_PRIM_INFEAS_CER:
          case MSK_SOL_STA_NEAR_DUAL_INFEAS_CER:
          case MSK_SOL_STA_NEAR_PRIM_INFEAS_CER:  
            printf("Primal or dual infeasibility certificate found.\n");
            break;
            
          case MSK_SOL_STA_UNKNOWN:
            printf("The status of the solution could not be determined.\n");
            break;
          default:
            printf("Other solution status.");
            break;
        }
      }
      else
      {
        printf("Error while optimizing.\n");
      }
    }
    
    if (r != MSK_RES_OK)
    {
      /* In case of an error print error code and description. */      
      char symname[MSK_MAX_STR_LEN];
      char desc[MSK_MAX_STR_LEN];
      
      printf("An error occurred while optimizing.\n");     
      MSK_getcodedesc (r,
                       symname,
                       desc);
      printf("Error %s - '%s'\n",symname,desc);
    }
    
    MSK_deletetask(&task);
    
    MSK_deleteenv(&env);
  }
    
  return r;
}


