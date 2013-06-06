#
#  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.
#
#  File:      example_lines.py
#
#  Purpose: This example is not meant to be distributed. It
#           demonstrates some functionality used in the manual.
#           It is means to compile _only_! It will not run!
#

import mosek
from numpy import *
from mosek import boundkey,accmode


env = mosek.Env()
env.init()

task = env.Task()


numvar = 10
numcon = 10
task.append(mosek.accmode.con, numcon)
task.append(mosek.accmode.var, numvar)


c = zeros(numvar,float)
task.getc(c)

upper_bound = zeros(8,float)
lower_bound = zeros(8,float)
bound_key   = array([None] * 8)

task.getboundslice(accmode.con, 2, 10,
                   bound_key,lower_bound,upper_bound)

bound_index = [          1,          6,          3,          9]
bound_key   = [boundkey.fr,boundkey.lo,boundkey.up,boundkey.fx]
lower_bound = [     0.0,         -10.0,        0.0,        5.0]
upper_bound = [     0.0,           0.0,        6.0,        5.0]
task.putboundlist(accmode.con, bound_index,
                  bound_key,lower_bound,upper_bound)

subi = array([   1,   3,   5 ])
subj = array([   2,   3,   4 ])
cof  = array([ 1.1, 4.3, 0.2 ])
task.putaijlist(subi,subj,cof)

rowsub = array([ 0, 1, 2, 3 ])
ptrb   = array([ 0, 3, 5, 7 ])
ptre   = array([ 3, 5, 7, 8 ])
sub    = array([ 0, 2, 3, 1, 4, 0, 3, 2 ])
cof    = array([ 1.1, 1.3, 1.4, 2.2, 2.5, 3.1, 3.4, 4.4 ])

task.putaveclist (accmode.con,
                  rowsub,ptrb,ptre,
                  sub,cof)

# Create an array of integers
a0 = array([1,2,3],int)
# Create an array of floats
a1 = array([1,2,3],float)
# Create an integer array of ones
a2 = ones(10)
# Create an float array of ones
a3 = ones(10,float)
# Create a range of integers 5,6,...,9
a4 = range(5,10)
# Create and array of objects
a5 = array(['a string', 'b string', 10, 2.2])

a = ones(10,float)
b = 1.0 * arange(10)


# element-wise multiplication, addition and subtraction
c0 = a * b
c1 = a + b
c2 = a - b

# multiplly each element by 2.1
c4 = a * 2.1

# add 2 to each element
c5 = a + 2

