/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:    milo1.cs

   Purpose:  Demonstrates how to solve a small mixed
             integer linear optimization problem using the MOSEK C# API.
 */


using System;

public class MsgClass : mosek.Stream
{

    public MsgClass ()
    {
      /* Construct the object */
    }

    public override void streamCB (string msg)
    {
        Console.Write ("{0}",msg);
    }
}

public class milo1
{
  public static void Main ()
  {
    const int NUMCON = 2;
    const int NUMVAR = 2;
    const int NUMANZ = 4;

    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double infinity = 0;

        
    mosek.boundkey[] bkc = { mosek.boundkey.up,
                             mosek.boundkey.lo };
    double[] blc = { -infinity,
                     -4.0 };
    double[] buc = { 250.0,
                     infinity }; 

    mosek.boundkey[] bkx = { mosek.boundkey.lo,
                             mosek.boundkey.lo  };
    double[] blx = { 0.0,
                     0.0 };
    double[] bux = { infinity,
                     infinity };

    double[] c   = {1.0, 0.64 };
    int[][] asub    = { new int[]  {0,   1},  new int[] {0,    1}   };
    double[][] aval = { new double[] {50.0, 3.0},new double[] {31.0, -2.0} };
        
    double[] xx  = new double[NUMVAR];

    mosek.Env env = null;
    mosek.Task task = null;
    
    try
      {
      // Make mosek environment. 
      env  = new mosek.Env ();
      // Direct the env log stream to the user specified
      // method env_msg_obj.streamCB 
      MsgClass env_msg_obj = new MsgClass ();
      env.set_Stream (mosek.streamtype.log,env_msg_obj);
      // Initialize the environment.
      env.init ();
      // Create a task object linked with the environment env.
      task = new mosek.Task (env, NUMCON,NUMVAR);
      // Directs the log task stream to the user specified
      // method task_msg_obj.streamCB
      MsgClass task_msg_obj = new MsgClass ();
      task.set_Stream (mosek.streamtype.log,task_msg_obj);
      
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
        /* Input column j of A */   
        task.putavec(mosek.accmode.var, /* Input columns of A.*/
                     j,                     /* Variable (column) index.*/
                     asub[j],               /* Row index of non-zeros in column j.*/
                     aval[j]);              /* Non-zero Values of column j. */
      }
      /* Set the bounds on constraints.
             for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
      for(int i=0; i<NUMCON; ++i)
        task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i]);
            
      /* Specify integer variables. */
      for(int j=0; j<NUMVAR; ++j)
        task.putvartype(j,mosek.variabletype.type_int);
      task.putobjsense(mosek.objsense.maximize);
           
      task.optimize();
             
      // Print a summary containing information
      //   about the solution for debugging purposes
      task.solutionsummary(mosek.streamtype.msg);
      
      mosek.solsta solsta;
      mosek.prosta prosta;
      /* Get status information about the solution */
      task.getsolutionstatus(mosek.soltype.itg,
                             out prosta,
                             out solsta);
      task.getsolutionslice(mosek.soltype.itg, // Integer solution.     
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
