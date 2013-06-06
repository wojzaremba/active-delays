package mioinitsol;

/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      mioinitsol.c

   Purpose:   Demonstrates how to solve a MIP with a start guess.

   Syntax:    mioinitsol mioinitsol.lp 
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
 
public class mioinitsol
{
    public static void main (String[] args)
    {
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        // Since the value infinity is never used, we define
        // 'infinity' symbolic purposes only
        double
            infinity = 0;

        int NUMVAR = 4;
        int NUMCON = 1;
        int NUMINTVAR = 3;

        double[] c = { 7.0, 10.0, 1.0, 5.0 };
        
        mosek.Env.boundkey[] bkc = {mosek.Env.boundkey.up};
        double[] blc = {-infinity};
        double[] buc = {2.5};
        mosek.Env.boundkey[] bkx
                  = {mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo,
                     mosek.Env.boundkey.lo};
        double[] blx = {0.0,
                        0.0,
                        0.0,
                        0.0};
        double[] bux = {infinity,
                        infinity,
                        infinity,
                        infinity};
        
        int[]    ptrb   = {0, 1, 2, 3};
        int[]    ptre   = {1, 2, 3, 4};
        double[] aval   = {1.0, 1.0, 1.0, 1.0};
        int[]    asub   = {0,   0,   0,   0  };
        int[]    intsub = {0, 1, 2};
        int j;
  
        try{
            // Make mosek environment. 
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

            task.inputdata(NUMCON,NUMVAR,
                           c,
                           0.0,
                           ptrb,
                           ptre,
                           asub,
                           aval,
                           bkc,
                           blc,
                           buc,
                           bkx,
                           blx,
                           bux);
                            
            for(j=0 ; j<NUMINTVAR ; ++j)
               task.putvartype(intsub[j],mosek.Env.variabletype.type_int);

            /* A maximization problem */ 
            task.putobjsense(mosek.Env.objsense.maximize);
                
            // Construct an initial feasible solution from the
            //     values of the integer valuse specified 
            task.putintparam(mosek.Env.iparam.mio_construct_sol,
                             mosek.Env.onoffkey.on.value);
        
            // Set status of all variables to unknown 
            task.makesolutionstatusunknown(mosek.Env.soltype.itg);
        
            // Assign values 1,1,0 to integer variables 
            task.putsolutioni (
                               mosek.Env.accmode.var,
                               0,
                               mosek.Env.soltype.itg, 
                               mosek.Env.stakey.supbas, 
                               0.0,
                               0.0,
                               0.0,
                               0.0);
        
            task.putsolutioni (
                               mosek.Env.accmode.var,
                               1,
                               mosek.Env.soltype.itg, 
                               mosek.Env.stakey.supbas, 
                               2.0,
                               0.0,
                               0.0,
                               0.0);
        
        
            task.putsolutioni (
                               mosek.Env.accmode.var,
                               2,
                               mosek.Env.soltype.itg, 
                               mosek.Env.stakey.supbas, 
                               0.0,
                               0.0,
                               0.0,
                               0.0);
        
            // solve   
            task.optimize(); 
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
