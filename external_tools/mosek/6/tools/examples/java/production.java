package production;

/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      production.cs

   Purpose:   Demonstrates how to solve a  linear
              optimization problem using the MOSEK API
              and and modify and re-optimize the problem.
*/


import mosek.*;

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
 
public class production
{
    static final int NUMCON = 3;
    static final int NUMVAR = 3;
    static final int NUMANZ = 9;

    public static void main (String[] args)
    {

        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double  
          infinity = 0;
        
        double c[]            = {1.5,
                                 2.5,
                                 3.0};
        mosek.Env.boundkey bkc[] 
                              = {mosek.Env.boundkey.up,
                                 mosek.Env.boundkey.up,
                                 mosek.Env.boundkey.up};
        double blc[]          = {-infinity,
                                 -infinity,
                                 -infinity};
        double buc[]          =  {100000,
                                  50000,
                                  60000};
        mosek.Env.boundkey bkx[]
                              = {mosek.Env.boundkey.lo,
                                  mosek.Env.boundkey.lo,
                                  mosek.Env.boundkey.lo};
        double blx[]          = {0.0,
                                  0.0,
                                  0.0};
        double bux[]           = {+infinity,
                                  +infinity,
                                  +infinity};
        
        int asub[][] = {{0, 1, 2},
                        {0, 1, 2},
                        {0, 1, 2}};

        double aval[][]   = { { 2.0, 3.0, 2.0 },
                              { 4.0, 2.0, 3.0 },
                              { 3.0, 3.0, 2.0 } };
                       
        double[] xx  = new double[NUMVAR];

        mosek.Env
            env = null;
        mosek.Task
            task = null;
        
        try
            {
                // Create mosek environment. 
                env  = new mosek.Env ();
                // Initialize the environment.
                env.init ();
                // Create a task object linked with the environment env.
                task = new mosek.Task (env, NUMCON, NUMVAR);
              
                /* Give MOSEK an estimate on the size of
                   the data to input. This is done to increase
                   the speed of inputting data and is optional.*/
                
                task.putmaxnumvar(NUMVAR);
                task.putmaxnumcon(NUMCON);
                task.putmaxnumanz(NUMANZ);
                                    
                /* Append the constraints. */
                task.append(mosek.Env.accmode.con,NUMCON);

                /* Append the variables. */
                task.append(mosek.Env.accmode.var,NUMVAR);

                /* Put C. */
                task.putcfix(0.0);
                for(int j=0; j<NUMVAR; ++j)
                  task.putcj(j,c[j]);

                /* Put constraint bounds. */
                for(int i=0; i<NUMCON; ++i)
                  task.putbound(mosek.Env.accmode.con,i,bkc[i],blc[i],buc[i]);

                /* Put variable bounds. */
                for(int j=0; j<NUMVAR; ++j)
                  task.putbound(mosek.Env.accmode.var,j,bkx[j],blx[j],bux[j]);

                /* Put A. */
                if ( NUMCON>0 )
                {
                  for(int j=0; j<NUMVAR; ++j)
                    task.putavec(mosek.Env.accmode.var,
                                 j,
                                 asub[j],
                                 aval[j]);
                }

                /* A maximization problem */ 
                task.putobjsense(mosek.Env.objsense.maximize);
                mosek.Env.rescode termcode;
                /* Solve the problem */
                try
                    {
                        termcode = task.optimize();
                    }
                catch (mosek.Warning e)
                    {
                        System.out.println ("Mosek warning:");
                        System.out.println (e.toString ());
                    }

                task.solutionsummary(mosek.Env.streamtype.msg);

                task.getsolutionslice(mosek.Env.soltype.bas,
                                      /* Basic solution.       */
                                      mosek.Env.solitem.xx,
                                      /* Which part of solution.  */
                                      0,
                                      /* Index of first variable. */
                                      NUMVAR,
                                      /* Index of last variable+1 */
                                      xx);

                for(int j = 0; j < NUMVAR; ++j)
                    System.out.println ("x[" + j + "]:" + xx[j]);
              /* Make a change to the A matrix */
              task.putaij(0, 0, 3.0);
              termcode = task.optimize();
              /* Append a new varaible x_3 to the problem */
              task.append(mosek.Env.accmode.var,1);
    
              /* Get index of new variable, this should be 3 */
              int[] numvar = new int[1];
              task.getnumvar(numvar);
    
              /* Set bounds on new varaible */
              task.putbound(mosek.Env.accmode.var,
                            numvar[0]-1,
                            mosek.Env.boundkey.lo,
                            0,       
                            +infinity);
    
              /* Change objective */
              task.putcj(numvar[0]-1,1.0);
    
              /* Put new values in the A matrix */
              int[] acolsub    =  new int[] {0,   2};
              double[] acolval =  new double[] {4.0, 1.0};
      
              task.putavec(mosek.Env.accmode.var,
                           numvar[0]-1, /* column index */
                           acolsub,
                           acolval);
              /* Change optimizer to simplex free and reoptimize */
              task.putintparam(mosek.Env.iparam.optimizer,mosek.Env.optimizertype.free_simplex.value);
              termcode = task.optimize(); 
              /* Append a new constraint */
              task.append(mosek.Env.accmode.con,1);

              /* Get index of new constraint, this should be 4 */
              int[] numcon = new int[1];
              task.getnumcon(numcon);
    
              /* Set bounds on new constraint */
              task.putbound(
                            mosek.Env.accmode.con,
                            numcon[0]-1,
                            mosek.Env.boundkey.up,
                            -infinity,
                            30000);

              /* Put new values in the A matrix */

              int[] arowsub = new int[] {0,   1,   2,   3  };
              double[] arowval = new double[]  {1.0, 2.0, 1.0, 1.0};
      
              task.putavec(mosek.Env.accmode.con,
                           numcon[0]-1, /* row index */
                           arowsub,
                           arowval); 
 
              termcode = task.optimize();
            }
        catch (mosek.ArrayLengthException e)
            {
                System.out.println ("Error: An array was too short");
                System.out.println (e.toString ());
            }
        catch (mosek.Exception e)
            /* Catch both Error and Warning */
            {
                System.out.println ("An error was encountered");
                System.out.println (e.getMessage ());
            }

        if (task != null) task.dispose ();
        if (env  != null)  env.dispose ();
    }
}
