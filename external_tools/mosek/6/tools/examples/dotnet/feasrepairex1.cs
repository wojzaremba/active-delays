     
/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      feasrepairex1.cs

  Purpose:    To demonstrate how to use the MSK_relaxprimal function to
              locate the cause of an infeasibility.

  Syntax: On command line
          feasrepairex1 feasrepair.lp
          feasrepair.lp is located in mosek\<version>\tools\examples.
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

public class feasrepairex1
{
     public static void Main (String[] args)
    {
        const double infinity = 0.0;
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        mosek.Task
            task_relaxprimal = null;
        
        double[] wlc = {1.0,1.0,1.0,1.0};
        double[] wuc = {1.0,1.0,1.0,1.0};
        double[] wlx = {1.0,1.0};
        double[] wux = {1.0,1.0};
        double sum_violation;

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
            task = new mosek.Task (env, 0,0);
            // Directs the log task stream to the user specified
            // method task_msg_obj.streamCB
            task.set_Stream (mosek.streamtype.log, new msgclass ("[task]"));


            /* read file from current dir */
            task.readdata(args[0]);
            task.putintparam(mosek.iparam.feasrepair_optimize,
                             mosek.Val.feasrepair_optimize_penalty);
            Console.WriteLine ("Start relax primal");
            task.relaxprimal(out task_relaxprimal,
                             wlc,
                             wuc,
                             wlx,
                             wux);
            Console.WriteLine ("End relax primal");
            
            task_relaxprimal.getprimalobj(mosek.soltype.bas,out sum_violation);
            Console.WriteLine ("Minimized sum of violations = {0}" , sum_violation);
            
            /* modified bound returned in wlc,wuc,wlx,wux */
            
            for (int i=0;i<4;++i)
            {
              if (wlc[i] == -infinity)
                Console.WriteLine("lbc[{0}] = -inf, ",i);
              else
                Console.WriteLine("lbc[{0}] = {1}, ",i,wlc[i]);
              
              if (wuc[i] == infinity)
                Console.WriteLine("ubc[{0}] = inf\n",i);
              else
                Console.WriteLine("ubc[{0}] = {1}\n",i,wuc[i]);
            }
            
            for (int i=0;i<2;++i)
            {
              if (wlx[i] == -infinity)
                            Console.WriteLine("lbx[{0}] = -inf, ",i);
              else
                Console.WriteLine("lbx[{0}] = {1}, ",i,wlx[i]);
      
              if (wux[i] == infinity)
                            Console.WriteLine("ubx[{0}] = inf\n",i);
              else
                Console.WriteLine("ubx[{0}] = {1}\n",i,wux[i]);
            }
            }
        catch (mosek.Exception e)
            {
                Console.WriteLine (e.Code);
                Console.WriteLine (e);
            }

        if (task != null) task.Dispose ();
        if (task_relaxprimal != null) task_relaxprimal.Dispose ();              
        if (env  != null)  env.Dispose ();

    }   
}
     
