package feasrepairex1;
     
/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:      feasrepairex1.java

  Purpose:    To demonstrate how to use the MSK_relaxprimal function to
              locate the cause of an infeasibility.

  Syntax: On command line
          java  feasrepairex1.feasrepairex1 feasrepair.lp
          feasrepair.lp is located in mosek\<version>\tools\examples.
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


public class feasrepairex1
{

    public static void main (String[] args)
    {
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        mosek.TaskContainer
            task_relaxprimal_container = new mosek.TaskContainer();
        mosek.Task
            task_relaxprimal = null;
        
        double[] wlc = {1.0,1.0,1.0,1.0};
        double[] wuc = {1.0,1.0,1.0,1.0};
        double[] wlx = {1.0,1.0};
        double[] wux = {1.0,1.0};
        double[] sum_violation = new double[1];
        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double
            infinity = 0;

        try
            {
                // Make mosek environment. 
                env  = new mosek.Env ();
                // Direct the env log stream to the user specified
                // method env_msg_obj.print
                msgclass env_msg_obj = new msgclass ();
                env.set_Stream ( mosek.Env.streamtype.log,env_msg_obj);
                // Initialize the environment.
                env.init ();
                // Create a task object linked with the environment env.
                task = new mosek.Task (env, 0, 0);
                // Directs the log task stream to the user specified
                // method task_msg_obj.print
                msgclass task_msg_obj = new msgclass ();
                task.set_Stream (mosek.Env.streamtype.log,task_msg_obj);
                 /* read file from current dir */
                task.readdata(args[0]);
                task.putintparam(mosek.Env.iparam.feasrepair_optimize,
                                 mosek.Env.feasrepairtype.optimize_penalty.value);
                System.out.println ("Start relax primal");
                task_relaxprimal = task.relaxprimal(wlc,
                                                    wuc,
                                                    wlx,
                                                    wux);
                System.out.println ("End relax primal");
                task_relaxprimal.getprimalobj(mosek.Env.soltype.bas,
                                              sum_violation);
                System.out.println ("Minimized sum of violations = "
                                    + sum_violation[0]);
    
                /* modified bound returned in wlc,wuc,wlx,wux */

                for (int i=0;i<4;++i)
                    {
                        if (wlc[i] == -infinity)
                            System.out.println("lbc[" + i + "] = -inf, ");
                        else
                            System.out.println("lbc[" + i + "] = " + wlc[i]);
      
                        if (wuc[i] == infinity)
                            System.out.println("ubc[" + i + "] = inf");
                        else
                            System.out.println("ubc[" + i + "] = " + wuc[i]);
                    }

                for (int i=0;i<2;++i)
                    {
                        if (wlx[i] == -infinity)
                            System.out.println("lbx[" + i + "] = -inf");
                        else
                            System.out.println("lbx[" + i + "] = " + wlx[i]);
      
                        if (wux[i] == infinity)
                            System.out.println("ubx[" + i + "] = inf");
                        else
                            System.out.println("ubx[" + i + "] = " + wux[i]);
                    }
            }
        catch (mosek.ArrayLengthException e)
            {
                System.out.println ("Error: An array was too short");
                System.out.println (e.toString ());
            }
        catch (mosek.Exception e)
            /* Catch both mosek.Error and mosek.Warning */
            {
                System.out.println ("An error or warning was encountered");
                System.out.println (e.getMessage ());
            }
        
        if (task != null) task.dispose ();
        if (task_relaxprimal != null) task_relaxprimal.dispose ();
        if (env  != null)  env.dispose ();
    }   
}
    
