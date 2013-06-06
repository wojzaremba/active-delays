#
# Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
# File:    network2.py
#
#  Demonstrates a simple use of network structure in a model.
#
#   Purpose: 1. Read an optimization problem from an
#               user specified MPS file.
#            2. Extract the embedded network (if any ).
#            3. Solve the embedded network with the network optimizer.
#
#   Note that the general simplex optimizer called though MSK_optimize can also extract 
#   embedded network and solve it with the network optimizer. The direct call to the 
#   network optimizer, which is demonstrated here, is offered as an option to save 
#   memory and overhead for solving either many or large network problems.
# 

import sys
import mosek
from numpy import resize,array, float, zeros
#from mosek.array import *

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

if len(sys.argv) != 2:
    print "Wrong arguments. The syntax is:"
    print " network2 inputfile"
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
    task   = env.Task (0,0)
    
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
    bkx     = [ mosek.boundkey.fx ] * numvar)
    
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
    skx     = [ mosek.stakey.unk ] * netnumvar 
    
    # Specify problem and solution status.
    prosta  = []
    solsta  = []
    
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

