package cqo1;

/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      cqo1.java

   Purpose:   Demonstrates how to solve a small conic qaudratic
              optimization problem using the MOSEK API.
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
  
public class cqo1
{
  static final int NUMCON = 1;
  static final int NUMVAR = 6;
  static final int NUMANZ = 4;
  
  public static void main (String[] args) throws java.lang.Exception
  {
    // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
    double infinity = 0;
    
    mosek.Env.boundkey[] bkc    = { mosek.Env.boundkey.fx };
    double[] blc = { 1.0 };
    double[] buc = { 1.0 };
    
    mosek.Env.boundkey[] bkx
              = {mosek.Env.boundkey.lo,
                 mosek.Env.boundkey.lo,
                 mosek.Env.boundkey.lo,
                 mosek.Env.boundkey.lo,
                 mosek.Env.boundkey.fr,
                 mosek.Env.boundkey.fr};
     double[] blx = { 0.0,
                      0.0,
                      0.0,
                      0.0,
                      -infinity,
                      -infinity};
     double[] bux = { 0.0,
                      0.0,
                      0.0,
                      0.0,
                      +infinity,
                      +infinity};
                          
     double[] c   = { 0.0,
                      0.0,
                      0.0,
                      0.0,
                      1.0,
                      1.0};
        
     double[][] aval   = {{1.0},
                         {1.0},
                         {1.0},
                         {1.0}};
     int[][]    asub   = {{0},
                         {0},
                         {0},
                         {0}};
        
     int[] csub = new int[3];
     double[] xx  = new double[NUMVAR];
     mosek.Env
         env = null;
     mosek.Task
         task = null;

     // create a new environment object
     env  = new mosek.Env ();
     try
       {
       // Direct the env log stream to the user specified
       // method env_msg_obj.stream
       msgclass env_msg_obj = new msgclass ();
       env.set_Stream (mosek.Env.streamtype.log, env_msg_obj);
       env.init ();
       // create a task object attached to the environment
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
       }
       
       for(int j=0; j<aval.length; ++j)
         /* Input column j of A */   
         task.putavec(mosek.Env.accmode.var, /* Input columns of A.*/
                      j,                     /* Variable (column) index.*/
                      asub[j],               /* Row index of non-zeros in column j.*/
                      aval[j]);              /* Non-zero Values of column j. */

       /* Set the bounds on constraints.
       for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
       for(int i=0; i<NUMCON; ++i)
         task.putbound(mosek.Env.accmode.con,i,bkc[i],blc[i],buc[i]);

       csub[0] = 4;
       csub[1] = 0;
       csub[2] = 2;
       task.appendcone(mosek.Env.conetype.quad,
                       0.0, /* For future use only, can be set to 0.0 */
                       csub);
       csub[0] = 5;
       csub[1] = 1;
       csub[2] = 3;
       task.appendcone(mosek.Env.conetype.quad,0.0,csub);

       System.out.println ("putintparam");
       task.putobjsense(mosek.Env.objsense.minimize);
       
       System.out.println ("optimize");
       /* Solve the problem */
       mosek.Env.rescode r = task.optimize();
       System.out.println (" Mosek warning:" + r.toString());
       // Print a summary containing information
       //   about the solution for debugging purposes
       task.solutionsummary(mosek.Env.streamtype.msg);
                
       mosek.Env.solsta solsta[] = new mosek.Env.solsta[1];
       mosek.Env.prosta prosta[] = new mosek.Env.prosta[1];
                /* Get status information about the solution */ 
       task.getsolutionstatus(mosek.Env.soltype.itr,
                              prosta,
                              solsta);
       task.getsolutionslice(mosek.Env.soltype.itr, // Interior solution.     
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
       throw (e);
     }
     
     if (task != null) task.dispose ();
     if (env  != null)  env.dispose ();
  }
}
