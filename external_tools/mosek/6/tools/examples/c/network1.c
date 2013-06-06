#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mosek.h"

/*
  Demonstrates a simple use of the network optimizer.

   Purpose: 1. Specify data for a network.
            2. Solve the network problem with the network optimizer.
 */

/* Network sizes */
#define NUMCON 4 /* Nodes in network */
#define NUMVAR 6 /* Arcs in network */

void MSKAPI printlog(void *ptr,
                     char s[])
{
  printf("%s",s);
} /* printlog */

/* Main function  */
int main(int argc, char *argv[])
{
  MSKrescodee         r;
  MSKenv_t            env;
  MSKtask_t           dummytask=NULL;
  MSKidxt             from[] = {0,2,3,1,1,1},
                      to[]   = {2,3,1,0,2,2};
  MSKrealt            cc[]   = {0.0,0.0},
                      cx[]   = {1.0,0.0,1.0,0.0,-1.0,1.0},
                      blc[]  = {1.0,1.0,-2.0,0.0},
                      buc[]  = {1.0,1.0,-2.0,0.0}, 
                      blx[]  = {0.0,0.0,0.0,0.0,0.0,0.0},
                      bux[]  = {MSK_INFINITY,MSK_INFINITY,MSK_INFINITY,
                               MSK_INFINITY,MSK_INFINITY,MSK_INFINITY},
                      xc[NUMCON],xx[NUMVAR],y[NUMCON],slc[NUMCON],
                      suc[NUMCON],slx[NUMVAR],sux[NUMVAR];
  MSKboundkeye        bkc[] = {MSK_BK_FX,MSK_BK_FX,MSK_BK_FX,MSK_BK_FX},
                      bkx[] = {MSK_BK_LO,MSK_BK_LO,MSK_BK_LO,MSK_BK_LO,
                               MSK_BK_LO,MSK_BK_LO};
  MSKstakeye          skc[NUMCON],skx[NUMVAR];
  MSKprostae          prosta;
  MSKsolstae          solsta;
  int                 i,j;
  
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printlog);
    
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);
  
  if ( r==MSK_RES_OK )
  {
    /* Create an optimization task. 
       Will be used as a dummy task in MSK_netoptimize, parameters can be set here */
    r = MSK_maketask(env,0,0,&dummytask);
  }

  if ( r==MSK_RES_OK )
  {
    MSK_linkfunctotaskstream(dummytask, MSK_STREAM_LOG, NULL,     printlog);
  }

  if ( r==MSK_RES_OK )
  {
    r = MSK_putobjsense(dummytask, MSK_OBJECTIVE_SENSE_MAXIMIZE);
  }

  if ( r==MSK_RES_OK )
  {
    /* Solve network problem with a direct call into the network optimizer */
    r =  MSK_netoptimize(dummytask,
                         NUMCON,
                         NUMVAR,
                         cc,
                         cx,
                         bkc,
                         blc,
                         buc,
                         bkx,
                         blx,
                         bux,
                         from,
                         to,
                         &prosta,
                         &solsta,
                         0,
                         skc,
                         skx,
                         xc,
                         xx,
                         y,
                         slc,
                         suc,
                         slx,
                         sux);

    if ( solsta == MSK_SOL_STA_OPTIMAL )
    {
      printf("Network problem is optimal\n");

      printf("Primal solution is :\n");
      for( i = 0; i < NUMCON; ++i )
        printf("xc[%d] = %-16.10e\n",i,xc[i]);

      for( j = 0; j < NUMVAR; ++j )
        printf("Arc(%d,%d) -> xx[%d] = %-16.10e\n",from[j],to[j],j,xx[j]);
    }
    else if ( solsta == MSK_SOL_STA_PRIM_INFEAS_CER )
    {
      printf("Network problem is primal infeasible\n");
    }
    else if ( solsta == MSK_SOL_STA_DUAL_INFEAS_CER )
    {
      printf("Network problem is dual infeasible\n");
    }
    else
    {
      printf("Network problem solsta : %d\n",solsta);
    }
  }

  MSK_deletetask(&dummytask);
  MSK_deleteenv(&env);
}
