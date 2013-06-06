package lo1;
 
/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      lo1.java

   Purpose:   Demonstrates how to solve a small linear
              optimization problem using the MOSEK Java API.
*/

class msgclass extends mosek.Stream {
  public msgclass ()
  {
    super ();
  }
  
  public void stream (String msg)
    {
      System.out.print (msg);
  }
}
 
public class lo1
{
  static final int NUMCON = 3;
  static final int NUMVAR = 4;
  static final int NUMANZ = 9;
       
  public static void main (String[] args)
  {
    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double
      infinity = 0;
    
    double c[]    = {3.0, 1.0, 5.0, 1.0};
    int    asub[][] = { {0, 1},
                        {0, 1, 2},
                        {0, 1},
                        {1, 2} };
    double aval[][] = { {3.0, 2.0},
                        {1.0, 1.0, 2.0},
                        {2.0, 3.0},
                        {1.0, 3.0} };
    mosek.Env.boundkey[]
                 bkc    = {mosek.Env.boundkey.fx,
                           mosek.Env.boundkey.lo,
                           mosek.Env.boundkey.up};
    double  blc[]  = {30.0,
                      15.0,
                      -infinity};
    double  buc[]  = {30.0,
                      +infinity,
                      25.0};
    mosek.Env.boundkey
            bkx[]  = {mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.ra,
                      mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo};
    double  blx[]  = {0.0,
                      0.0,
                      0.0,
                      0.0};
    double  bux[]  = {+infinity,
                      10.0,
                      +infinity,
                      +infinity};
    double[] xx  = new double[NUMVAR];

    mosek.Env
         env = null;
    mosek.Task
         task = null;
        
    try
      {
      // Make mosek environment. 
      env  = new mosek.Env ();
      // Direct the env log stream to the user specified
      // method env_msg_obj.stream
      msgclass env_msg_obj = new msgclass ();
      env.set_Stream (mosek.Env.streamtype.log, env_msg_obj);
      // Initialize the environment.
      env.init ();

      // Create a task object linked with the environment env.
      task = new mosek.Task (env, 0, 0);
      // Directs the log task stream to the user specified
      // method task_msg_obj.stream
      msgclass task_msg_obj = new msgclass ();
      task.set_Stream (mosek.Env.streamtype.log, task_msg_obj);
      
      /* Give MOSEK an estimate of the size of the input data. 
     This is done to increase the speed of inputting data. 
     However, it is optional. */
      task.putmaxnumvar(NUMVAR);
      task.putmaxnumcon(NUMCON);
      task.putmaxnumanz(NUMANZ);
      /* Append 'NUMCON' empty constraints.
     The constraints will initially have no bounds. */
      task.append(mosek.Env.accmode.con,NUMCON);
      
      /* Append 'NUMVAR' variables.
     The variables will initially be fixed at zero (x=0). */
      task.append(mosek.Env.accmode.var,NUMVAR);

        /* Optionally add a constant term to the objective. */
      task.putcfix(0.0);
        
      for(int j=0; j<NUMVAR; ++j)
      {
        /* Set the linear term c_j in the objective.*/  
        task.putcj(j,c[j]);
        /* Set the bounds on variable j.
           blx[j] <= x_j <= bux[j] */
        task.putbound(mosek.Env.accmode.var,j,bkx[j],blx[j],bux[j]);
        /* Input column j of A */   
        task.putavec(mosek.Env.accmode.var, /* Input columns of A.*/
                     j,                     /* Variable (column) index.*/
                     asub[j],               /* Row index of non-zeros in column j.*/
                     aval[j]);              /* Non-zero Values of column j. */
      }
      /* Set the bounds on constraints.
       for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
      for(int i=0; i<NUMCON; ++i)
        task.putbound(mosek.Env.accmode.con,i,bkc[i],blc[i],buc[i]);

      /* A maximization problem */ 
      task.putobjsense(mosek.Env.objsense.maximize);

      /* Solve the problem */
      mosek.Env.rescode r = task.optimize();
                
      // Print a summary containing information
      //   about the solution for debugging purposes
      task.solutionsummary(mosek.Env.streamtype.msg);
      
      mosek.Env.solsta solsta[] = new mosek.Env.solsta[1];
      mosek.Env.prosta prosta[] = new mosek.Env.prosta[1];
      /* Get status information about the solution */ 
      task.getsolutionstatus(mosek.Env.soltype.bas,
                             prosta,
                             solsta);
      task.getsolutionslice(mosek.Env.soltype.bas, // Basic solution.     
                            mosek.Env.solitem.xx,  // Which part of solution.
                            0,      // Index of first variable.
                            NUMVAR, // Index of last variable+1 
                            xx);
      switch(solsta[0])
      {
      case optimal:
      case near_optimal:
        System.out.println("Optimal primal solution\n");
        for(int j = 0; j < NUMVAR; ++j)
          System.out.println ("x[" + j + "]:" + xx[j]);
        break;
      case dual_infeas_cer:
      case prim_infeas_cer:
      case near_dual_infeas_cer:
      case near_prim_infeas_cer:  
        System.out.println("Primal or dual infeasibility.\n");
        break;
      case unknown:
        System.out.println("Unknown solution status.\n");
        break;
      default:
        System.out.println("Other solution status");
        break;
      }
    }
    catch (Exception e)
    {
      System.out.println ("An error/warning was encountered");
      System.out.println (e.toString());
    }
    if (task != null) task.dispose ();
    if (env  != null)  env.dispose ();
  }
}
