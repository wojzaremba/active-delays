/*
  Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

  File:    network3.java

  Demonstrates a more advanced use of network structure in a model.

   Purpose: 1. Read an optimization problem from an
                          user specified MPS file.
            2. Extract the embedded network (if any ).
            3. Solve the embedded network with the network optimizer.
            4. Use the network solution to hotstart dual simplex on the  
              original problem.

   Note the general simplex optimizer called though MSK_optimize can also extract 
   embedded network and solve it with the network optimizer. The direct call to 
   the network optimizer, which is demonstrated here, is offered as an option to 
   save memory and overhead for solving either many or large network problems.
*/

package network3;

import mosek.*;

class msgclass extends mosek.Stream {
    public msgclass ()
    {
        super ();
    }

    public void stream (String msg)
    {
        System.out.print (msg);
    }
}

public class network3
{
  public static void main (String[] args)
  {
    if (args.length != 1)
    {
      System.out.println ("Wrong arguments. The syntax is:");
      System.out.println (" simple inputfile");
    }
    else
    {
      mosek.Env
          env = null;
      mosek.Task
          task = null, dummytask = null;
  
      mosek.Env.solsta[]
          solsta    = new mosek.Env.solsta[1];
  
      mosek.Env.prosta[]    
          prosta    = new mosek.Env.prosta[1];
  
      int numcon,numvar;
      int[] netnumcon = new int[1];
      int[] netnumvar = new int[1];
  
      try
      {
        // Make mosek environment. 
        env  = new mosek.Env ();
  
        // Direct the env log stream to the user specified
        // method env_msg_obj.print
        msgclass env_msg_obj = new msgclass ();
  
        env.set_Stream (mosek.Env.streamtype.log,env_msg_obj);
        // Initialize the environment.
        env.init ();
  
        // Create a task object linked with the environment env.
        //  We create it initially with 0 variables and 0 columns, 
        //  since we don't know the size of the problem.
        task = new mosek.Task (env, 0,0);
  
        task.readdata (args[0]);
  
        numcon = task.getnumcon ();
        numvar = task.getnumvar ();
  
        // Specify network data
        int[] rmap        = new int[numcon];
        int[] cmap        = new int[numvar];
        int[] netcon      = new int[numcon];
        int[] netvar      = new int[numvar];
        int[] from        = new int[numvar];
        int[] to          = new int[numvar];
  
        // Specify network scaling factors
        double[] scalcon  = new double[numcon];
        double[] scalvar  = new double[numvar];
  
        // Specify objective and bounds
        double[] cc       = new double[numcon];
        double[] cx       = new double[numvar];
        double[] blc      = new double[numcon];
        double[] buc      = new double[numcon];
        double[] blx      = new double[numvar];
        double[] bux      = new double[numvar];
  
        // Specify bound keys
        mosek.Env.boundkey[] bkc = new mosek.Env.boundkey[numcon];
        mosek.Env.boundkey[] bkx = new mosek.Env.boundkey[numvar];
  
        // Specify solution data
        double[] xc   = new double[numcon];
        double[] xx   = new double[numvar];
        double[] y    = new double[numcon];
        double[] slc  = new double[numcon];
        double[] suc  = new double[numcon];
        double[] slx  = new double[numvar];
        double[] sux  = new double[numvar];
  
        mosek.Env.stakey[] skc  = new mosek.Env.stakey[numcon];
        mosek.Env.stakey[] skx  = new mosek.Env.stakey[numvar];
  
        for( int i = 0; i < numcon; ++i )
        {
          skc[i] = mosek.Env.stakey.unk;
        }

        for( int j = 0; j < numvar; ++j )
        {
          skx[j] = mosek.Env.stakey.unk;
        }

        /* We just use zero cost on slacks */
        for( int i = 0; i < numcon; ++i )
          cc[i] = 0.0;
  
        // Extract embedded network 
        task.netextraction(netnumcon,
                           netnumvar,
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
                           from,
                           to);

        System.out.println ("network extraction :");
        System.out.println ("numcon : " + numcon + " netnumcon : " + netnumcon[0]);
        System.out.println ("numvar : " + numvar + " netnumvar : " + netnumvar[0]);
  
        // Create a task object linked with the environment env.
        dummytask = new mosek.Task (env, netnumcon[0], netnumvar[0]);
  
        // Directs the log task stream to the user specified
        // method task_msg_obj.print
        msgclass task_msg_obj = new msgclass ();
        dummytask.set_Stream (mosek.Env.streamtype.log,task_msg_obj);
              
        // Solve the network problem
        dummytask.netoptimize(cc,
                              cx,
                              bkc,
                              blc,
                              buc,
                              bkx,
                              blx,
                              bux,
                              from,
                              to,
                              prosta,
                              solsta,
                              false,
                              skc,
                              skx,
                              xc,
                              xx,
                              y,
                              slc,
                              suc,
                              slx,
                              sux);
        
        if ( solsta[0] == mosek.Env.solsta.optimal )
        {
          System.out.println("Embedded network problem is optimal");
        }
        else if ( solsta[0] == mosek.Env.solsta.prim_infeas_cer )
        {
          System.out.println("Embedded network problem is primal infeasible");
        }
        else if ( solsta[0] == mosek.Env.solsta.dual_infeas_cer )
        {
          System.out.println("Embedded network problem is dual infeasible");
        }
        else
        {
          System.out.println("Embedded network problem solsta : "+solsta[0]);
        }
         
        /* Set up hotstart for dual simplex  */
    
        /* Setup mark arrays  */
        for( int i = 0; i < numcon; ++i )
          rmap[i] = 0;
    
        for( int j = 0; j < numvar; ++j )
          cmap[j] = 0;
    
        for( int i = 0; i < netnumcon[0]; ++i )
        { 
          rmap[netcon[i]]      = i+1;
        }
    
        for( int j = 0; j < netnumvar[0]; ++j )
        {
          cmap[netvar[j]]      = j+1;
        }
    
        /* Unscale rows and set up solution */
        for( int i = 0; i < numcon; ++i)
        {
          if( rmap[i] != 0 )
          {
            /* Get index in network solution  */
            int k        = rmap[i]-1;
    
            if( solsta[0] != mosek.Env.solsta.prim_infeas_cer )
            {
              xc[k]  /= scalcon[i];
            }
    
            if( solsta[0] != mosek.Env.solsta.dual_infeas_cer )
            {
              slc[k] *= scalcon[i];
              suc[k] *= scalcon[i];
            }
    
            /* Scaling value is negative, then bound keys has been changed  */
            if( scalcon[i] < 0.0 )
            {
              if( skc[k] == mosek.Env.stakey.low )
              {
                skc[k] = mosek.Env.stakey.upr;
              }
              else if( skc[k] == mosek.Env.stakey.upr )
              {
                skc[k] = mosek.Env.stakey.low;
              }
            }
    
            /* In network => use network status keys and solution */
            task.putsolutioni (mosek.Env.accmode.con,
                               i,
                               mosek.Env.soltype.bas,
                               skc[k],
                               xc[k],
                               slc[k],
                               suc[k],
                               0.0);
          }
          else
          {
            /* Not in network => make basic */
            task.putsolutioni (mosek.Env.accmode.con,
                               i,
                               mosek.Env.soltype.bas,
                               mosek.Env.stakey.bas,
                               0.0,
                               0.0,
                               0.0,
                               0.0);
          }
        }
    
    
        mosek.Env.boundkey[]    
            bk    = new mosek.Env.boundkey[1];
    
        double[] bl = new double[1];
        double[] bu = new double[1];
    
        /* Unscale columns and set up solution */
        for( int j = 0; j < numvar; ++j)
        {
          if( cmap[j] != 0 )
          {
            /* Get index in network solution  */
            int k        = cmap[j]-1;
    
            if ( solsta[0] != mosek.Env.solsta.prim_infeas_cer )
            {
              xx[k]  /= scalvar[j];
            }
    
            if ( solsta[0] != mosek.Env.solsta.dual_infeas_cer )
            {
              slx[k] *= scalvar[j];
              sux[k] *= scalvar[j];
            }
    
            /* Scaling value is negative, then bound keys has been changed  */
            if( scalvar[j] < 0.0 )
            {
              if( skx[k] == mosek.Env.stakey.low)
              {
                skx[k] = mosek.Env.stakey.upr;
              }
              else if( skx[k] == mosek.Env.stakey.upr)
              {
                skx[k] = mosek.Env.stakey.low;
              }
            }
    
            /* In network => use network status keys and solution */
            task.putsolutioni (mosek.Env.accmode.var,
                               j,
                               mosek.Env.soltype.bas,
                               skx[k],
                               xx[k],
                               slx[k],
                               sux[k],
                               0.0);
          }
          else
          {
            task.getbound (mosek.Env.accmode.var,
                             j,
                             bk,
                             bl,
                             bu);
    
            /* Not in network => value should correspond to fixed levels  */
            switch( bk[0] )
            {
              case fx:
                /* Put on fixed */
                task.putsolutioni (mosek.Env.accmode.var,
                                   j,
                                   mosek.Env.soltype.bas,
                                   mosek.Env.stakey.fix,
                                   bl[0],
                                   0.0,
                                   0.0,
                                   0.0);
                break;
              case lo:
              case ra:
                /* Put on lower */
                task.putsolutioni (mosek.Env.accmode.var,
                                   j,
                                   mosek.Env.soltype.bas,
                                   mosek.Env.stakey.low,
                                   bl[0],
                                   0.0,
                                   0.0,
                                   0.0);
                break;
              case up:
                /* Put on upper */
                task.putsolutioni (mosek.Env.accmode.var,
                                   j,
                                   mosek.Env.soltype.bas,
                                   mosek.Env.stakey.upr,
                                   bu[0],
                                   0.0,
                                   0.0,
                                   0.0);
                break;
              case fr:
                /* Put on superbasic */
                task.putsolutioni (mosek.Env.accmode.var,
                                   j,
                                   mosek.Env.soltype.bas,
                                   mosek.Env.stakey.supbas,
                                   0.0,
                                   0.0,
                                   0.0,
                                   0.0);
                break;
            }
          }
    
          /* Choose dual simplex */
          task.putintparam (mosek.Env.iparam.optimizer,
                            mosek.Env.optimizertype.dual_simplex.value);
    
          /* Reoptimize from the found solution from the network optimizer  */
          task.optimize ();
    
          /* Get solution status */
          try
          {
            task.getsolutioninf (mosek.Env.soltype.bas,
                                 prosta,
                                 solsta,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null);
          } 
          catch (mosek.ArrayLengthException e)
          {
              System.out.println ("Error: An array was too short");
              System.out.println (e.toString ());
          }
     
          if ( solsta[0] == mosek.Env.solsta.optimal )
          {
            System.out.println("Original network problem is optimal");
          }
          else if ( solsta[0] == mosek.Env.solsta.prim_infeas_cer )
          {
            System.out.println("Original network problem is primal infeasible");
          }
          else if ( solsta[0] == mosek.Env.solsta.dual_infeas_cer )
          {
            System.out.println("Original network problem is dual infeasible");
          }
          else
          {
            System.out.println("Original network problem solsta : "+solsta[0]);
          }
        }
        //  
      }
      catch (mosek.ArrayLengthException e)
      {
          System.out.println ("Error: An array was too short");
          System.out.println (e.toString ());
      }
      catch (java.lang.Exception e)
      /* Catch both mosek.Error and mosek.Warning */
      {
          System.out.println ("An error or warning was encountered");
          System.out.println (e.getMessage ());
      }
  
      // Dispose of task end environment
      if (dummytask != null) dummytask.dispose ();
      if (task != null)  task.dispose ();
      if (env  != null)  env.dispose ();
    }
  }
}
