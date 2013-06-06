/* 
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      mioinitsol.c

   Purpose:   Demonstrates how to solve a MIP with a start guess.

   Syntax:    mioinitsol mioinitsol.lp 
 */

using System;

class msgclass : mosek.Stream 
{
  string prefix;
  public msgclass (string prfx) 
  {
    prefix = prfx;
  }
  
  public override void streamCB (string msg)
  {
    Console.Write ("{0}{1}", prefix,msg);
  }
}

public class mioinitsol
{  
    public static void Main ()
    {
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double
            infinity = 0;

        int NUMVAR = 4;
        int NUMCON = 1;
        int NUMINTVAR = 3;

        double[] c = { 7.0, 10.0, 1.0, 5.0 };
        
        mosek.boundkey[] bkc = {mosek.boundkey.up};
        double[] blc = {-infinity};
        double[] buc = {2.5};
        mosek.boundkey[] bkx = {mosek.boundkey.lo,
                                mosek.boundkey.lo,
                                mosek.boundkey.lo,
                                mosek.boundkey.lo};
        double[] blx = {0.0,
                        0.0,
                        0.0,
                        0.0};
        double[] bux = {infinity,
                        infinity,
                        infinity,
                        infinity};
        
        int[] ptrb = {0, 1, 2, 3};
        int[]  ptre = {1, 2, 3, 4};
        double[]  aval = {1.0, 1.0, 1.0, 1.0};
        int[] asub = {0,   0,   0,   0  };
        int[] intsub = {0, 1, 2};  
        double[] xx  = new double[NUMVAR];

        try
          {
            // Make mosek environment. 
            env  = new mosek.Env ();
            // Direct the env log stream to the user specified
            // method env_msg_obj.streamCB 
            env.set_Stream (mosek.streamtype.log, new msgclass ("[env]"));
            // Initialize the environment.
            env.init ();
            // Create a task object linked with the environment env.
            task = new mosek.Task (env, NUMCON,NUMVAR);
            // Directs the log task stream to the user specified
            // method task_msg_obj.streamCB
            task.set_Stream (mosek.streamtype.log, new msgclass ("[task]"));
            task.inputdata(NUMCON,NUMVAR,
                           c,
                           0.0,
                           ptrb,
                           ptre,
                           asub,
                           aval,
                           bkc,
                           blc,
                           buc,
                           bkx,
                           blx,
                           bux);

            for(int j=0 ; j<NUMINTVAR ; ++j)            
              task.putvartype(intsub[j],mosek.variabletype.type_int);
            task.putobjsense(mosek.objsense.maximize);

            // Construct an initial feasible solution from the
            //     values of the integer valuse specified 
            task.putintparam(mosek.iparam.mio_construct_sol,
                             mosek.onoffkey.on);
        
            // Set status of all variables to unknown 
            task.makesolutionstatusunknown(mosek.soltype.itg);
        
            // Assign values 1,1,0 to integer variables 
            task.putsolutioni (
                               mosek.accmode.var,
                               0,
                               mosek.soltype.itg, 
                               mosek.stakey.supbas, 
                               0.0,
                               0.0,
                               0.0,
                               0.0);
        
            task.putsolutioni (
                               mosek.accmode.var,
                               1,
                               mosek.soltype.itg, 
                               mosek.stakey.supbas, 
                               2.0,
                               0.0,
                               0.0,
                               0.0);
        
        
            task.putsolutioni (
                               mosek.accmode.var,
                               2,
                               mosek.soltype.itg, 
                               mosek.stakey.supbas, 
                               0.0,
                               0.0,
                               0.0,
                               0.0);

            try
              {
                task.optimize();
              }
            catch (mosek.Warning w)
              {
                Console.WriteLine("Mosek warning:");
                Console.WriteLine (w.Code);
                Console.WriteLine (w);
              }
            task.getsolutionslice(mosek.soltype.itg, /* Basic solution.       */
                                  mosek.solitem.xx,  /* Which part of solution.  */
                                  0,                 /* Index of first variable. */
                                  NUMVAR,            /* Index of last variable+1 */
                                  xx);

            for(int j = 0; j < NUMVAR; ++j)
              Console.WriteLine ("x[{0}]:{1}", j,xx[j]);
          }
        catch (mosek.Exception e)
            {
                Console.WriteLine (e.Code);
                Console.WriteLine (e);
            }

        if (task != null) task.Dispose ();
        if (env  != null)  env.Dispose ();
    }
} 
  
