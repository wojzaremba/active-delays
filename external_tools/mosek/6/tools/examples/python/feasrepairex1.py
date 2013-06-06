#     
#   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
#   File:      feasrepairex1.py
#
#   Purpose:    To demonstrate how to use the MSK_relaxprimal function to
#               locate the cause of an infeasibility.
#
#   Syntax: On command line
#           feasrepairex1 feasrepair.lp
#           feasrepair.lp is located in mosek\<version>\tools\examples.


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


def formatdarray(a):
    r = []
    for v in a:
        r.append(str(v))
    return ','.join(r)

# We might write everything directly as a script, but it looks nicer
# to create a function.
def main (inputfile):
    # Make a MOSEK environment
    env = mosek.Env ()
    # Attach a printer to the environment
    env.set_Stream (mosek.streamtype.log, streamprinter)

    # Create a task
    task = env.Task(0,0)
    # Attach a printer to the task
    task.set_Stream (mosek.streamtype.log, streamprinter)

    # Read data 
    task.readdata(inputfile)

    task.putintparam(mosek.iparam.feasrepair_optimize,
                     mosek.feasrepairtype.optimize_penalty)
    

    # Relax
    wlc = array([ 1.0, 1.0, 1.0, 1.0 ])
    wuc = array([ 1.0, 1.0, 1.0, 1.0 ])
    wlx = array([ 1.0, 1.0 ])
    wux = array([ 1.0, 1.0 ])

    relaxed_task = task.relaxprimal(wlc,
                                    wuc,
                                    wlx,
                                    wux);

    sum_violation = relaxed_task.getprimalobj (mosek.soltype.bas)
    
    print 'lbc =', formatdarray(wlc)
    print 'ubc =', formatdarray(wuc)
    print 'lbx =', formatdarray(wlx)
    print 'ubx =', formatdarray(wux)


# call the main function
try:
    main (sys.argv[1])
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
 
