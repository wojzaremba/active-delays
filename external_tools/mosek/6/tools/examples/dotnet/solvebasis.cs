/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File     : solvebasis.cs
 
  Purpose  :  To demonstrate the usage of
              MSK_solvewithbasis on the problem:
 
              maximize  x0 + x1
              st. 
                      x0 + 2.0 x1 <= 2
                      x0  +    x1 <= 6
                      x0 >= 0, x1>= 0

               The problem has the slack variables
               xc0, xc1 on the constraints
               and the variabels x0 and x1.

               maximize  x0 + x1
               st. 
                  x0 + 2.0 x1 -xc1       = 2
                  x0  +    x1       -xc2 = 6                     
                  x0 >= 0, x1>= 0,
                  xc1 <=  0 , xc2 <= 0
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

public class lo1
{  
public static void Main ()
  {
    const int NUMCON = 2;
    const int NUMVAR = 2;

    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double
      infinity = 0;

    double[] c    = {1.0, 1.0};
    int[]    ptrb = {0, 2};
    int[]    ptre = {2, 3};
    int[]    asub = {0, 1,
                     0, 1};
    double[] aval = {1.0, 1.0,
                     2.0, 1.0};
    mosek.boundkey[] bkc  = {mosek.boundkey.up,
                             mosek.boundkey.up};
        
    double[] blc  = {-infinity,
                     -infinity};
    double[] buc  = {2.0,
                     6.0};
        
    mosek.boundkey[]  bkx  = {mosek.boundkey.lo,
                              mosek.boundkey.lo};
    double[]  blx  = {0.0,
                      0.0};
        
    double[]  bux  = {+infinity,
                      +infinity};
    mosek.Task 
      task = null;
    mosek.Env  
      env  = null;
        
    double[] w1 = {2.0, 6.0};
    double[] w2 = {1.0, 0.0};
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
      task.putobjsense(mosek.objsense.maximize);
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
                                
      int[] basis = new int[NUMCON];
      task.initbasissolve(basis);
                
      //List basis variables corresponding to columns of B             
      int[] varsub = {0,1};
      for (int i = 0; i < NUMCON; i++) {
        if (basis[varsub[i]] < NUMCON) 
          Console.WriteLine ("Basis variable no {0} is xc{1}",
                             i,
                             basis[i]);                                            
        else 
          Console.WriteLine ("Basis variable no {0} is x{1}",
                             i,
                             basis[i] - NUMCON);
      }
                
      // solve Bx = w1
      // varsub contains index of non-zeros in b.
      //  On return b contains the solution x and
      // varsub the index of the non-zeros in x. 
      int nz = 2; 
      
      task.solvewithbasis(0, ref nz, varsub, w1);
      Console.WriteLine ("nz = {0}", nz);
      Console.WriteLine ("Solution to Bx = w1:\n");
                
      for (int i = 0; i < nz; i++) {
        if (basis[varsub[i]] < NUMCON) 
          Console.WriteLine ("xc {0} = {1}",
                             basis[varsub[i]],
                             w1[varsub[i]] );  
        else 
          Console.WriteLine ("x{0} = {1}",
                             basis[varsub[i]] - NUMCON,
                             w1[varsub[i]]);       
      }

      // Solve B^Tx = w2 
      nz = 1;
      varsub[0] = 0;
                
      task.solvewithbasis(1, ref nz, varsub, w2);

      Console.WriteLine ("\nSolution to B^Tx = w2:\n");

      for (int i = 0; i < nz; i++) {
        if (basis[varsub[i]] < NUMCON) 
          Console.WriteLine ("xc {0} = {1}",
                             basis[varsub[i]],
                             w2[varsub[i]]);
        else 
          Console.WriteLine ("x {0} = {1}",
                             basis[varsub[i]] - NUMCON,
                             w2[varsub[i]]);   
      }
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
