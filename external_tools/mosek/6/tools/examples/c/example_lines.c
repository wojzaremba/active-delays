/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      example_lines.c

  Purpose: This example is not meant to be distributed. It
           demonstrates some functionality used in the manual.
           It is means to compile _only_! It will not run!
*/

#include <mosek.h>

int main (int argc, char ** argv)
{
  MSKenv_t  env = NULL;
  MSKtask_t task = NULL;
  MSKrescodee res = MSK_RES_OK;
  MSKintt numvar = 0;

  res = MSK_makeenv(&env, NULL,NULL,NULL,NULL);
  
  if (res == MSK_RES_OK)
    res = MSK_initenv(env);
  
  if (res == MSK_RES_OK)
    res = MSK_maketask(env, 0,0, &task);

  if (res == MSK_RES_OK)
  {
    MSKrealt * c = MSK_calloctask(task, numvar, sizeof(MSKrealt));
    MSK_getc(task,c);
  }

  if (res == MSK_RES_OK)
  {
    MSKrealt * upper_bound   = MSK_calloctask(task,8,sizeof(MSKrealt));
    MSKrealt * lower_bound   = MSK_calloctask(task,8,sizeof(MSKrealt));
    MSKboundkeye * bound_key = MSK_calloctask(task,8,sizeof(MSKboundkeye));
    MSK_getboundslice(task,MSK_ACC_CON, 2,10,
                      bound_key,lower_bound,upper_bound);
  }
  if (res == MSK_RES_OK)
  {
    MSKidxt bound_index[]    = {         1,         6,         3,         9 };
    MSKboundkeye bound_key[] = { MSK_BK_FR, MSK_BK_LO, MSK_BK_UP, MSK_BK_FX };
    MSKrealt lower_bound[]   = {       0.0,     -10.0,       0.0,       5.0 };
    MSKrealt upper_bound[]   = {       0.0,       0.0,       6.0,       5.0 };
    MSK_putboundlist(task,MSK_ACC_CON, 4, bound_index,
                      bound_key,lower_bound,upper_bound);
  }
  if (res == MSK_RES_OK)
  {
    MSKidxt subi[] = {   1,   3,   5 };
    MSKidxt subj[] = {   2,   3,   4 };
    MSKrealt cof[] = { 1.1, 4.3, 0.2 };
    MSK_putaijlist(task,3, subi,subj,cof);
  }


  if (res == MSK_RES_OK)
  {
    MSKlintt rowsub[] = { 0, 1, 2, 3 };
    MSKlidxt ptrb[]   = { 0, 3, 5, 7 };
    MSKlidxt ptre[]   = { 3, 5, 7, 8 };
    MSKlidxt sub[]    = { 0, 2, 3, 1, 4, 0, 3, 2 };
    MSKrealt cof[]    = { 1.1, 1.3, 1.4, 2.2, 2.5, 3.1, 3.4, 4.4 };
                  
    MSK_putaveclist (task,MSK_ACC_CON,4,
                     rowsub,ptrb,ptre,
                     sub,cof);
  }
  
  MSK_deletetask(&task);
  MSK_deleteenv(&env);
}
