/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:    DW.c

   Purpose: Demonstrates how to solve a small linear
            optimization problem with Dantzig-Wolfe column generation 
            using the MOSEK API.

            Syntax: dw subproblem.mps 
 */
 
#include <stdio.h>

#include "mosek.h"           /* Include the MOSEK definition file.       */

#define MASTERNUMCON 3       /* Number of constraints in masterproblem.  */
#define SUBNUMCON    5       /* Number of constraints in subproblem.     */
#define SUBNUMVAR    8       /* Number of variables in subproblem.       */
#define SUBNUMANZ    16      /* Number of numzeros in subproblem matrix. */
#define TOL          1.0e-8  /* Stopcriteria                             */
#define TOLA         1.0e-15 /* Zero tol in matrix                       */

/* Macro to test error codes from MOSEK */

#define MSK_checkerror(_r)                    \
{                                             \
     if( (_r) != MSK_RES_OK )                 \
     {                                        \
        printf("MOSEK error code %d\n",(_r)); \
        return (_r);                          \
     }                                        \
}

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  int       r,j,i,nz,mcols=0,
            index[SUBNUMVAR < MASTERNUMCON ? MASTERNUMCON : SUBNUMVAR],
            ienter[MASTERNUMCON],master_feasible;
  double    mblc[MASTERNUMCON],mbuc[MASTERNUMCON],mdual[MASTERNUMCON],
            venter[MASTERNUMCON],iblx,ibux,
            c[SUBNUMVAR],cs[SUBNUMVAR],mc,obj,rtemp,
            sprimal[SUBNUMVAR],A[MASTERNUMCON-1][SUBNUMVAR];
  MSKenv_t  env;
  MSKtask_t subtask,mastertask;
  MSKboundkeye mbkc[MASTERNUMCON],ibkx;
  MSKprostae sprobsta,mprobsta;
  MSKsolstae ssolsta,msolsta;

  /* Make mosek environment. */
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); 

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Directs the env log stream to the user
     specified procedure 'printstr'. */
  MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);

  /* Initialize the environment. */   
  r = MSK_initenv(env);

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Send a message to the MOSEK Message stream. */
  MSK_echoenv(env,
              MSK_STREAM_MSG,
              "Making the MOSEK optimization subproblem task\n");

  /* Make the subproblem optimization task. */
  r = MSK_maketask(env,SUBNUMCON,SUBNUMVAR,&subtask);

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Directs the log task stream to the user
     specified procedure 'printstr'. */

  MSK_linkfunctotaskstream(subtask,MSK_STREAM_LOG,NULL,printstr);

  /* Set subproblem to maximize */
  MSK_putobjsense(subtask,
                  MSK_OBJECTIVE_SENSE_MAXIMIZE);


  /* Choose primal simplex optimizer             */
  /* Only cost changes, stays primal feasible    */
  MSK_putintparam(subtask, 
                  MSK_IPAR_OPTIMIZER, 
                  MSK_OPTIMIZER_PRIMAL_SIMPLEX);

  MSK_echotask(subtask,
               MSK_STREAM_MSG,
               "Load the subproblem data.\n");

  if (argc != 2)
  {
    printf("Please give a single input file as argument.");
    return (1);
  }
  
  r = MSK_readdata(subtask,argv[1]);

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Store the objective         */
  r = MSK_getcslice(subtask, 
                    0, 
                    SUBNUMVAR, 
                    c);

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Send a message to the MOSEK Message stream. */
  MSK_echoenv(env,
              MSK_STREAM_MSG,
              "Making the MOSEK optimization "
              "masterproblem task\n");

  /* Make the masterproblem optimization task.    */
  r = MSK_maketask(env,MASTERNUMCON,0,&mastertask);

  /* Check if return code is ok. */
  MSK_checkerror(r);

  /* Directs the log task stream to the user
     specified procedure 'printstr'.                 */

  MSK_linkfunctotaskstream(mastertask,MSK_STREAM_LOG,NULL,printstr);

  /* Set masterproblem to maximize                   */
  MSK_putobjsense(mastertask,
                  MSK_OBJECTIVE_SENSE_MAXIMIZE);

  /* Choose primal simplex optimizer                 */
  /* Only appending columns, stays primal feasible   */
  MSK_putintparam(mastertask, 
                  MSK_IPAR_OPTIMIZER, 
                  MSK_OPTIMIZER_PRIMAL_SIMPLEX);

  /* For efficiency we do the following.  */
  /* We quess that there will be no more  */
  /* than 10 columns, we correct later if */
  /* this were not the case.              */ 
  r = MSK_putmaxnumvar(mastertask,10);

  /* Check if return code is ok.          */
  MSK_checkerror(r);

  /* The 10 columns have 3 non-zeroes each*/
  r = MSK_putmaxnumanz(mastertask,3*10); 

  /* Check if return code is ok.          */
  MSK_checkerror(r);

  /* Add the 10 columns                   */
  /* These are pr. default fixed to zero  */
  r = MSK_append(mastertask,
                 0,
                 10);

  /* Check if return code is ok.          */
  MSK_checkerror(r);

  /* Add the MASTERNUMCON constraints     */
  /* These are pr. default free           */
  r = MSK_append(mastertask,
                 1,
                 MASTERNUMCON);

  /* Check if return code is ok.          */
  MSK_checkerror(r);
  /* done efficiency calls.               */

  /* Setup the original master matrix in dense form 
     (since it is completely dense)                  */
  A[0][0] =  2.0;
  A[0][1] =  1.0;
  A[0][2] = -2.0;
  A[0][3] = -1.0;
  A[0][4] =  2.0;
  A[0][5] = -1.0;
  A[0][6] = -2.0;
  A[0][7] = -3.0;

  A[1][0] =  1.0;
  A[1][1] = -3.0;
  A[1][2] =  2.0;
  A[1][3] =  3.0;
  A[1][4] = -1.0;
  A[1][5] =  2.0;
  A[1][6] =  1.0;
  A[1][7] =  1.0;

  /* Setting up the initial masterproblem            */
  MSK_echotask(mastertask,
               MSK_STREAM_MSG,
               "Define the initial masterproblem\n");

  /* Constraint: 0 */
  mbkc[0]  = MSK_BK_FX;  /* Type of bound.           */
  mblc[0]  =  4.0;       /* Lower bound on the
                            constraint.              */
  mbuc[0]  =  4.0;       /* Upper bound on the
                            constraint.              */
  index[0] =  0;

  /* Constraint: 1 */
  mbkc[1]  = MSK_BK_FX;
  mblc[1]  =  -2.0;
  mbuc[1]  =  -2.0;
  index[1] =  1;

  /* Constraint: 2 */
  mbkc[2]  = MSK_BK_FX;
  mblc[2]  =  1.0;
  mbuc[2]  =  1.0;
  index[2] =  2;

  /* Input bounds on empty constraints                */
  r = MSK_putboundlist(mastertask,
                       1, 
                       MASTERNUMCON,
                       index,
                       mbkc,
                       mblc,
                       mbuc);

  /* Check if return code is ok.                      */
  MSK_checkerror(r);

  /* Starting Dantzig-Wolfe algorithm                 */
  MSK_echotask(mastertask,
               MSK_STREAM_MSG,
               "Solving problem using Dantzig-Wolfe "
               "column generation\n");

  /* Start main loop */
  while( r==MSK_RES_OK )
  {
    /* Optimize the masterproblem                      */
    MSK_echotask(mastertask,
                 MSK_STREAM_MSG,
                 "Solving the masterproblem\n");

    r = MSK_optimize(mastertask);

    /* Check if return code is ok.                     */
    MSK_checkerror(r);

    /* Write solution summary                          */
    MSK_solutionsummary(mastertask, MSK_STREAM_MSG);

    /* Get problem status key and dual solution        */
    MSK_echotask(mastertask,
                 MSK_STREAM_MSG,
                 "Getting problem status and dual solution "
                 "from the masterproblem\n");

    r = MSK_getsolution(mastertask,
                        MSK_SOL_BAS,
                        &mprobsta, 
                        &msolsta, 
                        NULL, 
                        NULL, 
                        NULL,
                        NULL,
                        NULL,
                        mdual,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL);

    /* Check if return code is ok.                      */
    MSK_checkerror(r);


    if( msolsta == MSK_SOL_STA_OPTIMAL )
       master_feasible = 1;
    else
       master_feasible = 0;

    /* If masterproblem is dual infeasible,
       then the original problem is also dual infeasible */ 
    if( msolsta == MSK_SOL_STA_DUAL_INFEAS_CER )
    { 
        MSK_echotask(subtask,
                     MSK_STREAM_MSG,
                     "Original problem is dual infeasible\n");
        break;
    }

    /* Compute new prices for the subproblem            */
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Compute new prices for the subproblem\n");


    for(j=0; j<SUBNUMVAR; ++j)
    {
       index[j] = j;

       /* If feasible then we do a normal cost calculation,
          if infeasible then MOSEK returns a farkas ray,
          which we use for a phase one cost */                 
       if( master_feasible )
         cs[j]    = c[j];
       else
         cs[j]    = 0.0;

       for(i=0; i<MASTERNUMCON-1; ++i)
           cs[j] -= mdual[i]*A[i][j];
    }

    /* Input new prices into the subproblem             */
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Input the new prices into the subproblem\n");

    r = MSK_putclist(subtask,
                     SUBNUMVAR,
                     index,
                     cs);

    /* Check if return code is ok.                       */
    MSK_checkerror(r);

    /* Optimize the subproblem                           */
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Solving the subproblem\n");

    r = MSK_optimize(subtask);

    /* Check if return code is ok.                       */
    MSK_checkerror(r);

    /* Write solution summary                            */
    MSK_solutionsummary(subtask, MSK_STREAM_MSG);

    /* Get problem status key and primal solution        */ 
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Getting problem status and primal solution "
                 "from the subproblem\n");

    r = MSK_getsolution(subtask,
                        MSK_SOL_BAS,
                        &sprobsta, 
                        &ssolsta, 
                        NULL, 
                        NULL, 
                        NULL,
                        NULL,
                        sprimal,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL);

    /* Check if return code is ok.                       */
    MSK_checkerror(r);

    /* Get the objective                                 */
    r = MSK_getsolutioninf(subtask,
                           MSK_SOL_BAS,
                           &sprobsta,
                           &ssolsta,
                           &obj,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL);

    /* Check if return code is ok.                       */
    MSK_checkerror(r);

    /* Check if we should stop the algorithm             
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Should we stop ?\n"); */

    /* Check stop criteria */
    if( obj-TOL < mdual[2] )
    {
       /* No improving entering column found             */
       if( msolsta == MSK_SOL_STA_OPTIMAL ) 
       { 
            /* Get master objective */
            r = MSK_getsolutioninf(mastertask,
                                   MSK_SOL_BAS,
                                   &sprobsta,
                                   &ssolsta,
                                   &obj,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL);

            /* If master feasible and optimal, then problem is optimal */
            MSK_echotask(subtask,
                         MSK_STREAM_MSG,
                         "Optimal solution : %-16.10e\n",obj);

       }
       else
       {
            /* If master infeasible, then problem is infeasible        */
            MSK_echotask(subtask,
                         MSK_STREAM_MSG,
                         "Original problem is primal infeasible\n");

       } 
       break;
    }

    /* Calculate a new column for the masterproblem                    */
    MSK_echotask(mastertask,
                 MSK_STREAM_MSG,
                 "Calculate new entering column for "
                 "the masterproblem\n");

    nz = 0;
    for( i=0; i<MASTERNUMCON-1; ++i )
    {
      rtemp = 0.0;
      for( j=0; j<SUBNUMVAR; ++j)
      {
        rtemp += sprimal[j]*A[i][j];
      } 

      if( rtemp > TOLA || rtemp < -TOLA )
      {
        ienter[nz] = i;
        venter[nz] = rtemp;
        ++nz;
      }
    }

    if( ssolsta ==  MSK_SOL_STA_OPTIMAL )
    {    
        /* If primal and dual feasible,   
           should be included in convexity constraint      */
        venter[nz] = 1.0;
        ienter[nz] = MASTERNUMCON-1;
        ++nz;
    }
    else if( ssolsta == MSK_SOL_STA_DUAL_INFEAS_CER )
    {
        /* If dual infeasible,
           should not be included in convexity constraint  */
    }
    else
    {
        /* Must be primal infeasible                       */
        MSK_echotask(subtask,
                     MSK_STREAM_MSG,
                     "Original problem is primal infeasible "
                     "(in subproblem)\n");
        break;
    }


    /* Calculate cost for entering column                  */
    mc = 0.0;
    for( j=0; j<SUBNUMVAR; ++j )
       mc += c[j]*sprimal[j];

    /* Input the new column into the masterproblem         */
    MSK_echotask(subtask,
                 MSK_STREAM_MSG,
                 "Inputting the new entering column " 
                 "into the masterproblem\n");

    /* Define bounds                                       */
    ibkx = MSK_BK_LO;
    iblx = 0.0;
    ibux = MSK_INFINITY;

    if( mcols < 10 )
    {
        /* We still have less columns than initial guess   */
        /* Put new coefficients                            */
        r = MSK_putavec(mastertask,
                        0,
                        mcols,
                        nz,
                        ienter,
                        venter);   

        /* Check if return code is ok.                     */
        MSK_checkerror(r);

        /* Put new bounds                                  */
        r = MSK_putbound(mastertask,
                         0,
                         mcols,
                         MSK_BK_LO,
                         0.0,
                         MSK_INFINITY);
      
        /* Check if return code is ok.                     */
        MSK_checkerror(r);

        /* Put new cost                                    */
        r = MSK_putclist(mastertask,
                         1,
                         &mcols,
                         &mc);
      
        /* Check if return code is ok.                     */
        MSK_checkerror(r);

        ++mcols;
    }
    else
    {
        /* Start and end defines                           */
        i = 0;
        j = nz;

        /* Our initial guess was wrong append one column   */
        if ( r==MSK_RES_OK )
        {  
          if (r == MSK_RES_OK)
            r = MSK_append(mastertask,
                           MSK_ACC_VAR,
                           1);

          r = MSK_putcj(mastertask,
                        mcols,
                        mc);

          if ( r==MSK_RES_OK )
            r = MSK_putbound(mastertask,
                             MSK_ACC_VAR,
                             mcols,
                             ibkx,
                             iblx,
                             ibux);

         if ( r==MSK_RES_OK ) 
           r = MSK_putavec(mastertask,
                           MSK_ACC_VAR,
                           mcols,
                           nz,
                           ienter,
                           venter);  

        /* Check if return code is ok.                     */
        MSK_checkerror(r);

        ++mcols;
      }
    }
  }

  MSK_deletetask(&mastertask);
  MSK_deletetask(&subtask);
 
  MSK_deleteenv(&env);

  return ( r );
} /* main */
