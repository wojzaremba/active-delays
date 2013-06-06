/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    simple.java

  Purpose: Demonstrates a very simple example using MOSEK by
  reading a problem file, solving the problem and
  writing the solution to a file.
*/

package simple;

import mosek.*;

public class simple
{
    public static void main (String[] args)
    {
      if (args.length == 0)
      {
        System.out.println ("Missing argument. The syntax is:");
        System.out.println (" simple inputfile [ solutionfile ]");
      }
      else
      {
        mosek.Env
            env = null;
        mosek.Task
            task = null;
        try
        {
          // Make mosek environment. 

          env  = new mosek.Env ();
          // Initialize the environment.

          env.init ();

          // Create a task object linked with the environment env.
          //  We create it initially with 0 variables and 0 columns, 
          //  since we don't know the size of the problem.
          task = new mosek.Task (env, 0,0);

          // We assume that a problem file was given as the first command
          // line argument (received in `args')
          task.readdata (args[0]);

          // Solve the problem
          task.optimize();

          // Print a summary of the solution
          task.solutionsummary(mosek.Env.streamtype.log);
        
          // If an output file was specified, write a solution
          if (args.length > 1)
          {
            // We define the output format to be OPF, and tell MOSEK to
            // leave out parameters and problem data from the output file.
            task.putintparam (mosek.Env.iparam.write_data_format,
                              mosek.Env.dataformat.op.value);
            task.putintparam (mosek.Env.iparam.opf_write_solutions,
                              mosek.Env.onoffkey.on.value);
            task.putintparam (mosek.Env.iparam.opf_write_hints,
                              mosek.Env.onoffkey.off.value);
            task.putintparam (mosek.Env.iparam.opf_write_parameters,
                              mosek.Env.onoffkey.off.value);
            task.putintparam (mosek.Env.iparam.opf_write_problem,
                              mosek.Env.onoffkey.off.value);
            task.writedata(args[1]);
          }
        }
        catch (mosek.Exception e)
          /* Catch both mosek.Error and mosek.Warning */
        {
          System.out.println ("An error or warning was encountered");
          System.out.println (e.getMessage ());
        }

      
        // Dispose of task end environment
        if (task != null) task.dispose ();
        if (env  != null)  env.dispose ();
      }
    }
}
