/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      production.cs

   Purpose:   Demonstrates how to solve a  linear
              optimization problem using the MOSEK API
              and and modify and re-optimize the problem.
*/


using System;
 
public class production
{  
    public static void Main ()
    {
        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double  
          infinity = 0;

        const int NUMCON = 3;
        const int NUMVAR = 3;
        const int NUMANZ = 9;

        double[] c            = {1.5,
                                 2.5,
                                 3.0};
        mosek.boundkey[] bkc  = {mosek.boundkey.up,
                                 mosek.boundkey.up,
                                 mosek.boundkey.up};
        double[] blc          = {-infinity,
                                 -infinity,
                                 -infinity};
        double[] buc          =  {100000,
                                  50000,
                                  60000};
        mosek.boundkey[] bkx  = {mosek.boundkey.lo,
                                  mosek.boundkey.lo,
                                  mosek.boundkey.lo};
        double[] blx           = {0.0,
                                  0.0,
                                  0.0};
        double[] bux           = {+infinity,
                                  +infinity,
                                  +infinity};
        
        int[][] asub = new int[NUMVAR][];
        asub[0] = new int[] {0, 1, 2};
        asub[1] = new int[] {0, 1, 2};
        asub[2] = new int[] {0, 1, 2};

        double[][] aval   = new double[NUMVAR][];
        aval[0] = new double[] { 2.0, 3.0, 2.0 };
        aval[1] = new double[] { 4.0, 2.0, 3.0 };
        aval[2] = new double[] { 3.0, 3.0, 2.0 };

        double[] xx  = new double[NUMVAR];
        
        mosek.Task task = null;
        mosek.Env  env  = null;
        
        try
          {
            // Create mosek environment. 
              env  = new mosek.Env ();
              // Initialize the environment.
              env.init ();
              // Create a task object linked with the environment env.
              task = new mosek.Task (env, NUMCON,NUMVAR);
        

              /* Give MOSEK an estimate on the size of
                 the data to input. This is done to increase
                 the speed of inputting data and is optional.*/
                
              task.putmaxnumvar(NUMVAR); 
              task.putmaxnumcon(NUMCON);      
              task.putmaxnumanz(NUMANZ);

              /* Append the constraints. */
              task.append(mosek.accmode.con,NUMCON);

              /* Append the variables. */
              task.append(mosek.accmode.var,NUMVAR);

              /* Put C. */
              task.putcfix(0.0);
              for(int j=0; j<NUMVAR; ++j)
                  task.putcj(j,c[j]);

              /* Put constraint bounds. */
              for(int i=0; i<NUMCON; ++i)
                  task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i]);

              /* Put variable bounds. */
              for(int j=0; j<NUMVAR; ++j)
                  task.putbound(mosek.accmode.var,j,bkx[j],blx[j],bux[j]);

              /* Put A. */
              if ( NUMCON>0 )
                  {
                      for(int j=0; j<NUMVAR; ++j)
                          task.putavec(mosek.accmode.var,
                                       j,
                                       asub[j],
                                       aval[j]);
                  }

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
            
              task.getsolutionslice(mosek.soltype.bas, /* Basic solution.       */
                                    mosek.solitem.xx,  /* Which part of solution.  */
                                    0,                 /* Index of first variable. */
                                    NUMVAR,            /* Index of last variable+1 */
                                    xx);

              for(int j = 0; j < NUMVAR; ++j)
                  Console.WriteLine ("x[{0}]:{1}", j,xx[j]);

              /* Make a change to the A matrix */
              task.putaij(0, 0, 3.0);
              task.optimize();
              /* Append a new varaible x_3 to the problem */
              task.append(mosek.accmode.var,1);
    
              /* Get index of new variable, this should be 3 */
              int numvar;
              task.getnumvar(out numvar);
    
              /* Set bounds on new varaible */
              task.putbound(mosek.accmode.var,
                            numvar-1,
                            mosek.boundkey.lo,
                            0,       
                            +infinity);
    
              /* Change objective */
              task.putcj(numvar-1,1.0);
    
              /* Put new values in the A matrix */
              int[] acolsub    =  new int[] {0,   2};
              double[] acolval =  new double[] {4.0, 1.0};
      
              task.putavec(mosek.accmode.var,
                           numvar-1, /* column index */
                           acolsub,
                           acolval);
              /* Change optimizer to simplex free and reoptimize */
              task.putintparam(mosek.iparam.optimizer,mosek.optimizertype.free_simplex);
              task.optimize(); 
              /* Append a new constraint */
              task.append(mosek.accmode.con,1);

              /* Get index of new constraint, this should be 4 */
              int numcon; 
              task.getnumcon(out numcon);
    
              /* Set bounds on new constraint */
              task.putbound(
                            mosek.accmode.con,
                            numcon-1,
                            mosek.boundkey.up,
                            -infinity,
                            30000);

              /* Put new values in the A matrix */

              int[] arowsub = new int[] {0,   1,   2,   3  };
              double[] arowval = new double[]  {1.0, 2.0, 1.0, 1.0};
      
              task.putavec(mosek.accmode.con,
                           numcon-1, /* row index */
                           arowsub,
                           arowval); 
 
              task.optimize();
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
