/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File     :  solvelinear.c
 
  Purpose  :  To demonstrate the usage of MSK_solvewithbasis
              when solving the linear system:
               
  1.0  x1             = b1
  -1.0  x0  +  1.0  x1 = b2

  with two different right hand sides

  b = (1.0, -2.0)

  and

  b = (7.0, 0.0)
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

public class solvelinear
{


  
static public void put_a(mosek.Task task,
                  double[][] aval,
                  int[][] asub,
                  int[] ptrb,
                  int[] ptre,
                  int numvar,
                  int[] basis
                  )
  {
    // Since the value infinity is never used, we define
    // 'infinity' symbolic purposes only
    double
      infinity = 0;

    
    mosek.stakey[] skx = new mosek.stakey [numvar];
    mosek.stakey[] skc = new mosek.stakey [numvar];
    
    for (int i=0;i<numvar ;++i)
    {
      skx[i] = mosek.stakey.bas;
      skc[i] = mosek.stakey.fix;
    }
    
    task.append(mosek.accmode.var,numvar);
    task.append(mosek.accmode.con,numvar);
    
    for (int i=0;i<numvar ;++i)
      task.putavec(mosek.accmode.var,
                   i,
                   asub[i],
                   aval[i]);

    for (int i=0 ; i<numvar ;++i)
      task.putbound(mosek.accmode.con,
                    i,
                    mosek.boundkey.fx,
                    0.0,
                    0.0);

    for (int i=0 ; i<numvar ;++i)
      task.putbound(mosek.accmode.var,
                    i,
                    mosek.boundkey.fr,
                    -infinity,
                    infinity);

    task.makesolutionstatusunknown(mosek.soltype.bas);
    

    /* Define a basic solution by specifying
       status keys for variables & constraints. */ 

    for (int i=0 ; i<numvar ;++i)
      task.putsolutioni (
                         mosek.accmode.var,
                         i,  
                         mosek.soltype.bas, 
                         skx[i],     
                         0.0,
                         0.0,
                         0.0,
                         0.0);
    
    for (int i=0 ; i<numvar ;++i)
      task.putsolutioni (
                         mosek.accmode.con,
                         i,
                         mosek.soltype.bas,       
                         skc[i], 
                         0.0,
                         0.0,
                         0.0,
                         0.0);
    
    
    
    task.initbasissolve(basis);    
  }
  
public static void Main ()
  {
    const int NUMCON = 2;
    const int NUMVAR = 2;


    int   numvar = 2;
    int   numcon = 2;   /* we must have numvar == numcon */

    double[][]
      aval   = new double[NUMVAR][];
    
    aval[0] = new double[] {-1.0 };
    aval[1] = new double[] {1.0, 1.0};


    int[][]
      asub = new int[NUMVAR][];

    asub[0] = new int[] {1};
    asub[1] = new int[] {0,1};
        
    int []      ptrb  = {0,1};
    int []      ptre  = {1,3};

    int[]       bsub  = new int[numvar];
    double[]    b     = new double[numvar];
    int[]       basis = new int[numvar];
    
    mosek.Task 
      task = null;
    mosek.Env  
      env  = null;
        

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


      /* Put A matrix and factor A.
         Call this function only once for a given task. */ 

      put_a(
            task,
            aval,
            asub,
            ptrb,
            ptre,
            numvar,
            basis
            );

      /* now solve rhs */
      b[0] = 1;
      b[1] = -2;
      bsub[0] = 0;
      bsub[1] = 1;
      int nz = 2;
  
      task.solvewithbasis(0,ref nz,bsub,b);
      Console.WriteLine ("\nSolution to Bx = b:\n\n");
      
      /* Print solution and show correspondents
         to original variables in the problem */
      for (int i=0;i<nz;++i) 
      {    
        if (basis[bsub[i]] < numcon)
          Console.WriteLine ("This should never happen\n");
        else   
          Console.WriteLine ("x{0} = {1}\n",basis[bsub[i]] - numcon , b[bsub[i]] );   
      }
      
      b[0] = 7;
      bsub[0] = 0;
      nz = 1;
  
      task.solvewithbasis(0,ref nz,bsub,b);
      
      Console.WriteLine ("\nSolution to Bx = b:\n\n");
      /* Print solution and show correspondents
         to original variables in the problem */
      for (int i=0;i<nz;++i) 
      {    
        if (basis[bsub[i]] < numcon)
          Console.WriteLine ("This should never happen\n");
        else   
          Console.WriteLine ("x{0} = {1}\n",basis[bsub[i]] - numcon , b[bsub[i]] );   
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
