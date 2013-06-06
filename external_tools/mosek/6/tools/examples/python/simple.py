#
# Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
# File:    simple.py
#
# Purpose: Demonstrates a very simple example using MOSEK by
# reading a problem file, solving the problem and
# writing the solution to a file.
#

import mosek
import sys

if len(sys.argv) <= 1:
    print "Missing argument. The syntax is:"
    print " simple inputfile [ solutionfile ]"
else:
    # Make mosek environment. 
    env  = mosek.Env ()
    
    # Initialize the environment.
    env.init ()

    # Create a task object linked with the environment env.
    #  We create it initially with 0 variables and 0 columns, 
    #  since we don't know the size of the problem.
    task = env.Task (0,0)

    # We assume that a problem file was given as the first command
    # line argument (received in `args')
    task.readdata (sys.argv[1])

    # Solve the problem
    task.optimize()

    # Print a summary of the solution
    task.solutionsummary(mosek.streamtype.log)

    # If an output file was specified, write a solution
    if len(sys.argv) > 2:
      # We define the output format to be OPF, and tell MOSEK to
      # leave out parameters and problem data from the output file.
      task.putintparam (mosek.iparam.write_data_format,    mosek.dataformat.op)
      task.putintparam (mosek.iparam.opf_write_solutions,  mosek.onoffkey.on)
      task.putintparam (mosek.iparam.opf_write_hints,      mosek.onoffkey.off)
      task.putintparam (mosek.iparam.opf_write_parameters, mosek.onoffkey.off)
      task.putintparam (mosek.iparam.opf_write_problem,    mosek.onoffkey.off)

      task.writedata(sys.argv[2])

