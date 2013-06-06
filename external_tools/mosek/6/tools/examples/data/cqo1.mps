* File: cqo1.mps
NAME          CQO EXAMPLE
ROWS
 N  obj
 E  c1
COLUMNS
    x1        obj       1.0   
    x2        obj       2.0
    x3        c1        2.0           
    x4        c1        4.0
    x5        obj       0.0
    x6        obj       0.0  
RHS
    rhs       c1        5.0     
BOUNDS
 FX bounds    x5        1.0
 FX bounds    x6        1.0
CSECTION      k1        0.0            RQUAD
    x1
    x3
    x5
CSECTION      k2        0.0            RQUAD 
    x2
    x4  
    x6
ENDATA
