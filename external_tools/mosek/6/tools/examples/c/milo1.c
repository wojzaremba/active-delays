/* 
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      milo1.c

   Purpose:   To demonstrate how to solve a small mixed
              integer linear optimization problem using 
              the MOSEK API.
*/

#include <stdio.h>
 
#include "mosek.h" /* Include the MOSEK definition file. */

#define NUMCON 2   /* Number of constraints.             */
#define NUMVAR 2   /* Number of variables.               */
#define NUMANZ 4   /* Number of non-zeros in A.          */

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKrescodee  r;
  double       c[]   = {  1.0, 0.64 };
  MSKboundkeye bkc[] = { MSK_BK_UP,    MSK_BK_LO };
  double       blc[] = { -MSK_INFINITY,-4.0 };
  double       buc[] = { 250.0,        MSK_INFINITY };

  MSKboundkeye bkx[] = { MSK_BK_LO,    MSK_BK_LO };
  double       blx[] = { 0.0,          0.0 };
  double       bux[] = { MSK_INFINITY, MSK_INFINITY };
  

  MSKintt      aptrb[] = { 0, 2 };
  MSKintt      aptre[] = { 2, 4 };
  MSKidxt      asub[] = { 0,    1,   0,    1 };
  double       aval[] = { 50.0, 3.0, 31.0, -2.0 };
  MSKidxt      i,j;

  double       xx[NUMVAR];
  MSKenv_t     env;
  MSKtask_t    task;

  /* Create the mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);

  /* Initialize the environment. */   
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);

  /* Check if return code is ok. */
  if ( r==MSK_RES_OK )
  {
    /* Directs the log stream to the 'printstr' function. */
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);

    /* Create the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    if ( r==MSK_RES_OK )
      r = MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);
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
    
    /* Specify integer variables. */
    for(j=0; j<NUMVAR && r == MSK_RES_OK; ++j)
      r = MSK_putvartype(task,j,MSK_VAR_TYPE_INT);
    
    if ( r==MSK_RES_OK )
      r =  MSK_putobjsense(task,
                           MSK_OBJECTIVE_SENSE_MAXIMIZE);
    
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
          int j;
          
          MSK_getsolutionstatus (task,
                                 MSK_SOL_ITG,
                                 NULL,
                                 &solsta);
          
          switch(solsta)
          {
            case MSK_SOL_STA_INTEGER_OPTIMAL:   
            case MSK_SOL_STA_NEAR_INTEGER_OPTIMAL :
              MSK_getsolutionslice(task,
                                   MSK_SOL_ITG,    /* Request the integer */
                                   MSK_SOL_ITEM_XX,/* Which part of solution.     */
                                   0,              /* Index of first variable.    */
                                   NUMVAR,         /* Index of last variable+1.   */
                                   xx);
              
              printf("Optimal solution.\n");
              for(j=0; j<NUMVAR; ++j)
                printf("x[%d]: %e\n",j,xx[j]);
              
              break;
            case MSK_SOL_STA_PRIM_FEAS:
              /* A feasible but not necessarily optimal solution was located. */
              MSK_getsolutionslice(task,
                                   MSK_SOL_ITG,    /* Request the integer.*/
                                   MSK_SOL_ITEM_XX,/* Which part of solution.     */
                                   0,              /* Index of first variable.    */
                                   NUMVAR,         /* Index of last variable+1.   */
                                   xx);
              printf("Feasible solution.\n");
              for(j=0; j<NUMVAR; ++j)
                printf("x[%d]: %e\n",j,xx[j]);
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
    
  MSK_deletetask(&task);
  MSK_deleteenv(&env);

  printf("Return code: %d.\n",r);

  return ( r );
} /* main */
