/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    simple.cs

  Purpose: Demonstrates a very simple example using MOSEK by
  reading a problem file, solving the problem and
  writing the solution to a file.
*/

using System;

public class simple
{
  
  public static void Main (string[] args)
  {
    mosek.Task task = null;
    mosek.Env  env  = null;

    if (args.Length == 0)
    {
      Console.WriteLine ("Missing argument. The syntax is:");
      Console.WriteLine (" simple inputfile [ solutionfile ]");
    }
    else
    {
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
        task.solutionsummary(mosek.streamtype.log);
        
        // If an output file was specified, write a solution
        if (args.Length > 1)
        {
          // We define the output format to be OPF, and tell MOSEK to
          // leave out parameters and problem data from the output file.
          task.putintparam (mosek.iparam.write_data_format,    mosek.dataformat.op);
          task.putintparam (mosek.iparam.opf_write_solutions,  mosek.onoffkey.on);
          task.putintparam (mosek.iparam.opf_write_hints,      mosek.onoffkey.off);
          task.putintparam (mosek.iparam.opf_write_parameters, mosek.onoffkey.off);
          task.putintparam (mosek.iparam.opf_write_problem,    mosek.onoffkey.off);
          
          task.writedata(args[1]);
        }
      }
      finally
      {
        // Dispose of task end environment
        if (task != null) task.Dispose ();
        if (env  != null)  env.Dispose ();
      }
    }
  }
}
