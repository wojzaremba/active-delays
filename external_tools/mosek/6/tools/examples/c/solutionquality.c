/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    solutionquality.c

  Purpose: To demonstrate how to examine the quality of a solution. 
*/
#include "mosek.h"
#include "math.h"

static void MSKAPI printstr(void *handle,
                            char str[])
{
  printf("%s",str);
} /* printstr */


double double_max(double arg1,double arg2)
{
  return arg1<arg2 ? arg2 : arg1;
}

int main (int argc, char * argv[])
{
  MSKtask_t   task = NULL;
  MSKenv_t    env  = NULL;
  MSKrescodee r  = MSK_RES_OK;

  if (argc <= 1)
  {
    printf ("Missing argument. The syntax is:\n");
    printf (" simple inputfile [ solutionfile ]\n");
  }
  else
  {    
    /* Create the mosek environment. 
       The `NULL' arguments here, are used to specify customized 
       memory allocators and a memory debug file. These can
       safely be ignored for now. */
    
    r = MSK_makeenv(&env, NULL, NULL, NULL, NULL);
      
    /* Initialize the environment */
    if ( r==MSK_RES_OK )
      MSK_initenv (env);

    /* Create a task object linked to the environment env.
       Initially we create it with 0 variables and 0 columns, 
       since we do not know the size of the problem. */ 
    if ( r==MSK_RES_OK )
      r = MSK_maketask (env, 0,0, &task);

    if (r == MSK_RES_OK)
      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);
      
    /* We assume that a problem file was given as the first command
       line argument (received in `argv'). */
    if ( r==MSK_RES_OK )   
      r = MSK_readdata (task, argv[1]);


    /* Solve the problem */
    if ( r==MSK_RES_OK )
    {
      MSKrescodee trmcode;
      
      MSK_optimizetrm(task,&trmcode);
    }

    /* Print a summary of the solution. */
    MSK_solutionsummary(task, MSK_STREAM_MSG);

    if (r == MSK_RES_OK)
    {
      MSKprostae prosta;
      MSKsolstae  solsta;
      MSKrealt primalobj,maxpbi,maxpcni,maxpeqi,maxinti,
        dualobj, maxdbi, maxdcni, maxdeqi;
      MSKintt isdef;
      MSKsoltypee whichsol = MSK_SOL_BAS;
      int accepted = 1;
      
        
      MSK_getsolutioninf (
                          task,
                          whichsol,
                          &prosta,
                          &solsta,
                          &primalobj,
                          &maxpbi,
                          &maxpcni,
                          &maxpeqi,
                          &maxinti,
                          &dualobj,
                          &maxdbi,
                          &maxdcni,
                          &maxdeqi);

        switch(solsta)
        {
          case MSK_SOL_STA_OPTIMAL:
          case MSK_SOL_STA_NEAR_OPTIMAL:
            {
              double max_primal_infeas = 0.0; /* maximal primal infeasibility */
              double max_dual_infeas   = 0.0; /* maximal dual infeasibility */
              double obj_gap = fabs(dualobj-primalobj);
           
            
              max_primal_infeas = double_max(max_primal_infeas,maxpbi);
              max_primal_infeas = double_max(max_primal_infeas,maxpcni);
              max_primal_infeas = double_max(max_primal_infeas,maxpeqi);
            
              max_dual_infeas = double_max(max_dual_infeas,maxdbi);
              max_dual_infeas = double_max(max_dual_infeas,maxdcni);
              max_dual_infeas = double_max(max_dual_infeas,maxdeqi);

              /* Assume the application needs the solution to be within
                 1e-6 ofoptimality in an absolute sense. Another approach
                 would be looking at the relative objective gap */
              printf("Objective gap: %e\n",obj_gap);
              if (obj_gap > 1e-6)
              {
                printf("Warning: The objective gap is too large.");
                accepted = 0;
              }            

              printf("Max primal infeasibility: %e\n", max_primal_infeas);
              printf("Max dual infeasibility: %e\n"  , max_dual_infeas);

              /* We will accept a primal infeasibility of 1e-8 and
                 dual infeasibility of 1e-6 */
            
              if (max_primal_infeas > 1e-8)
              {
                printf("Warning: Primal infeasibility is too large");
                accepted = 0;
              }

              if (max_dual_infeas > 1e-6)
              {
                printf("Warning: Dual infeasibility is too large");
                accepted = 0;
              }         
            }
            
            if (accepted && r == MSK_RES_OK)
            {
              MSKintt numvar,j;
              MSKrealt *xx = NULL;

              MSK_getnumvar(task,&numvar);
              
              xx = (double *) malloc(numvar*sizeof(MSKrealt));
              
              MSK_getsolutionslice(task,
                                   MSK_SOL_BAS,    /* Request the basic solution. */
                                   MSK_SOL_ITEM_XX,/* Which part of solution.     */
                                   0,              /* Index of first variable.    */
                                   numvar,         /* Index of last variable+1.   */
                                   xx);

      
              printf("Optimal primal solution\n");
              for(j=0; j<numvar; ++j)
                printf("x[%d]: %e\n",j,xx[j]);

              free(xx);
            }
            else
            {
              /* Print detailed information about the solution */
              if (r == MSK_RES_OK)
                r = MSK_analyzesolution(task,MSK_STREAM_LOG,whichsol);
            }
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
            printf("Other solution status");
            break;
        }
    }
    else
    {
      printf("Error while optimizing.\n");
    }

    MSK_deletetask(&task);
    MSK_deleteenv(&env);
  }
  return r;
}
