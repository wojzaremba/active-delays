##
#    Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
#    File:    mioinitsol.cs
#
#    Purpose:  Demonstrates how to solve a small mixed
#              integer linear optimization problem using the MOSEK Python API.
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

       
    bkc  = [ mosek.boundkey.up ]
    blc  = [ -inf,             ]
    buc  = [ 2.5               ] 

    bkx  = [ mosek.boundkey.lo,
             mosek.boundkey.lo,
             mosek.boundkey.lo,
             mosek.boundkey.lo ]
    
    blx  = [0.0, 0.0, 0.0, 0.0 ]
    bux  = [ inf, inf,  inf,  inf ]

    c    = [ 7.0, 10.0, 1.0, 5.0 ]

    asub = [  0,   0,   0,   0   ]
    acof = [  1.0, 1.0, 1.0, 1.0]

    ptrb = [ 0, 1, 2, 3 ]
    ptre = [ 1, 2, 3, 4 ]

    numvar = len(bkx)
    numcon = len(bkc)

    # Input linear data
    task.inputdata(numcon,numvar,
                   c,0.0,
                   ptrb, ptre, asub, acof,
                   bkc,  blc,  buc,
                   bkx,  blx,  bux)

    # Input objective sense
    task.putobjsense(mosek.objsense.maximize)

    # Define variables to be integers
    task.putvartypelist([ 0, 1, 2 ],
                        [ mosek.variabletype.type_int,
                          mosek.variabletype.type_int,
                          mosek.variabletype.type_int])
    
    # Construct an initial feasible solution from the
    #     values of the integer valuse specified 
    task.putintparam(mosek.iparam.mio_construct_sol,
                     mosek.onoffkey.on);

    # Set status of all variables to unknown 
    task.makesolutionstatusunknown(mosek.soltype.itg);
    
    # Assign values 1,1,0 to integer variables 
    task.putsolutioni (
        mosek.accmode.var,
        0,
        mosek.soltype.itg, 
        mosek.stakey.supbas, 
        0.0,
        0.0,
        0.0,
        0.0);
    
    task.putsolutioni (
        mosek.accmode.var,
        1,
        mosek.soltype.itg, 
        mosek.stakey.supbas, 
        2.0,
        0.0,
        0.0,
        0.0);
        
        
    task.putsolutioni (
        mosek.accmode.var,
        2,
        mosek.soltype.itg, 
        mosek.stakey.supbas, 
        0.0,
        0.0,
        0.0,
        0.0);

    # Optimize
    task.optimize()

    if task.solutiondef(mosek.soltype.itg):

        # Output a solution
        xx = zeros(numvar, float)
        task.getsolutionslice(mosek.soltype.itg,
                              mosek.solitem.xx,
                              0, numvar,
                              xx)
        print "x =", xx
    else:
        print "Integer solution not defined. Probably a problem with 'mosekglb' optimizer."

# call the main function
try:
    main ()
except mosek.Exception, e:
    print "ERROR: %s" % str(e.errno)
    if e.msg is not None:
        print "\t%s" % e.msg
    sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)

