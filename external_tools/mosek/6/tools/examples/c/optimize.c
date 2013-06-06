#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mosek.h"

/*
   Purpose: 1. Reads an optimization problem from an
               user specified MPS file.
            2. Optimizes the problem.
            3. Writes the primal solution to the file filename.pri.
            4. Writes the dual solution to the file filename.dua.
 */


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

int main(int argc, char *argv[])
{
  char      filename[1024];
  double    *xx,*slc,*suc;
  int       r,j,i,numcon,numvar;
  FILE      *f;
  MSKenv_t  env;
  MSKtask_t task;

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

  #if 0
  MSK_putlicensedefaults(env,buffer,licbuf,licwait,0);
  #endif 
     
  if ( r==MSK_RES_OK ) 
    r = MSK_initenv(env);

  if ( r==MSK_RES_OK )              /* Check if return code is ok. */
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
      for(i=2; i<argc; ++i)
      {
        if ( argv[i][0]=='-' && argv[i][1]=='p' && i+1<argc )
        {
          MSK_putstrparam(task,MSK_SPAR_PARAM_READ_FILE_NAME,argv[i+1]);
          MSK_readparamfile(task);
          ++ i;
        }
      }

      r = MSK_readdata(task,argv[1]);
      if ( r==MSK_RES_OK )
      {
        r = MSK_optimize(task);
        if ( r==MSK_RES_OK )
        {
          MSK_solutionsummary(task,MSK_STREAM_MSG);

        }

        addext(filename,"sol");
        MSK_writesolution(task,MSK_SOL_ITR,filename);
      }
    }
    MSK_deletetask(&task);
  }

  MSK_deleteenv(&env);
  printf("Return code: %d (0 means no error occured.)\n",r);

  return ( r );
} /* main */


