/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      concurrent1.cs

   Purpose:   To demonstrate how to solve a problem 
              with the concurrent optimizer. 
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

public class concurrent1
{
  
  public static void Main (String[] args)
    {
      mosek.Env
        env = null;
      mosek.Task
        task = null;
      
      try
        {
          // Create mosek environment. 
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
            
          task.readdata(args[0]);
          task.putintparam(mosek.iparam.optimizer,
                           mosek.Val.optimizer_concurrent);
          task.putintparam(mosek.iparam.concurrent_num_optimizers,
                           2);
            
          task.optimize();
            
          task.solutionsummary(mosek.streamtype.msg);
       
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

 

