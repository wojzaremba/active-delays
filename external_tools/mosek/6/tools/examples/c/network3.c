#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mosek.h"

/*
  Demonstrates a more advanced use of network structure in a model.

   Purpose: 1. Read an optimization problem from an
               user specified MPS file.
            2. Extract the embedded network (if any ).
            3. Solve the embedded network with the network optimizer.
            4. Use the network solution to hotstart dual simplex on the  
               original problem.

   Note the general simplex optimizer called though MSK_optimize can also extract 
   embedded network and solve it with the network optimizer. The direct call to 
   the network optimizer, which is demonstrated here, is offered as an option to 
   save memory and overhead for solving either many or large network problems.
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
  MSKrealt            *scalcon,*scalvar,*cc,*cx,*blc,*buc,*blx,*bux,*xc,*xx,*y,
                      *slc,*suc,*slx,*sux;
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
    r = MSK_makeemptytask(env,&task);

    if ( r==MSK_RES_OK )
    {
      MSK_linkfunctotaskstream(task, MSK_STREAM_LOG, NULL,     printlog);
      MSK_linkfiletotaskstream(task, MSK_STREAM_LOG, filename, 0);
    }
  
     /* Specifies that data should be read from the
                  file argc[1]
            */
   
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

  /* Allocate memory for embedded network (maximum sizez => (numcon and numvar) */
  if ( r==MSK_RES_OK )              
  {
     /* Sizes of the embedded network structure is unknown use maximum size 
        required by MSK_networkextraction */
     rmap     = MSK_calloctask(task,numcon,sizeof(int));
     cmap     = MSK_calloctask(task,numvar,sizeof(int));
     netcon   = MSK_calloctask(task,numcon,sizeof(MSKidxt));
     netvar   = MSK_calloctask(task,numvar,sizeof(MSKidxt));
     from     = MSK_calloctask(task,numvar,sizeof(MSKidxt));
     to       = MSK_calloctask(task,numvar,sizeof(MSKidxt));

     scalcon  = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     scalvar  = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     cc       = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     cx       = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     blc      = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     buc      = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     blx      = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     bux      = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     xx       = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     xc       = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     y        = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     slc      = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     suc      = MSK_calloctask(task,numcon,sizeof(MSKrealt));
     slx      = MSK_calloctask(task,numvar,sizeof(MSKrealt));
     sux      = MSK_calloctask(task,numvar,sizeof(MSKrealt));

     bkc      = MSK_calloctask(task,numcon,sizeof(MSKboundkeye));
     bkx      = MSK_calloctask(task,numvar,sizeof(MSKboundkeye));

     skc      = MSK_calloctask(task,numvar,sizeof(MSKstakeye));
     skx      = MSK_calloctask(task,numvar,sizeof(MSKstakeye));

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

  if ( r==MSK_RES_OK )              
  {
    /* Set up hotstart for dual simplex  */

    /* Setup mark arrays  */
    for( i = 0; i < numcon; ++i )
      rmap[i] = 0;

    for( j = 0; j < numvar; ++j )
      cmap[j] = 0;
    
    for( i = 0; i < numnetcon; ++i )
    { 
      rmap[netcon[i]]      = i+1;
    }
    
    for( j = 0; j < numnetvar; ++j )
    {
      cmap[netvar[j]]      = j+1;
    }

    /* Unscale rows and set up solution */
    for( i = 0; i < numcon && r == MSK_RES_OK; ++i)
    {
      if( rmap[i] )
      {
        /* Get index in network solution  */
        k        = rmap[i]-1;

        if ( solsta != MSK_SOL_STA_PRIM_INFEAS_CER )
        {
          xc[k]  /= scalcon[i];
        }
                
        if ( solsta != MSK_SOL_STA_DUAL_INFEAS_CER )
        {
          slc[k] *= scalcon[i];
          suc[k] *= scalcon[i];
        }
      
        /* Scaling value is negative, then bound keys has been changed  */
        if( scalcon[i] < 0.0 )
        {
          if( skc[k] == MSK_SK_LOW )
          {
            skc[k] = MSK_SK_UPR;
          }
          else if( skc[k] == MSK_SK_UPR )
          {
            skc[k] = MSK_SK_LOW;
          }
        }

        /* In network => use network status keys and solution */
        r = MSK_putsolutioni (task,
                              MSK_ACC_CON,
                              i,
                              MSK_SOL_BAS,
                              skc[k],
                              xc[k],
                              slc[k],
                              suc[k],
                              0.0);
      }
      else
      {
        /* Not in network => make basic */
        r = MSK_putsolutioni (task,
                              MSK_ACC_CON,
                              i,
                              MSK_SOL_BAS,
                              MSK_SK_BAS,
                              0.0,
                              0.0,
                              0.0,
                              0.0);
      }
    }

    /* Unscale columns and set up solution */
    for( j = 0; j < numvar && r == MSK_RES_OK; ++j)
    {
      if( cmap[j] )
      {
        /* Get index in network solution  */
        k        = cmap[j]-1;

        if ( solsta != MSK_SOL_STA_PRIM_INFEAS_CER )
        {
          xx[k]  /= scalvar[j];
        }
                
        if ( solsta != MSK_SOL_STA_DUAL_INFEAS_CER )
        {
          slx[k] *= scalvar[j];
          sux[k] *= scalvar[j];
        }
      
        /* Scaling value is negative, then bound keys has been changed  */
        if( scalvar[j] < 0.0 )
        {
          if( skx[k] == MSK_SK_LOW )
          {
            skx[k] = MSK_SK_UPR;
          }
          else if( skx[k] == MSK_SK_UPR )
          {
            skx[k] = MSK_SK_LOW;
          }
        }

        /* In network => use network status keys and solution */
        r = MSK_putsolutioni (task,
                              MSK_ACC_VAR,
                              j,
                              MSK_SOL_BAS,
                              skx[k],
                              xx[k],
                              slx[k],
                              sux[k],
                              0.0);
      }
      else
      {
        MSKboundkeye bk;
        MSKrealt bl,bu;
  
        r = MSK_getbound (task,
                          MSK_ACC_VAR,
                          j,
                          &bk,
                          &bl,
                          &bu);
        
        if( r == MSK_RES_OK )
        { 
          /* Not in network => value should correspond to fixed levels  */
          switch( bk )
          {
            case MSK_BK_FX:
              /* Put on fixed */
              r = MSK_putsolutioni (task,
                                    MSK_ACC_VAR,
                                    j,
                                    MSK_SOL_BAS,
                                    MSK_SK_FIX,
                                    bl,
                                    0.0,
                                    0.0,
                                    0.0);
              break;
            case MSK_BK_LO:
            case MSK_BK_RA:
              /* Put on lower */
              r = MSK_putsolutioni (task,
                                    MSK_ACC_VAR,
                                    j,
                                    MSK_SOL_BAS,
                                    MSK_SK_LOW,
                                    bl,
                                    0.0,
                                    0.0,
                                    0.0);
              break;
            case MSK_BK_UP:
              /* Put on upper */
              r = MSK_putsolutioni (task,
                                    MSK_ACC_VAR,
                                    j,
                                    MSK_SOL_BAS,
                                    MSK_SK_UPR,
                                    bu,
                                    0.0,
                                    0.0,
                                    0.0);
              break;
            case MSK_BK_FR:
              /* Put on superbasic */
              r = MSK_putsolutioni (task,
                                    MSK_ACC_VAR,
                                    j,
                                    MSK_SOL_BAS,
                                    MSK_SK_SUPBAS,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0);
              break;
          }
        }
      }
    }

    /* Switch off presolve (not a requirement) */
    if ( r==MSK_RES_OK )              
      r =  MSK_putintparam(task,
                           MSK_IPAR_PRESOLVE_USE,MSK_OFF);

    /* Choose dual simplex */
    if ( r==MSK_RES_OK )              
      r =  MSK_putintparam(task,
                           MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_DUAL_SIMPLEX);

    /* Reoptimize from the found solution from the network optimizer  */
    if ( r==MSK_RES_OK )              
      r =  MSK_optimize(task);

    /* Get solution status */
    if ( r==MSK_RES_OK )              
      r = MSK_getsolutioninf (task,
                              MSK_SOL_BAS,
                              &prosta,
                              &solsta,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL);


    if ( r==MSK_RES_OK )              
    {      
      if ( solsta == MSK_SOL_STA_OPTIMAL )
      {
        printf("Original problem is optimal\n");
      }
      else if ( solsta == MSK_SOL_STA_PRIM_INFEAS_CER )
      {
        printf("Original problem is primal infeasible\n");
      }
      else if ( solsta == MSK_SOL_STA_DUAL_INFEAS_CER )
      {
        printf("Original is dual infeasible\n");
      }
      else
      {
        printf("Original problem solsta : %d\n",solsta);
      }
    }
  }

  /* Free allocated memory */
  MSK_freetask(task,rmap);
  MSK_freetask(task,cmap);
  MSK_freetask(task,netcon);
  MSK_freetask(task,netvar);
  MSK_freetask(task,from);
  MSK_freetask(task,to);
  MSK_freetask(task,scalcon);
  MSK_freetask(task,scalvar);
  MSK_freetask(task,cc);
  MSK_freetask(task,cx);
  MSK_freetask(task,blc);
  MSK_freetask(task,buc);
  MSK_freetask(task,blx);
  MSK_freetask(task,bux);
  MSK_freetask(task,xx);
  MSK_freetask(task,xc);
  MSK_freetask(task,y);
  MSK_freetask(task,slc);
  MSK_freetask(task,suc);
  MSK_freetask(task,slx);
  MSK_freetask(task,sux);
  MSK_freetask(task,bkc);
  MSK_freetask(task,bkx);
  MSK_freetask(task,skc);
  MSK_freetask(task,skx);

  MSK_deletetask(&task);
  MSK_deletetask(&dummytask);
  MSK_deleteenv(&env);
}
