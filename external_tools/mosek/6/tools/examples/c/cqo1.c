/* 
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      cqo1.c

   Purpose:   To demonstrate how to solve a small conic quadratic
              optimization problem using the MOSEK API.
 */

#include <stdio.h>

#include "mosek.h" /* Include the MOSEK definition file. */

#define NUMCON 1   /* Number of constraints.             */
#define NUMVAR 6   /* Number of variables.               */
#define NUMANZ 4   /* Number of non-zeros in A.          */

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKrescodee  r;
  
  MSKboundkeye bkc[] = { MSK_BK_FX };
  double       blc[] = { 1.0 };
  double       buc[] = { 1.0 };
  
  MSKboundkeye bkx[] = {MSK_BK_LO,
                        MSK_BK_LO,
                        MSK_BK_LO,
                        MSK_BK_LO,
                        MSK_BK_FR,
                        MSK_BK_FR};
  double       blx[] = {0.0,
                        0.0,
                        0.0,
                        0.0,
                        -MSK_INFINITY,
                        -MSK_INFINITY};
  double       bux[] = {+MSK_INFINITY,
                        +MSK_INFINITY,
                        +MSK_INFINITY,
                        +MSK_INFINITY,
                        +MSK_INFINITY,
                        +MSK_INFINITY};
  
  double       c[]   = {0.0,
                        0.0,
                        0.0,
                        0.0,
                        1.0,
                        1.0};

  MSKintt     aptrb[] = {0, 1, 2, 3, 5, 5};
  MSKintt     aptre[] = {1, 2, 3, 4, 5, 5};
  double      aval[] = {1.0, 1.0, 1.0, 1.0};
  MSKidxt     asub[] = {0, 0, 0, 0};
   
  MSKidxt     i,j,csub[3];
  double      xx[NUMVAR];
  MSKenv_t    env;
  MSKtask_t   task;

  /* Create the mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  /* Check if return code is ok. */
  if ( r==MSK_RES_OK )
  {
    /* Directs the log stream to the 
       'printstr' function. */
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
  }

  /* Initialize the environment. */   
  if ( r==MSK_RES_OK ) 
    r = MSK_initenv(env);

  if ( r==MSK_RES_OK )
  {
    /* Create the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    if ( r==MSK_RES_OK )
    {
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

        /* Input column j of A */   
        if(r == MSK_RES_OK)
          r = MSK_putavec(task,
                          MSK_ACC_VAR,       /* Input columns of A.*/
                          j,                 /* Variable (column) index.*/
                          aptre[j]-aptrb[j], /* Number of non-zeros in column j.*/
                          asub+aptrb[j],     /* Pointer to row indexes of column j.*/
                          aval+aptrb[j]);    /* Pointer to Values of column j.*/
      
      }

      /* Set the bounds on constraints.
       for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
      for(i=0; i<NUMCON && r==MSK_RES_OK; ++i)
        r = MSK_putbound(task,
                        MSK_ACC_CON, /* Put bounds on constraints.*/
                        i,           /* Index of constraint.*/
                        bkc[i],      /* Bound key.*/
                        blc[i],      /* Numerical value of lower bound.*/
                        buc[i]);     /* Numerical value of upper bound.*/
                 
      if ( r==MSK_RES_OK )
      {
        /* Append the first cone. */
        csub[0] = 4;
        csub[1] = 0;
        csub[2] = 2;
        r = MSK_appendcone(task,
                           MSK_CT_QUAD,
                           0.0, /* For future use only, can be set to 0.0 */
                           3,
                           csub);
      }

      if ( r==MSK_RES_OK )
      {
        /* Append the second cone. */
        csub[0] = 5;
        csub[1] = 1;
        csub[2] = 3;

        r       =  MSK_appendcone(task,
                                  MSK_CT_QUAD,
                                  0.0,
                                  3,
                                  csub);
      }


      if ( r==MSK_RES_OK )
      {
        MSKrescodee trmcode;
        
        /* Run optimizer */
        r = MSK_optimizetrm(task,&trmcode);

        /* Print a summary containing information
           about the solution for debugging purposes*/
        MSK_solutionsummary (task,MSK_STREAM_LOG);
        
        if ( r==MSK_RES_OK )
        {
          MSKsolstae solsta;
          MSKidxt    j;
          
          MSK_getsolutionstatus (task,
                                 MSK_SOL_ITR,
                                 NULL,
                                 &solsta);
          
          switch(solsta)
          {
            case MSK_SOL_STA_OPTIMAL:   
            case MSK_SOL_STA_NEAR_OPTIMAL:
              MSK_getsolutionslice(task,
                                   MSK_SOL_ITR,    /* Request the interior solution. */
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
    }
    /* Delete the task and the associated data. */
    MSK_deletetask(&task);
  }
 
  /* Delete the environment and the associated data. */
  MSK_deleteenv(&env);

  return ( r );
} /* main */
