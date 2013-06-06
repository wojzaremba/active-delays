package concurrent2;

/*
 * Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
 *
 * File:      concurrent2.java
 *
 * Purpose:   To demonstrate a more flexible interface for concurrent optimization. 
*/

import mosek.*;


class msgclass extends mosek.Stream {
    String prefix;
    public msgclass (String prfx)
    {
      super ();
      prefix = prfx;
    }

    public void stream (String msg)
    {
      System.out.print (prefix + msg);
    }
}

public class concurrent2
{
  
    public static void main (String[] args)
    {
      mosek.Env
          env = null;
      mosek.Task
          task = null;
      mosek.Task[]
          task_list = { null } ;
        
      try
      {
        // Create mosek environment. 
        env  = new mosek.Env ();
        // Direct the env log stream to the user specified
        // method env_msg_obj.print
        msgclass env_msg_obj = new msgclass ("[env]");
        if (false)
          env.set_Stream (mosek.Env.streamtype.log,env_msg_obj);
        // Initialize the environment.
        env.init ();

        // Create a task object linked with the environment env.
        task = new mosek.Task (env, 0, 0);
        task_list[0] = new mosek.Task (env, 0, 0);
        // Directs the log task stream to the user specified
        // method task_msg_obj.print
        task.set_Stream ( mosek.Env.streamtype.log,new msgclass ("simplex: "));
        task_list[0].set_Stream ( mosek.Env.streamtype.log,new msgclass ("intrpnt: "));

        task.readdata(args[0]);
        
        // Assign different parameter values to each task. 
        // In this case different optimizers. 
        task.putintparam(mosek.Env.iparam.optimizer,
                         mosek.Env.optimizertype.primal_simplex.value);
        
        task_list[0].putintparam(mosek.Env.iparam.optimizer,
                                 mosek.Env.optimizertype.intpnt.value);
        
        
        // Optimize task and task_list[0] in parallel.
        // The problem data i.e. C, A, etc. 
        // is copied from task to task_list[0].
        task.optimizeconcurrent(task_list);
          
        task.solutionsummary(mosek.Env.streamtype.log);
      }
      catch (mosek.Exception e)
        // Catch both mosek.Error and mosek.Warning 
      {
        System.out.println ("An error or warning was encountered");
        System.out.println (e.getMessage ());
      }
      catch (mosek.ArrayLengthException e)
        // Catch both mosek.Error and mosek.Warning 
      {
        System.out.println ("An error or warning was encountered");
        System.out.println (e.getMessage ());
      }
        
      // We make sure to dispose of all tasks we created
      if (task != null) task.dispose ();
      if (task_list[0] != null) task_list[0].dispose ();
      if (env  != null)  env.dispose ();
    }
}
