#
# Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
# File:    network3.py
#
#  Demonstrates a simple use of network structure in a model.
#
#   Purpose: 1. Read an optimization problem from an
#               user specified MPS file.
#            2. Extract the embedded network (if any ).
#            3. Solve the embedded network with the network optimizer.
#            4. Uses the network solution to hotstart dual simplex on the  
#               original problem.
#
#   Note the general simplex optimizer called though MSK_optimize can also extract 
#   embedded network and solve it with the network optimizer. The direct call to the 
#   network optimizer, which is demonstrated here, is offered as an option to save 
#   memory and overhead for solving either many or large network problems.
# 

import sys
import mosek
from numpy import resize,array,zeros,ones,float

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

if len(sys.argv) != 2:
    print "Wrong arguments. The syntax is:"
    print " network3 inputfile"
else:
  # Make mosek environment. 
  env  = mosek.Env ()
  
  # Initialize the environment.
  env.init ()
  
  # Attach a printer to the environment
  env.set_Stream (mosek.streamtype.log, streamprinter)
  
  #  since we don't know the size of the problem.
  numcon    = []
  numvar    = []
  netnumcon = []
  netnumvar = []
  task      = env.Task (0,0)
  
  task.readdata (sys.argv[1])
  
  numcon = task.getnumcon ()
  numvar = task.getnumvar ()
  
  # Specify network graph data.
  netfrom = zeros (numvar, int) 
  netto   = zeros (numvar, int) 
  
  # Specify arc cost.
  cc      = zeros (numcon, float) 
  cx      = zeros (numvar, float) 
  
  # Specify boundkeys.
  bkc     = [ mosek.boundkey.fx ] * numcon 
  bkx     = [ mosek.boundkey.fx ] * numvar
  
  # Specify bounds.
  blc     = zeros (numcon, float) 
  buc     = zeros (numcon, float)
  blx     = zeros (numvar, float)
  bux     = zeros (numvar, float) 
  
  # Specify data for extracted network.
  scalcon = zeros (numcon, float) 
  scalvar = zeros (numvar, float) 
  netcon  = zeros (numcon, int) 
  netvar  = zeros (numvar, int)
  
  # Extract embedded network
    
  netnumcon,netnumvar = task.netextraction(
    netcon,
    netvar,
    scalcon,
    scalvar,
    cx,
    bkc,
    blc,
    buc,
    bkx,
    blx,
    bux,
    netfrom,
    netto)
  
  # Create a dummy task object linked with the environment env.
  dummytask = env.Task (netnumcon,netnumvar)
  
  # Array length for netoptimize must match netnumcon and netnumvar

  # Resize network graph data.
  netfrom = resize (netfrom,netnumvar) 
  netto   = resize (netto,netnumvar) 

  # Resize arc cost.
  cc      = resize (cc,netnumcon) 
  cx      = resize (cx,netnumvar) 

  # Resize boundkeys.
  bkc     = [ mosek.boundkey.fx ] * netnumcon
  bkx     = [ mosek.boundkey.fx ] * netnumvar

  # Resize bounds.
  blc     = resize (blc,netnumcon) 
  buc     = resize (buc,netnumcon)
  blx     = resize (blx,netnumvar)
  bux     = resize (bux,netnumvar) 

  # Specify zero primal solution.
  xc      = zeros (netnumcon, float) 
  xx      = zeros (netnumvar, float) 
  
  # Specify zero dual solution.
  y       = zeros (netnumcon, float) 
  slc     = zeros (netnumcon, float) 
  suc     = zeros (netnumcon, float) 
  slx     = zeros (netnumvar, float) 
  sux     = zeros (netnumvar, float) 
  
  # Specify status keys.
  skc     = [ mosek.stakey.unk ] * netnumcon
  skx     = [ mosek.stakey.unk ] * netnumvar) 
  
  
  # Solve the network problem

  prosta,solsta = dummytask.netoptimize(
    cc,
    cx,
    bkc,
    blc,
    buc,
    bkx,
    blx,
    bux,
    netfrom,
    netto,
    0,
    skc,
    skx,
    xc,
    xx,
    y,
    slc,
    suc,
    slx,
    sux)
  
  print "Original problem size : numcon : %d numvar : %d" % (numcon,numvar)
  print "Embedded network size : numcon : %d numvar : %d" % (netnumcon,netnumvar)
  
  if  solsta == mosek.solsta.optimal :
    print "Network problem is optimal"
  elif solsta == mosek.solsta.prim_infeas_cer :
    print "Network problem is primal infeasible"
  elif solsta == mosek.solsta.dual_infeas_cer :
    print "Network problem is dual infeasible"
  else :
    print "Network problem solsta : %s" % solsta 
  
  # Setup mark arrays
  rmap  = zeros (numcon, int) 
  cmap  = zeros (numvar, int)
  
  for i in range(0,netnumcon) :
    rmap[netcon[i]]      = i+1
  
  for j in range(0,netnumvar) :
    cmap[netvar[j]]      = j+1
  
  # Unscale rows and set up solution 
  for i in range(0,numcon) :
    if rmap[i] != 0 :  
      # Get index in network solution  
      k        = rmap[i]-1
  
      if solsta != mosek.solsta.prim_infeas_cer :
        xc[k]  /= scalcon[i]
  
      if solsta != mosek.solsta.dual_infeas_cer :
        slc[k] *= scalcon[i]
        suc[k] *= scalcon[i]
  
      # Scaling value is negative, then bound keys has been changed  
      if scalcon[i] < 0.0 :
        if skc[k] == mosek.stakey.low :
          skc[k] = mosek.stakey.upr
        elif skc[k] == mosek.statkey.upr :
          skc[k] = mosek.stakey.low
  
      # In network => use network status keys and solution 
      task.putsolutioni (mosek.accmode.con,
                         i,
                         mosek.soltype.bas,
                         skc[k],
                         xc[k],
                         slc[k],
                         suc[k],
                         0.0)
    else:
      # Not in network => make basic 
      task.putsolutioni (mosek.accmode.con,
                         i,
                         mosek.soltype.bas,
                         mosek.stakey.bas,
                         0.0,
                         0.0,
                         0.0,
                         0.0)
  
  # Unscale columns and set up solution 
  for j in range(0,numvar) :
    if cmap[j] != 0 :
      # Get index in network solution  */
      k        = cmap[j]-1
  
      if solsta != mosek.solsta.prim_infeas_cer :
        xx[k]  /= scalvar[j]
  
      if solsta != mosek.solsta.dual_infeas_cer :
        slx[k] *= scalvar[j]
        sux[k] *= scalvar[j]
  
      # Scaling value is negative, then bound keys has been changed  
      if scalvar[j] < 0.0 :
        if skx[k] == mosek.stakey.low :
          skx[k] = mosek.stakey.upr
        elif skx[k] == mosek.stakey.upr :
          skx[k] = mosek.stakey.low
  
      # In network => use network status keys and solution 
      task.putsolutioni (mosek.accmode.var,
                         j,
                         mosek.soltype.bas,
                         skx[k],
                         xx[k],
                         slx[k],
                         sux[k],
                         0.0)
    else :
      bk,bl,bu = task.getbound (mosek.accmode.var, j)
  
      # Not in network => value should correspond to fixed levels  
      if bk == mosek.boundkey.fx:
        # Put on fixed 
        task.putsolutioni (mosek.accmode.var,
                           j,
                           mosek.soltype.bas,
                           mosek.stakey.fix,
                           bl,
                           0.0,
                           0.0,
                           0.0)
  
      elif bk == mosek.boundkey.lo or bk == mosek.boundkey.ra:
        # Put on lower 
        task.putsolutioni (mosek.accmode.var,
                           j,
                           mosek.soltype.bas,
                           mosek.stakey.low,
                           bl,
                           0.0,
                           0.0,
                           0.0)
  
      elif bk == mosek.boundkey.up:
        # Put on upper 
        task.putsolutioni (mosek.accmode.con,
                           j,
                           mosek.soltype.bas,
                           mosek.stakey.upr,
                           bu,
                           0.0,
                           0.0,
                           0.0)
  
      elif bk == mosek.boundkey.fr:
        # Put on superbasic 
        task.putsolutioni (mosek.accmode.con,
                           j,
                           mosek.soltype.bas,
                           mosek.stakey.supbas,
                           0.0,
                           0.0,
                           0.0,
                           0.0)
  
  # Set the optimizer to dual simplex
  task.putintparam (mosek.iparam.optimizer,mosek.optimizertype.dual_simplex)
  
  # Optimize from the network hotstart
  task.optimize ()
  
  # Obtain solution status
  solinf = task.getsolutioninf (mosek.soltype.bas)
  solsta = solinf[0]
  prosta = solinf[1]

  if  solsta == mosek.solsta.optimal :
    print "Problem is optimal"
  elif solsta == mosek.solsta.prim_infeas_cer :
    print "Problem is primal infeasible"
  elif solsta == mosek.solsta.dual_infeas_cer :
    print "Problem is dual infeasible"
  else :
    print "Problem solsta : %s" % solsta 

