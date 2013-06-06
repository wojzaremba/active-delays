/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    network1.java

  Demonstrates a simple use of the network optimizer.

   Purpose: 1. Specify data for a network.
            2. Solve the network problem with the network optimizer.
*/

package network1;


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

public class network1
{
  static final int NUMCON = 4;
  static final int NUMVAR = 6;

  public static void main (String[] args)
  {
    double
        infinity = 0;

    double cc[]    = {0.0, 0.0, 0.0, 0.0};

    double cx[]    = {1.0, 0.0, 1.0, 0.0, -1.0, 1.0};

    mosek.Env.boundkey bkc[]  
                   = {mosek.Env.boundkey.fx,
                      mosek.Env.boundkey.fx,
                      mosek.Env.boundkey.fx,
                      mosek.Env.boundkey.fx};

    double  blc[]  = {1.0,
                      1.0,
                      -2.0,
                      0.0};

    double  buc[]  = {1.0,
                      1.0,
                      -2.0,
                      0.0};

    mosek.Env.boundkey bkx[]  
                   = {mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo,
                      mosek.Env.boundkey.lo};

    double  blx[]  = {0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0};

    double  bux[]  = {+infinity,
                      +infinity,
                      +infinity,
                      +infinity,
                      +infinity,
                      +infinity};

    int  from[]  = {0,
                    2,
                    3,
                    1,
                    1,
                    1};

    int  to[]  = {2,
                  3,
                  1,
                  0,
                  2,
                  2};

    // Specify solution data
    double[] xc   = new double[NUMCON];
    double[] xx   = new double[NUMVAR];
    double[] y    = new double[NUMCON];
    double[] slc  = new double[NUMCON];
    double[] suc  = new double[NUMCON];
    double[] slx  = new double[NUMVAR];
    double[] sux  = new double[NUMVAR];

    mosek.Env.stakey[] skc  = new mosek.Env.stakey[NUMCON]; 
    mosek.Env.stakey[] skx  = new mosek.Env.stakey[NUMVAR];
    for (int i = 0; i < NUMCON; ++i) skc[i] = mosek.Env.stakey.unk;
    for (int i = 0; i < NUMVAR; ++i) skx[i] = mosek.Env.stakey.unk;

    mosek.Env
        env = null;
    mosek.Task
        dummytask = null;

    mosek.Env.solsta[]
        solsta    = new mosek.Env.solsta[1];

    mosek.Env.prosta[]    
        prosta    = new mosek.Env.prosta[1];

    try
    {
      // Make mosek environment. 
      env  = new mosek.Env ();

      // Direct the env log stream to the user specified
      // method env_msg_obj.print
      msgclass env_msg_obj = new msgclass ();

      env.set_Stream (mosek.Env.streamtype.log,env_msg_obj);
      // Initialize the environment.
      env.init ();

      // Create a task object linked with the environment env.
      dummytask = new mosek.Task (env, NUMCON, NUMVAR);

      // Directs the log task stream to the user specified
      // method task_msg_obj.print
      msgclass task_msg_obj = new msgclass ();
      dummytask.set_Stream (mosek.Env.streamtype.log,task_msg_obj);
      
      // Set the problem to be maximized
      dummytask.putobjsense(mosek.Env.objsense.maximize);
      
      // Solve the network problem
      dummytask.netoptimize(cc,
                            cx,
                            bkc,
                            blc,
                            buc,
                            bkx,
                            blx,
                            bux,
                            from,
                            to,
                            prosta,
                            solsta,
                            false,
                            skc,
                            skx,
                            xc,
                            xx,
                            y,
                            slc,
                            suc,
                            slx,
                            sux);

      switch (solsta[0])
      {
        case optimal:
          System.out.println("Embedded network problem is optimal");
          break;
        case prim_infeas_cer:
          System.out.println("Embedded network problem is primal infeasible");
          break;
        case dual_infeas_cer:
          System.out.println("Embedded network problem is dual infeasible");
          break;
        default:
          System.out.println("Embedded network problem solsta : " + solsta[0]);
          break;
      }
    }
    catch (Exception e)
    /* Catch both mosek.Error and mosek.Warning */
    {
        System.out.println ("An error or warning was encountered");
        System.out.println (e.getMessage ());
    }
  
    // Dispose of task end environment
    if (dummytask != null) dummytask.dispose ();
    if (env  != null)  env.dispose ();
  }
}
