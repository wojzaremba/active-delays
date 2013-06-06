using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.SolverFoundation.Services;
using SolverFoundation.Plugin.Mosek; 
using System.Configuration;

/* Microsoft solver foundation example which load an MPS file and solve the problem using mosek interior point */

namespace Microsoft.SolverFoundation.Samples {
    using Microsoft.SolverFoundation.Services;
  class Program {
    static void Main(string[] args) {

      {
        SolverContext context = SolverContext.GetContext();

        // Load a model from file
        if (args.Length > 0)
        {
            using (TextReader streamReader =
                  new StreamReader(args[0]))
            {
                context.LoadModel(FileFormat.MPS, streamReader);
            }

            // Select the Mosek interior point optimizer.
            MosekInteriorPointMethodDirective d = new MosekInteriorPointMethodDirective();

            // Mosek specific parameters may optionally be set.
            // d[mosek.dparam.optimizer_max_time] = 100.0;

            // Optionally write log information to console using two lines below
            System.Diagnostics.ConsoleTraceListener listener =
            new System.Diagnostics.ConsoleTraceListener();
            d.AddListener(listener);

            // Solve the problem 
            Solution sol = context.Solve(d);

            // Print solution 
            Report report = sol.GetReport();
        }
        else
        {
            Console.WriteLine("Usage: MosekMsfExample filename");
        }
        Console.WriteLine("Please press any key.");
        Console.ReadKey();
      }  
    } 
  }
}
