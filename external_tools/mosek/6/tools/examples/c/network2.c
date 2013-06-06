#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mosek.h"

/*
  Demonstrates a simple use of network structure in a model.

   Purpose: 1. Read an optimization problem from an
                          user specified MPS file.
                     2. Extract the embedded network.
                     3. Solve the embedded network with the network optimizer.

   Note that the general simplex optimizer called though MSK_optimize can also extract 
   embedded network and solve it with the network optimizer. The direct call to the 
   network optimizer, which is demonstrated here, is offered as an option to save 
   memory and overhead when solving either many or large network problems.
 */

/* Helper functions  */
void addext(char filename[],
            char extension[])
{
  char *cptr;

  cptr = strrchr(filename,'.');
  if ( cptr && cptr[1]!='\\' )
    strcpy(cptr+1,extension);
  else
  {
    strcat(filename,".");
    strcat(filename,extension);
  }
} /* addext */

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
  MSKtask_t           task=NULL,dummytask=NULL;
  MSKintt             numcon=0,numvar=0,numnetcon,numnetvar;
  MSKidxt             *netcon,*netvar,*from,*to;
  MSKrealt            *scalcon,*scalvar,*cc,*cx,*blc,*buc,*blx,*bux,
                      *xc,*xx,*y,*slc,*suc,*slx,*sux;
  MSKboundkeye        *bkc,*bkx;
  MSKstakeye          *skc,*skx;
  MSKprostae          prosta;
  MSKsolstae          solsta;
  int                 i,j,k,*rmap,*cmap,hotstart=0;
  char                filename[1024];

  if ( argc<2 )
  {
    printf("No input file specified\n");
    exit(0);
  }
  else
    printf("Inputfile:  %s\n",argv[1]);
  
  r = MSK_makeenv(&env,NULL,NULL,NULL,NULL);
  
  if ( r==MSK_RES_OK )
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printlog);
    
  if ( r==MSK_RES_OK )
    r = MSK_initenv(env);
  
  if ( r==MSK_RES_OK )            
  {
    strcpy(filename,argv[1]);
    addext(filename,"log");
  
    /* Create an (empty) optimization task. */
    r = MSK_maketask(env,0,0,&task);

    if ( r==MSK_RES_OK )
    {
      MSK_linkfunctotaskstream(task, MSK_STREAM_LOG, NULL,     printlog);
      MSK_linkfiletotaskstream(task, MSK_STREAM_LOG, filename, 0);
    }
     
    if ( r==MSK_RES_OK )
    {
     r = MSK_readdata(task,argv[1]);
    }
  }

  if ( r==MSK_RES_OK )  
  {
    r = MSK_getnumcon(task,&numcon);
  }

  if ( r==MSK_RES_OK )  
  {
    r = MSK_getnumvar(task,&numvar);
  }

  if ( r==MSK_RES_OK )  
  {
    /* Create an (empty) optimization task. Will be used as a dummy task 
       in MSK_netoptimize, parameters can be set here */
    r = MSK_maketask(env,0,0,&dummytask);
  }

  if ( r==MSK_RES_OK )
  {
    MSK_linkfunctotaskstream(dummytask, MSK_STREAM_LOG, NULL,     printlog);
    MSK_linkfiletotaskstream(dummytask, MSK_STREAM_LOG, filename, 0);
  }

  /* Allocate memory for embedded network (maximum sizez => (numcon and numvar) */
  if ( r==MSK_RES_OK )       
  {
     /* Sizes of the embedded network structure is unknown use maximum size
        required  by MSK_networkextraction */
     rmap     = MSK_calloctask(dummytask,numcon,sizeof(int));
     cmap     = MSK_calloctask(dummytask,numvar,sizeof(int));
     netcon   = MSK_calloctask(dummytask,numcon,sizeof(MSKidxt));
     netvar   = MSK_calloctask(dummytask,numvar,sizeof(MSKidxt));
     from     = MSK_calloctask(dummytask,numvar,sizeof(MSKidxt));
     to       = MSK_calloctask(dummytask,numvar,sizeof(MSKidxt));

     scalcon  = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     scalvar  = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     cc       = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     cx       = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     blc      = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     buc      = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     blx      = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     bux      = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     xx       = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     xc       = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     y        = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     slc      = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     suc      = MSK_calloctask(dummytask,numcon,sizeof(MSKrealt));
     slx      = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));
     sux      = MSK_calloctask(dummytask,numvar,sizeof(MSKrealt));

     bkc      = MSK_calloctask(dummytask,numcon,sizeof(MSKboundkeye));
     bkx      = MSK_calloctask(dummytask,numvar,sizeof(MSKboundkeye));

     skc      = MSK_calloctask(dummytask,numvar,sizeof(MSKstakeye));
     skx      = MSK_calloctask(dummytask,numvar,sizeof(MSKstakeye));

     if( !( rmap    && cmap    && netcon && netvar && from && to  && 
            scalcon && scalvar && cc     && cx     && blc  && buc && 
            blx     && bux     && xx     && xc     && y    && slc && 
            suc     && slx     && sux    && bkc    && bkx  && skc && 
            skx ) )
     {
       r = MSK_RES_ERR_SPACE;
     }
     else
     {
       /* We just use zero cost on slacks */
       for( i = 0; i < numcon; ++i )
         cc[i] = 0.0;
     } 
  }

  if ( r==MSK_RES_OK )        
  {
    /* Extract embedded network */
    r = MSK_netextraction(task,
                          &numnetcon,
                          &numnetvar,
                          netcon,
                          netvar,
                          scalcon,
                          scalvar,
                          cx,
                          bkc,
                          blc,
                          buc,
                          bkx,
                          blx,
                          bux,
                          from,
                          to);

    MSK_deletetask(&task);
  }

  if ( r==MSK_RES_OK ) 
  {
    /* Solve embedded network with a direct call into the network optimizer */
    r =  MSK_netoptimize(dummytask,
                         numnetcon,
                         numnetvar,
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
                         hotstart,
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
      printf("Embedded network problem is optimal\n");
    }
    else if ( solsta == MSK_SOL_STA_PRIM_INFEAS_CER )
    {
      printf("Embedded network problem is primal infeasible\n");
    }
    else if ( solsta == MSK_SOL_STA_DUAL_INFEAS_CER )
    {
      printf("Embedded network problem is dual infeasible\n");
    }
    else
    {
      printf("Embedded network problem solsta : %d\n",solsta);
    }
  }

  /* Free allocated memory */
  MSK_freetask(dummytask,rmap);
  MSK_freetask(dummytask,cmap);
  MSK_freetask(dummytask,netcon);
  MSK_freetask(dummytask,netvar);
  MSK_freetask(dummytask,from);
  MSK_freetask(dummytask,to);
  MSK_freetask(dummytask,scalcon);
  MSK_freetask(dummytask,scalvar);
  MSK_freetask(dummytask,cc);
  MSK_freetask(dummytask,cx);
  MSK_freetask(dummytask,blc);
  MSK_freetask(dummytask,buc);
  MSK_freetask(dummytask,blx);
  MSK_freetask(dummytask,bux);
  MSK_freetask(dummytask,xx);
  MSK_freetask(dummytask,xc);
  MSK_freetask(dummytask,y);
  MSK_freetask(dummytask,slc);
  MSK_freetask(dummytask,suc);
  MSK_freetask(dummytask,slx);
  MSK_freetask(dummytask,sux);
  MSK_freetask(dummytask,bkc);
  MSK_freetask(dummytask,bkx);
  MSK_freetask(dummytask,skc);
  MSK_freetask(dummytask,skx);

  MSK_deletetask(&dummytask);
  MSK_deleteenv(&env);
}
