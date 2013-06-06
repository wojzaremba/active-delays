/* File:    qo1.cs

Purpose: Demonstrate how to solve a quadratic
optimization problem using the MOSEK .NET API.
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

public class qo1
{
  public static void Main ()
  {
    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    const double infinity = 0;
    const int NUMCON = 1;   /* Number of constraints.             */
    const int NUMVAR = 3;   /* Number of variables.               */
    const int NUMANZ = 9;   /* Number of numzeros in A.           */

    double[] c = {0.0,-1.0,0.0};
    
    mosek.boundkey[]  bkc   = {mosek.boundkey.lo};
    double[] blc = {1.0};
    double[] buc = {infinity};
    
    mosek.boundkey[]  bkx   = {mosek.boundkey.lo,
                               mosek.boundkey.lo,
                               mosek.boundkey.lo};        
    double[] blx  = {0.0,
                     0.0,
                     0.0};
    double[] bux  = {+infinity,
                     +infinity,
                     +infinity};
     
    int[][]    asub  = { new int[] {0},   new int[] {0},   new int[] {0}};
    double[][] aval  = { new double[] {1.0}, new double[] {1.0}, new double[] {1.0}};
        
    mosek.Task 
      task = null;
    mosek.Env
      env = null;
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

      /*
       * The lower triangular part of the Q
       * matrix in the objective is specified.
       */

      int[]    qsubi = {0,   1,    2,   2  };
      int[]    qsubj = {0,   1,    0,   2  };
      double[] qval =  {2.0, 0.2, -1.0, 2.0};
            
      /* Input the Q for the objective. */

      task.putobjsense(mosek.objsense.minimize);

      task.putqobj(qsubi,qsubj,qval);

      task.optimize();

      // Print a summary containing information
      //   about the solution for debugging purposes
      task.solutionsummary(mosek.streamtype.msg);
      
      mosek.solsta solsta;
      mosek.prosta prosta;
      /* Get status information about the solution */
      task.getsolutionstatus(mosek.soltype.itr,
                             out prosta,
                             out solsta);
      task.getsolutionslice(mosek.soltype.itr, // Interior point solution.     
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
        Console.WriteLine (e);
      }
    finally
      {
        if (task != null) task.Dispose ();
        if (env  != null)  env.Dispose ();
      }
  } /* Main */
}
