/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      concurrent1.java

   Purpose:   To demonstrate how to solve a problem 
              with the concurrent optimizer. 
 */

package concurrent1;

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

public class concurrent1
{
    public static void main (String[] args)
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
                // method env_msg_obj.print
                msgclass env_msg_obj = new msgclass ();
                env.set_Stream (mosek.Env.streamtype.log,env_msg_obj);
                // Initialize the environment.
                env.init ();
                // Create a task object linked with the environment env.
                task = new mosek.Task (env, 0, 0);
                // Directs the log task stream to the user specified
                // method task_msg_obj.print
                msgclass task_msg_obj = new msgclass ();
                task.set_Stream (mosek.Env.streamtype.log,task_msg_obj);
                task.readdata(args[0]);
                task.putintparam(mosek.Env.iparam.optimizer,
                                 mosek.Env.optimizertype.concurrent.value);
                task.putintparam(mosek.Env.iparam.concurrent_num_optimizers,
                                 2);

                task.optimize();

                task.solutionsummary(mosek.Env.streamtype.msg);
                System.out.println ("Done.");
            }
        catch (mosek.Exception e)
            /* Catch both mosek.Error and mosek.Warning */
            {
                System.out.println ("An error or warning was encountered");
                System.out.println (e.getMessage ());
            }
        
        if (task != null) task.dispose ();
        if (env  != null)  env.dispose ();
    }
}

