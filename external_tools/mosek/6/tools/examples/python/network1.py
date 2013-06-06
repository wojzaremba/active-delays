#
# Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
# File:    network1.py
#
#  Demonstrates a simple use of the network optimizer.
#
#   Purpose: 1. Specify data for a network.
#            2. Solve the network problem with the network optimizer.
# 

import sys
import mosek
from numpy import array, float, zeros

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

# Since the actual value of Infinity is ignored, we define it solely
# for symbolic purposes:
inf = 0.0

# Make mosek environment. 
env  = mosek.Env ()

# Initialize the environment.
env.init ()

# Attach a printer to the environment
env.set_Stream (mosek.streamtype.log, streamprinter)

numcon = 4
numvar = 6

# Specify network graph data.
netfrom = array ([0,2,3,1,1,1]) 
netto   = array ([2,3,1,0,2,2]) 

# Specify arc cost.
cc      = zeros (4, float) 
cx      = array ([1.0,0.0,1.0,0.0,-1.0,1.0]) 

# Specify boundkeys.
bkc     = [mosek.boundkey.fx]*4 

bkx     = [mosek.boundkey.lo]*6 

# Specify bounds.
blc     = array ([1.0,1.0,-2.0,0.0]) 
buc     = array ([1.0,1.0,-2.0,0.0]) 
blx     = zeros (6, float) 
bux     = array ([inf,inf,inf,inf,inf,inf]) 

# Specify zero primal solution.
xc      = zeros (4, float) 
xx      = zeros (6, float) 

# Specify zero dual solution.
y       = zeros (4, float) 
slc     = zeros (4, float) 
suc     = zeros (4, float) 
slx     = zeros (6, float) 
sux     = zeros (6, float) 

# Specify status keys.
skc     = [mosek.stakey.unk]*4
 
skx     = [mosek.stakey.unk]*6 

# Create a task object linked with the environment env.
dummytask = env.Task (numcon,numvar)

# Set the problem to be maximized
dummytask.putobjsense (mosek.objsense.maximize)

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

if  solsta == mosek.solsta.optimal :
  print "Network problem is optimal"

  print "Primal solution is :"
  for i in range(0,numcon) :
    print "xc[%d] = %-16.10e" % (i,xc[i])

  for j in range(0,numvar) :
    print "Arc(%d,%d) -> xx[%d] = %-16.10e" % (netfrom[j],netto[j],j,xx[j])
elif solsta == mosek.solsta.prim_infeas_cer :
  print "Network problem is primal infeasible"
elif solsta == mosek.solsta.dual_infeas_cer :
  print "Network problem is dual infeasible"
else :
  print "Network problem solsta : %s" % solsta

