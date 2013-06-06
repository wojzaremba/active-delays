#
#  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
#  File:    lo2.py
#
#  Purpose: Demonstrates how to solve small linear
#           optimization problem using the MOSEK Python API.
##

import sys

import mosek
# If numpy is installed, use that, otherwise use the 
# Mosek's array module.
try:
    from numpy import array,zeros,ones
except ImportError:
    from mosek.array import array, zeros, ones

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

# We might write everything directly as a script, but it looks nicer
# to create a function.
def main ():
  # Make a MOSEK environment
  env = mosek.Env ()
  # Attach a printer to the environment
  env.set_Stream (mosek.streamtype.log, streamprinter)
  
  # Create a task
  task = env.Task(0,0)
  # Attach a printer to the task
  task.set_Stream (mosek.streamtype.log, streamprinter)
  
  # Bound keys for constraints
  bkc = [mosek.boundkey.fx,
         mosek.boundkey.lo,
         mosek.boundkey.up]
  # Bound values for constraints
  blc = [30.0, 15.0, -inf]
  buc = [30.0, +inf, 25.0]
  # Bound keys for variables
  bkx = [mosek.boundkey.lo,
         mosek.boundkey.ra,
         mosek.boundkey.lo,
         mosek.boundkey.lo]
  # Bound values for variables
  blx = [ 0.0,  0.0,  0.0,  0.0]
  bux = [+inf, 10.0, +inf, +inf]
  # Objective coefficients

  c = [ 3.0, 1.0, 5.0, 1.0 ] 

  # We input the A matrix column-wise
  # asub contains row indexes
  asub = [ array([0, 1, 2]),
           array([0, 1, 2, 3]),
           array([0, 3])]
    # acof contains coefficients
  aval = [ array([3.0, 1.0, 2.0]),
           array([2.0, 1.0, 3.0, 1.0]),
           array([2.0, 3.0])]
  NUMVAR = len(bkx)
  NUMCON = len(bkc)
  NUMANZ = 9
  # Give MOSEK an estimate of the size of the input data. 
  #  This is done to increase the speed of inputting data. 
  #  However, it is optional. 
  task.putmaxnumvar(NUMVAR)
  task.putmaxnumcon(NUMCON)
  task.putmaxnumanz(NUMANZ)
  # Append 'NUMCON' empty constraints.
  # The constraints will initially have no bounds. 
  task.append(mosek.accmode.con,NUMCON)
     
  #Append 'NUMVAR' variables.
  # The variables will initially be fixed at zero (x=0). 
  task.append(mosek.accmode.var,NUMVAR)

  #Optionally add a constant term to the objective. 
  task.putcfix(0.0)

  for j in range(NUMVAR):
    # Set the linear term c_j in the objective.
    task.putcj(j,c[j])
    # Set the bounds on variable j
    # blx[j] <= x_j <= bux[j] 
    task.putbound(mosek.accmode.var,j,bkx[j],blx[j],bux[j])

  for i in range(NUMCON):
    task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i])
    # Input row i of A 
    task.putavec(mosek.accmode.con,     #Input row of A.
                 i,                     # Row index.
                 asub[i],               # Column indexes of non-zeros in row i.
                 aval[i]);              # Non-zero Values of row i. 


  # Input the objective sense (minimize/maximize)
  task.putobjsense(mosek.objsense.maximize)
       
  # Optimize the task
  task.optimize()

  # Print a summary containing information
  # about the solution for debugging purposes
  task.solutionsummary(mosek.streamtype.msg)

  prosta = []
  solsta = []
  [prosta,solsta] = task.getsolutionstatus(mosek.soltype.bas)

  # Output a solution
  xx = zeros(NUMVAR, float)
  task.getsolutionslice(mosek.soltype.bas,
                        mosek.solitem.xx, 
                        0,NUMVAR,          
                        xx)

  if solsta == mosek.solsta.optimal or solsta == mosek.solsta.near_optimal:
      print("Optimal solution: %s" % xx)
  elif solsta == mosek.solsta.dual_infeas_cer: 
      print("Primal or dual infeasibility.\n")
  elif solsta == mosek.solsta.prim_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif solsta == mosek.solsta.near_dual_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif  solsta == mosek.solsta.near_prim_infeas_cer:
      print("Primal or dual infeasibility.\n")
  elif mosek.solsta.unknown:
    print("Unknown solution status")
  else:
    print("Other solution status")

# call the main function
try:
    main ()
except mosek.Exception, (code,msg):
    print "ERROR: %s" % str(code)
    if msg is not None:
        print "\t%s" % msg
        sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)
sys.exit(0)
