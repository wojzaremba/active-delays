package qcqo1;

/* 
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      qcqo1.java

   Purpose:   Demonstrate how to solve a quadratic
              optimization problem using the MOSEK API.

              minimize  x0^2 + 0.1 x1^2 +  x2^2 - x0 x2 - x1 
              s.t 1 <=  x0 + x1 + x2 - x0^2 - x1^2 - 0.1 x2^2 + 0.2 x0 x2 
              x >= 0              
                       
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

public class qcqo1
{
    static final int NUMCON = 1;   /* Number of constraints.             */
    static final int NUMVAR = 3;   /* Number of variables.               */
    static final int NUMANZ = 3;   /* Number of numzeros in A.           */
    static final int NUMQNZ = 4;   /* Number of nonzeros in Q.           */
    public static void main (String[] args)
    {
      // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
      double infinity = 0;
      double[] c = {0.0, -1.0, 0.0};
      
      mosek.Env.boundkey[]    bkc  = {mosek.Env.boundkey.lo};
      double[] blc = {1.0};
      double[] buc = {infinity};
      
      mosek.Env.boundkey[]  bkx   
                        = {mosek.Env.boundkey.lo,
                          mosek.Env.boundkey.lo,
                          mosek.Env.boundkey.lo};        
      double[] blx = {0.0,
                      0.0,
                      0.0};
      double[] bux = {infinity,
                      infinity,
                      infinity};
        
      int[][]    asub  = { {0},   {0},   {0} };
      double[][] aval  = { {1.0}, {1.0}, {1.0} };

      double[] xx   = new double[NUMVAR];
  
      mosek.Env  
          env = null;
      mosek.Task 
          task = null;
 
      env  = new mosek.Env ();
      try
        {
        // Direct the env log stream to the user specified
        // method env_msg_obj.stream
        msgclass env_msg_obj = new msgclass ();
        env.set_Stream (mosek.Env.streamtype.log, env_msg_obj);
        env.init ();
        
        task = new mosek.Task (env, NUMCON,NUMVAR);
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
        /*
         * The lower triangular part of the Q
         * matrix in the objective is specified.
         */

        int[]   qosubi = { 0,   1,   2,    2 };
        int[]   qosubj = { 0,   1,   0,    2 };
        double[] qoval = { 2.0, 0.2, -1.0, 2.0 };
        
        /* Input the Q for the objective. */

        task.putqobj(qosubi,qosubj,qoval);
        
       /*
        * The lower triangular part of the Q^0
        * matrix in the first constraint is specified.
        * This corresponds to adding the term
        * x0^2 - x1^2 - 0.1 x2^2 + 0.2 x0 x2
        */

        int[]    qsubi = {0,   1,    2,   2  };
        int[]    qsubj = {0,   1,    2,   0  };
        double[] qval =  {-2.0, -2.0, -0.2, 0.2};
        
        /* put Q^0 in constraint with index 0. */
                
        task.putqconk (0,
                       qsubi, 
                       qsubj, 
                       qval); 
        
        task.putobjsense(mosek.Env.objsense.minimize);

        /* Solve the problem */
        
        try
          {
          mosek.Env.rescode termcode = task.optimize();
        }
        catch (mosek.Warning e)
        {
          System.out.println (" Mosek warning:");
          System.out.println (e.toString ());
        }
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
      catch (mosek.ArrayLengthException e)
      /* Catch both Error and Warning */
      {
        System.out.println ("An error/warning was encountered");
        System.out.println (e.toString ());
      }
      catch (mosek.Exception e)
      {
        System.out.println ("An error/warning was encountered");
        System.out.println (e.msg);
      }
      
      if (task != null) task.dispose ();
      if (env  != null)  env.dispose ();
      
    } /* Main */
}
 
