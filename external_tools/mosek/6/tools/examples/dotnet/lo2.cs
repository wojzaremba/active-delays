/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:    lo2.cs

   Purpose: Demonstrates how to solve small linear
            optimization problem using the MOSEK C# API.
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

public class lo2
{  
  public static void Main ()
  {
    const int NUMCON = 3;
    const int NUMVAR = 4;
    const int NUMANZ = 9;
    
    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double
      infinity = 0;
    
    double[] c    = {3.0, 1.0, 5.0, 1.0};
    int[][]    asub = { new int[] {0,1,2},
                        new int[] {0,1,2,3},
                        new int[] {1,3} };
    double[][] aval = { new double[] {3.0,1.0,2.0},
                        new double[] {2.0,1.0,3.0,1.0},
                        new double[] {2.0,3.0} };
                        
                                                   
   mosek.boundkey[] bkc  = {mosek.boundkey.fx,
                            mosek.boundkey.lo,
                            mosek.boundkey.up};

   double[] blc  = {30.0,
                    15.0,
                   -infinity};
   double[] buc  = {30.0,
                    +infinity,
                    25.0};
   mosek.boundkey[]  bkx  = {mosek.boundkey.lo,
                             mosek.boundkey.ra,
                             mosek.boundkey.lo,
                             mosek.boundkey.lo};
   double[]  blx  = {0.0,
                     0.0,
                     0.0,
                     0.0};
   double[]  bux  = {+infinity,
                     10.0,
                     +infinity,
                     +infinity};

   mosek.Task 
     task = null;
   mosek.Env  
     env  = null;
   
   double[] xx  = new double[NUMVAR];
   
   try
     {
     // Make mosek environment. 
     env  = new mosek.Env ();
     // Direct the env log stream to the user specified
     // method env_msg_obj.streamCB 
     env.set_Stream (mosek.streamtype.log, new msgclass (""));
     // Initialize the environment.
     env.init ();
     // Create a task object linked with the environment env.
     task = new mosek.Task (env, 0,0);
     // Directs the log task stream to the user specified
     // method task_msg_obj.streamCB
     task.set_Stream (mosek.streamtype.log, new msgclass (""));

     /* Give MOSEK an estimate of the size of the input data. 
           This is done to increase the speed of inputting data. 
           However, it is optional. */
     task.putmaxnumvar(NUMVAR);
     task.putmaxnumcon(NUMCON);
     task.putmaxnumanz(NUMANZ);
     /* Append 'NUMCON' empty constraints.
           The constraints will initially have no bounds. */
     task.append(mosek.accmode.con,NUMCON);
     
     /* Append 'NUMVAR' variables.
           The variables will initially be fixed at zero (x=0). */
     task.append(mosek.accmode.var,NUMVAR);

     /* Optionally add a constant term to the objective. */
     task.putcfix(0.0);

     for(int j=0; j<NUMVAR; ++j)
     {
       /* Set the linear term c_j in the objective.*/  
       task.putcj(j,c[j]);
       /* Set the bounds on variable j.
                 blx[j] <= x_j <= bux[j] */
       task.putbound(mosek.accmode.var,j,bkx[j],blx[j],bux[j]);
     }
     /* Set the bounds on constraints.
             for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
     for(int i=0; i<NUMCON; ++i)
     {
         task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i]);

          /* Input row i of A */   
          task.putavec(mosek.accmode.con, /* Input row of A.*/
                       i,                     /* Row index.*/
                       asub[i],               /* Column indexes of non-zeros in row i.*/
                       aval[i]);              /* Non-zero Values of row i. */
     }

     task.putobjsense(mosek.objsense.maximize);
     task.optimize();
            // Print a summary containing information
            //   about the solution for debugging purposes
     task.solutionsummary(mosek.streamtype.msg);
     
     mosek.solsta solsta;
     mosek.prosta prosta;
     /* Get status information about the solution */
     task.getsolutionstatus(mosek.soltype.bas,
                            out prosta,
                            out solsta);
     task.getsolutionslice(mosek.soltype.bas, // Basic solution.     
                           mosek.solitem.xx,  // Which part of solution.
                           0,      // Index of first variable.
                           NUMVAR, // Index of last variable+1 
                           xx);
                
     switch(solsta)
     {
       case mosek.solsta.optimal:
       case mosek.solsta.near_optimal:      
         Console.WriteLine ("Optimal primal solution\n");
         for(int j = 0; j < NUMVAR; ++j)
           Console.WriteLine ("x[{0}]:",xx[j]);
         break;
       case mosek.solsta.dual_infeas_cer:
       case mosek.solsta.prim_infeas_cer:
       case mosek.solsta.near_dual_infeas_cer:
       case mosek.solsta.near_prim_infeas_cer:  
         Console.WriteLine("Primal or dual infeasibility.\n");
         break;
       case mosek.solsta.unknown:
         Console.WriteLine("Unknown solution status.\n");
         break;
       default:
         Console.WriteLine("Other solution status");
         break;
     }
   }
   catch (mosek.Exception e)
   {
     Console.WriteLine (e.Code);
     Console.WriteLine (e);
   }
   finally
     {
     if (task != null) task.Dispose ();
     if (env  != null)  env.Dispose ();
   }
  }
}
