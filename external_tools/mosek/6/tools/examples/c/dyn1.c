/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:    dyn1.c

   Purpose: Demonstrates how to dynamically add columns and 
            solve a small linear optimization problem using 
            the MOSEK API.
 */

#include <stdio.h>

#include "mosek.h" /* Include the MOSEK definition file. */

#define NUMCON 3   /* Number of constraints.             */
#define NUMVAR 4   /* Number of variables.               */
#define NUMANZ 9   /* Number of numzeros in A.           */

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKrescodee
    r;
  MSKboundkeye
    bkc[NUMCON],bkx[NUMVAR];
  int 
    j,i,
    ptrb[NUMVAR],ptre[NUMVAR],sub[NUMANZ];
  double
    blc[NUMCON],buc[NUMCON],
    c[NUMVAR],blx[NUMVAR],bux[NUMVAR],val[NUMANZ],
    xx[NUMVAR];
  MSKenv_t  env;
  MSKtask_t task;

  /* Make mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); 

  /* Check is return code is ok. */
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
                "\nMaking the MOSEK optimization task\n");

    /* Make the optimization task. */
    r = MSK_maketask(env,NUMCON,NUMVAR,&task);

    if ( r==MSK_RES_OK )
    {
      /* Directs the log task stream to the user
         specified procedure 'printstr'. */

      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

      MSK_echotask(task,
                   MSK_STREAM_MSG,
                   "\nDefining the problem data.\n");

      /* Define bounds for the constraints. */

      /* Constraint: 0 */
      bkc[0] = MSK_BK_FX;  /* Type of bound. */
      blc[0] = 30.0;       /* Lower bound on the
                              constraint. */
      buc[0] = 30.0;       /* Upper bound on the
                              constraint. */

      /* Constraint: 1 */
      bkc[1] = MSK_BK_LO;
      blc[1] = 15.0;
      buc[1] = MSK_INFINITY;

      /* Constraint: 2 */
      bkc[2] = MSK_BK_UP;
      blc[2] = -MSK_INFINITY;
      buc[2] = 25.0;

      /* Define information for the variables. */

      /* Variable: x0 */
      c[0]    = 3.0;              /* The objective function. */

      ptrb[0] = 0;  ptre[0] = 2;  /* First column in
                                     the constraint matrix. */
      sub[0]  = 0;  val[0]  = 3.0;
      sub[1]  = 1;  val[1]  = 2.0;

      bkx[0]  = MSK_BK_LO;        /* Type of bound. */
      blx[0]  = 0.0;              /* Lower bound on the
                                     variables. */
      bux[0]  = MSK_INFINITY;     /* Upper bound on the
                                     variables.  */

      /* Variable: x1 */
      c[1]    = 1.0;

      ptrb[1] = 2;  ptre[1] = 5;
      sub[2]  = 0;  val[2]  = 1.0;
      sub[3]  = 1;  val[3]  = 1.0;
      sub[4]  = 2;  val[4]  = 2.0;

      bkx[1]  = MSK_BK_RA;
      blx[1]  = 0.0;
      bux[1]  = 10;


      /* Variable: x2 */
      c[2]    = 5.0;

      ptrb[2] = 5;  ptre[2] = 7;
      sub[5]  = 0;  val[5]  = 2.0;
      sub[6]  = 1;  val[6]  = 3.0;

      bkx[2]  = MSK_BK_LO;
      blx[2]  = 0.0;
      bux[2]  = MSK_INFINITY;

      /* Variable: x3 */
      c[3]    = 1.0;

      ptrb[3] = 7;  ptre[3] = 9;
      sub[7]  = 1;  val[7]  = 1.0;
      sub[8]  = 2;  val[8]  = 3.0;

      bkx[3]  = MSK_BK_LO;
      blx[3]  = 0.0;
      bux[3]  = MSK_INFINITY;

      MSK_putobjsense(task,
                      MSK_OBJECTIVE_SENSE_MAXIMIZE);

      /* Use the primal simplex optimizer. */
      MSK_putintparam(task,
                      MSK_IPAR_OPTIMIZER,
                      MSK_OPTIMIZER_PRIMAL_SIMPLEX);


      MSK_echotask(task,
                   MSK_STREAM_MSG,
                   "\nAdding constraints\n");
    
      r = MSK_append(task,
                     MSK_ACC_CON,
                     NUMCON);
   
      /* Adding bounds on empty constraints */
      for(i=0; r==MSK_RES_OK && i<NUMCON; ++i)
      {
        r = MSK_putbound(task,
                         MSK_ACC_CON,
                         i,
                         bkc[i], 
                         blc[i], 
                         buc[i]);
                         
      }

      /* Dynamically adding columns */
      for(j= 0; r==MSK_RES_OK && j<NUMVAR; ++j)
      {
        MSK_echotask(task,
                     MSK_STREAM_MSG,
                     "\nAdding a new variable.\n");

        r = MSK_append(task,MSK_ACC_VAR,1);

        if ( r==MSK_RES_OK )
          r = MSK_putcj(task,j,c[j]); 
                   
        if ( r==MSK_RES_OK )
          r = MSK_putavec(task,
                          MSK_ACC_VAR,
                          j,
                          ptre[j]-ptrb[j],
                          sub+ptrb[j],
                          val+ptrb[j]); 

        if ( r==MSK_RES_OK )
          r = MSK_putbound(task,
                           MSK_ACC_VAR,
                           j,
                           bkx[j], 
                           blx[j], 
                           bux[j]);
                             
        if(  r == MSK_RES_OK )
        {                            
          MSK_echotask(task,
                       MSK_STREAM_MSG,
                      "\nOptimizing\n");
                                                                        
          r = MSK_optimize(task);

          MSK_solutionsummary(task,MSK_STREAM_MSG);        
        }
      }

      MSK_deletetask(&task);
    }
  }
  MSK_deleteenv(&env);

  printf("Return code: %d (0 means no error occured.)\n",r);

  return ( r );
} /* main */
