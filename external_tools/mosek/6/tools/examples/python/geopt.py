##
#   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
#   File:    geopt.py
#

#   Purpose: Demonstrates how to solve GP using the MOSEK Python API.
##

import sys
import os
import re

import mosek

from mosek.array import array, Float, log, zeros,ones

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0


# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()



def readeo(eofile):
    """
    Read a .eo file and extract data.

    The fileformat is:
    --
    numcon
    numvar
    numter
    tercof[1]
    ...
    tercof[numter]
    consub[1]
    ...
    consub[numter]
    subb[1] subj[1] cof[1]
    ...

    """
    f = open(eofile,'rb')

    fiter = iter(f)
    
    numcon = int(fiter.next())
    numvar = int(fiter.next())
    numter = int(fiter.next())

    termcof = array([ float(fiter.next()) for i in range(numter) ])
    subi    = array([ int(fiter.next())   for i in range(numter) ])
    terms   = [ ([],[]) for i in range(numter) ]
    
    subk,subj,cof = [],[],[]
    for l in fiter:
        if (l.strip()):
            _k,_j,_c = re.split(r'[ \t]+', l)
            subk.append(int(_k))
            subj.append(int(_j))
            cof.append(float(_c))

    f.close()

    subk = array(subk)
    subj = array(subj)
    cof  = array(cof)
    
    return numcon,numvar,termcof,subi,subk,subj,cof


# We might write everything directly as a script, but it looks nicer
# to create a function.
def main (eofile):
    # Open MOSEK and create an environment and task
    # Create a handle to MOSEK
    mskhandle = mosek.mosek ()
    # Make a MOSEK environment
    env = mskhandle.Env ()
    # Attach a printer to the environment
    env.set_Stream (mosek.streamtype.log, streamprinter)
    # Initialize the environment
    env.init ()

    task = env.Task()
    task.set_Stream (mosek.streamtype.log,streamprinter)# log

    numcon,numvar,termcof,subi,subk,subj,cof = readeo(eofile)
    numter = len(termcof)

    oprjo = []
    opric = []
    oprjc = []

    for i in range(len(termcof)):
        if subi[i] == 0:
            # objective term
            oprjo.append(i)
        else:
            opric.append(subi[i]-1)
            oprjc.append(i)

    numobjterm = len(oprjo)
    if numobjterm > 0:
        opro = [ mosek.scopr.exp for i in range(numobjterm) ]
        oprjo = array(oprjo)
        oprfo = ones(numobjterm,Float)
        oprgo = ones(numobjterm,Float)
        oprho = zeros(numobjterm,Float)
    else:
        opro  = None
        oprjo = None
        oprfo = None
        oprgo = None
        oprho = None

    numconterm = len(opric)
    if numconterm > 0:
        oprc = [ mosek.scopr.exp for i in range(numconterm) ]
        opric = array(opric)
        oprjc = array(oprjc)
        oprfc = ones(numconterm,Float)
        oprgc = ones(numconterm,Float)
        oprhc = zeros(numconterm,Float)
    else:
        oprc  = None
        opric = None
        oprjc = None
        oprfc = None
        oprgc = None
        oprhc = None

    # Define:
    #  var[0..numter-1] are the new variables
    #  var[numter..numter+numvar-1] are the original variables
    #  con[0..numcon-1] are the non-linear ("original") constraints
    #  con[numcon..numcon+numter] is the affine transformation
    task.append(mosek.accmode.var, numvar + numter)
    task.append(mosek.accmode.con, numcon + numter)

    for i in range(numter):
        task.putname(mosek.problemitem.var,i,'v%d' % i)
    for i in range(numvar):
        task.putname(mosek.problemitem.var,i+numter,'x%d' % i)
    for i in range(numcon):
        task.putname(mosek.problemitem.con,i,'con%d' % i)
    for i in range(numter):
        task.putname(mosek.problemitem.con,i+numcon,'fx%d' % i)
    task.putobjname('obj')
    
    

    task.putboundslice(mosek.accmode.var,
                       0, numvar + numter,
                       [ mosek.boundkey.fr for i in range(numvar + numter)],
                       zeros(numvar + numter, Float),
                       zeros(numvar + numter, Float))

    # Non-linear objective and constraints

    task.putSCeval(opro  = opro,
                   oprjo = oprjo,
                   oprfo = oprfo,
                   oprgo = oprgo,
                   oprho = oprho,
                   oprc  = oprc,
                   opric = opric,
                   oprjc = oprjc,
                   oprfc = oprfc,
                   oprgc = oprgc,
                   oprhc = oprhc)

    task.putboundslice(mosek.accmode.con,
                       0, numcon,
                       [ mosek.boundkey.up for i in range(numcon)],
                       -inf * ones(numcon,Float),
                       ones(numcon,Float))
    

    # Linear constraints
    task.putaijlist(array(range(numcon, numcon + numter)), # row
                    array(range(numter)),                  # var
                    -ones(numter,Float))                   # cof
    
    task.putaijlist(subk + numcon, # row
                    subj + numter, # var
                    cof)

    task.putboundslice(mosek.accmode.con,
                       numcon, numcon+numter,
                       [ mosek.boundkey.fx for i in range(numter) ],
                       -log(termcof),
                       -log(termcof))

    task.putobjsense(mosek.objsense.minimize)

    task.optimize ()
    print "Solution summary"

    task.solutionsummary(mosek.streamtype.log)
    xx = zeros(numvar, Float)
    task.getsolutionslice(mosek.soltype.itr,
                          mosek.solitem.xx,
                          numter, numter+numvar,
                          xx)
    print "x =", xx

    return None


# call the main function
try:
    args = sys.argv[1:]
    args.reverse()
    if len(args) > 0:
        infile   = args.pop()
        main (infile)
        f = open(resfile,'wb')
        f.write('ok')
        f.close()
    else:
        print "Syntax: %s file.eo" % sys.argv[0]
except mosek.Exception, err:
    print "ERROR: %s" % str(err)
    f = open(resfile,'wb')
    f.write(str(err))
    f.close()
    sys.exit(1)
except:
    f = open(resfile,'wb')
    f.write('System error')
    f.close()

    import traceback
    traceback.print_exc()
    sys.exit(1)
