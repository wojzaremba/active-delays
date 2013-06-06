
'
'   File:    lo1.vb
'
'   Purpose: Demonstrates how to solve small linear
'            optimization problem using the MOSEK .net API.
'
Imports System, mosek


Public Class MsgTest
    Inherits mosek.Stream
    Dim name As String

    Public Sub New(ByVal e As mosek.Env, ByVal n As String)
        '        MyBase.New ()
        name = n
    End Sub

    Public Overrides Sub streamCB(ByVal msg As String)
        Console.Write("{0}: {1}", name, msg)
    End Sub
End Class

Module Module1
    Sub Main()
        Dim infinity As Double = 0.0
        Dim NUMCON As Integer = 3
        Dim NUMVAR As Integer = 4
        Dim NUMANZ As Integer = 9

        Dim bkc As boundkey() = {boundkey.fx, boundkey.lo, boundkey.up}
        Dim bkx As boundkey() = {boundkey.lo, boundkey.ra, boundkey.lo, boundkey.lo}
        Dim asub(NUMVAR)() As Integer
        asub(0) = New Integer() {0, 1}
        asub(1) = New Integer() {0, 1, 2}
        asub(2) = New Integer() {0, 1}
        asub(3) = New Integer() {1, 2}

        Dim blc As Double() = {30.0, 15.0, -infinity}
        Dim buc As Double() = {30.0, infinity, 25.0}
        Dim cj As Double() = {3.0, 1.0, 5.0, 1.0}
        Dim blx As Double() = {0.0, 0.0, 0.0, 0, 0}
        Dim bux As Double() = {infinity, 10, infinity, infinity}

        Dim aval(NUMVAR)() As Double
        aval(0) = New Double() {3.0, 2.0}
        aval(1) = New Double() {1.0, 1.0, 2.0}
        aval(2) = New Double() {2.0, 3.0}
        aval(3) = New Double() {1.0, 3.0}

        Dim xx As Double() = {0, 0, 0, 0, 0}

        Dim task As mosek.Task
        Dim env As mosek.Env
        Dim msg As MsgTest
        Dim i As Integer
        Dim j As Integer

        Try
            env = New mosek.Env()
            env.init()
            task = New mosek.Task(env, NUMCON, NUMVAR)
            msg = New MsgTest(env, "msg")
            task.set_Stream(streamtype.log, msg)


            '  Give MOSEK an estimate of the size of the input data. 
            '  This is done to increase the speed of inputting data. 
            '  However, it is optional. 

            Call task.putmaxnumvar(NUMVAR)
            Call task.putmaxnumcon(NUMCON)
            Call task.putmaxnumanz(NUMANZ)

            'Append 'NUMCON' empty constraints.
            'The constraints will initially have no bounds. 
            Call task.append(mosek.accmode.con, NUMCON)

            'Append 'NUMVAR' variables.
            ' The variables will initially be fixed at zero (x=0). 

            Call task.append(mosek.accmode.var, NUMVAR)

            ' Optionally add a constant term to the objective. 
            Call task.putcfix(0.0)

            For j = 0 To NUMVAR - 1
                'Set the linear term c_j in the objective.
                Call task.putcj(j, cj(j))

                ' Set the bounds on variable j.
                'blx[j] <= x_j <= bux[j] 
                Call task.putbound(mosek.accmode.var, j, bkx(j), blx(j), bux(j))
                'Input column j of A 
                Call task.putavec(mosek.accmode.var, j, asub(j), aval(j))
            Next j

            ' for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] 
            For i = 0 To NUMCON - 1
                Call task.putbound(mosek.accmode.con, i, bkc(i), blc(i), buc(i))
            Next i

            Call task.putobjsense(mosek.objsense.maximize)

            Call task.optimize()
            ' Print a summary containing information
            '   about the solution for debugging purposes
            Call task.solutionsummary(mosek.streamtype.msg)


            Dim solsta As mosek.solsta
            Dim prosta As mosek.prosta
            ' Get status information about the solution 

            Call task.getsolutionstatus(mosek.soltype.bas, prosta, solsta)

            task.getsolutionslice(soltype.itr, solitem.xx, 0, NUMVAR - 1, xx)

            For j = 0 To NUMVAR - 1
                Console.WriteLine("x[{0}]:{1}", j, xx(j))
            Next

            Console.WriteLine("Finished optimization")
        Catch e As mosek.Exception
            Console.WriteLine("MosekException caught, {0}", e)
        Catch e As System.Exception
            Console.WriteLine("System.Exception caught, {0}", e)
        End Try
    End Sub
End Module

