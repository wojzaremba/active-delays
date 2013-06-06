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
  
  bkc = [ mosek.boundkey.fx ]
  blc = [ 1.0 ]
  buc = [ 1.0 ]
  
  c   = [               0.0,              0.0,              0.0,
                        0.0,              1.0,              1.0 ]
  bkx = [ mosek.boundkey.lo,mosek.boundkey.lo,mosek.boundkey.lo,
          mosek.boundkey.lo,mosek.boundkey.fr,mosek.boundkey.fr ]
  blx = [               0.0,              0.0,              0.0,
                        0.0,             -inf,             -inf ]
  bux = [               inf,              inf,              inf,
                        inf,              inf,              inf ]
  
  asub = [ array([0]),   array([0]),   array([0]),   array([0])   ]
  aval = [ array([1.0]), array([1.0]), array([1.0]), array([1.0]) ]


  NUMVAR = len(bkx)
  NUMCON = len(bkc)
  NUMANZ = 4
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

  for j in range(len(aval)):
    # Input column j of A 
    task.putavec(mosek.accmode.var,  # Input columns of A.
                 j,                  # Variable (column) index.
                 asub[j],            # Row index of non-zeros in column j.
                 aval[j])            # Non-zero Values of column j. 
  for i in range(NUMCON):
    task.putbound(mosek.accmode.con,i,bkc[i],blc[i],buc[i])
        
  # Input the cones
  task.appendcone(mosek.conetype.quad,
                  0.0,
                  [ 4, 0, 2 ])
  task.appendcone(mosek.conetype.quad,
                  0.0,
                  [ 5, 1, 3 ])

  # Input the objective sense (minimize/maximize)
  task.putobjsense(mosek.objsense.minimize)
       
  # Optimize the task
  task.optimize()
  # Print a summary containing information
  # about the solution for debugging purposes
  task.solutionsummary(mosek.streamtype.msg)
  prosta = []
  solsta = []
  [prosta,solsta] = task.getsolutionstatus(mosek.soltype.itr)

  # Output a solution
  xx = zeros(NUMVAR, float)
  task.getsolutionslice(mosek.soltype.itr,
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


