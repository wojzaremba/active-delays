using System;
using System.Threading;
using System.Collections.Generic;
using System.Text;
using Microsoft.SolverFoundation.Common;
using Microsoft.SolverFoundation.Services;
using Microsoft.SolverFoundation.Solvers;
using System.Reflection;
using mosek;

[assembly: AssemblyTitle("MSFMosekPugIn")]
[assembly: AssemblyDescription("Mosek pugin for MSF")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("Mosek")]
[assembly: AssemblyProduct("MSFMosekPugIn")]
[assembly: AssemblyCopyright("")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: AssemblyVersion("2.0.0.1")]
[assembly: AssemblyFileVersion("2.0.0.1")]

namespace SolverFoundation.Plugin.Mosek
{

  public class MosekMsfFatalPluginException  : System.Exception
  {
    const string MosekMsfFatalPluginMessage = "Fatal error in plugin code";
    public MosekMsfFatalPluginException() : base(MosekMsfFatalPluginMessage) {}
    public MosekMsfFatalPluginException(string msg) : base(String.Format("{0} - {1}",MosekMsfFatalPluginMessage,msg)) {}
  }

  public class MosekMsfException  : System.Exception
  {
    const string MosekMsfMessage = "Error from MOSEK";
    public MosekMsfException() : base(MosekMsfMessage) {}
    public MosekMsfException(string msg) : base(String.Format("{0}",msg)) {}
  }

  public class MosekMsfUnsupportedFeatureException : MsfException
  {
    const string MosekMsfUnsupportedFeatureMNessage = "Feature not implemented by the MOSEK plug-in";
    public MosekMsfUnsupportedFeatureException() : base (MosekMsfUnsupportedFeatureMNessage) {}
    public MosekMsfUnsupportedFeatureException(string msg) : base(String.Format("{0} - {1}",MosekMsfUnsupportedFeatureMNessage,msg)) {}
  }

  public class MosekMsfNoSolutionDefinedException : MsfException
  {
    const string MosekMsfNoSolutionDefinedMessage = "No solution defined";
    public MosekMsfNoSolutionDefinedException() : base (MosekMsfNoSolutionDefinedMessage) {}
    public MosekMsfNoSolutionDefinedException(string msg) : base(String.Format("{0} - {1}",MosekMsfNoSolutionDefinedMessage,msg)) {}
  }
  
public class MosekLinearSolverReport : ILinearSolverReport {}

/// <summary> Base class for all MOSEK solver directives.  </summary>
public class MosekSolverDirective : Directive
{
  internal Dictionary<mosek.iparam,int> iparam = new Dictionary<mosek.iparam,int>();
  internal Dictionary<mosek.dparam,double> dparam = new Dictionary<mosek.dparam,double>();
  internal Dictionary<mosek.sparam,string> sparam = new Dictionary<mosek.sparam,string>();
  internal int timeLimit;
  internal List<System.Diagnostics.TraceListener> listeners = new  List<System.Diagnostics.TraceListener>();
  internal string taskFileName  = null;

    
  public MosekSolverDirective() : base() {}
  /// <summary> If set the MOSEK task file is written to this file-name before optimizing. </summary>
  public string TaskDumpFileName
    {
      get {
        return taskFileName;
      }

      set {
        taskFileName = value;
      }
    }
  
/// <summary> Optimizer time limit in seconds. </summary>    
  new public int TimeLimit
    {
      get {
        return timeLimit;
      }
      set {
        timeLimit = value;
        dparam[mosek.dparam.optimizer_max_time] = (double) value;
        dparam[mosek.dparam.mio_max_time] = (double) value;
      }
    }

 /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  
  public int this[mosek.iparam pkey]
    {
      set
        {
          SetMosekParameter(pkey,value);
        }
    }
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public double this[mosek.dparam pkey]
    {
      set
        {
          SetMosekParameter(pkey,value);
        }
    }
  
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public string this[mosek.sparam pkey]
    {
      set
        {
          SetMosekParameter(pkey,value);
        }
    }

  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void SetMosekParameter(mosek.iparam pkey,int value)
  {
    iparam[pkey] = value; 
  }
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void SetMosekParameter(mosek.dparam pkey,double value)
  {
    dparam[pkey] = value; 
  }
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void SetMosekParameter(mosek.sparam pkey,string value)
  {
    sparam[pkey] = value; 
  }
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void GetMosekParameters(Dictionary<mosek.iparam,int> ip)
  {
    foreach (KeyValuePair<mosek.iparam,int> p in iparam)
      ip[p.Key] = p.Value;
  }
  /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void GetMosekParameters(Dictionary<mosek.dparam,double> dp)
  {
    foreach (KeyValuePair<mosek.dparam,double> p in dparam)
      dp[p.Key] = p.Value;
  }
   /// <summary> Set MOSEK parameter. Please see the MOSEK .net API documentation for documentation of the available parameters. </summary>
  public void GetMosekParameters(Dictionary<mosek.sparam,string> sp)
  {
    foreach (KeyValuePair<mosek.sparam,string> p in sparam)
      sp[p.Key] = p.Value;
  }
  
  public void LoadMosekParams(mosek.Task task)
  {
    foreach (KeyValuePair<mosek.iparam,int> p in iparam)
      task.putintparam(p.Key,p.Value);
      
    foreach (KeyValuePair<mosek.dparam,double> p in dparam)
      task.putdouparam(p.Key,p.Value);

    foreach (KeyValuePair<mosek.sparam,string> p in sparam)
      task.putstrparam(p.Key,p.Value);   
  }
  
  /// <summary> Add a System.Diagnostics.TraceListener to which log information from the optimizer will be written. </summary>
  /// <param name="listener"> Listener to add. </param>
  public void AddListener(System.Diagnostics.TraceListener listener)
    {
      listeners.Add(listener);
    }
  /// <summary> Remove a listener  </summary>
  /// <param name="listener"> Listener to remove. </param>
  public void RemoveListener(System.Diagnostics.TraceListener listener)
    {
      listeners.Remove(listener);
    }

  public List<System.Diagnostics.TraceListener> GetListeners()
    {
      return listeners;
    }        
}

/// <summary> If this directive is parsed to the Solve method the Simplex algorithm will be used. If the problem has integer variables the MIP solver is called.</summary>
public class MosekSimplexDirective : MosekSolverDirective
{
  internal SimplexAlgorithm _algorithm;
  internal int _ite_limit;
  internal SimplexPricing _pricing;
  internal SimplexBasis _basis;
  
  public  MosekSimplexDirective() : base(){}

  public SimplexAlgorithm Algorithm
    {
      get {
        return _algorithm;
      }
      
      set {
        _algorithm = value;

        switch (_algorithm)
          {
          case SimplexAlgorithm.Primal:
            SetMosekParameter(mosek.iparam.optimizer,mosek.optimizertype.primal_simplex);
            break;
          case SimplexAlgorithm.Dual:
             SetMosekParameter(mosek.iparam.optimizer,mosek.optimizertype.dual_simplex);
             break;
          case SimplexAlgorithm.Default:
            SetMosekParameter(mosek.iparam.optimizer,mosek.optimizertype.free_simplex);
            break;
          }
      }
    }
 
  public int IterationLimit
    {
      get {
        return _ite_limit;
      }
      
      set {
        _ite_limit = value;
        SetMosekParameter(mosek.iparam.sim_max_iterations,_ite_limit);
      }
    }

    public SimplexPricing Pricing
    {
      get {
        return _pricing;
      }
      
      set {
        _pricing = value;
        /* Don't set the pricing, available options does not map to mosek values */
      }
    }
    
    public SimplexBasis Basis
    {
      get {
        return _basis;
      }
      
      set {
        _basis = value;
        /* No corresponding parameter */
      }
    }
}

  

/// <summary> If this directive is parsed to the Solve method the InteriorPoint algorithm will be used. If the problem has integer variables the MIP solver is called. </summary>
public class MosekInteriorPointMethodDirective : MosekSolverDirective
{
  public  MosekInteriorPointMethodDirective() : base(){}
}

/// <summary> If this directive is parsed to the Solve method the MIP solver will be used. </summary>
public class MosekMipDirective : MosekSolverDirective
{
  public  MosekMipDirective() : base(){}
}
/// <summary> Base class for all MOSEK solver parameters.  </summary>  
public class MosekSolverParams : MosekSolverDirective,ISolverParameters
{
  private Func<bool> cb = null;

  private void Init(MosekSolverDirective directive)
  {
    directive.GetMosekParameters(iparam);
    directive.GetMosekParameters(sparam);
    directive.GetMosekParameters(dparam);
    listeners = directive.GetListeners();
    TaskDumpFileName = directive.TaskDumpFileName;
  }
  
  public MosekSolverParams(){}

  public MosekSolverParams(Directive directive)
  {
    MosekSolverDirective mosekDirective = directive as MosekSolverDirective;       
    if(mosekDirective!=null)
      Init(mosekDirective);
  }

  /// <summary> Initialize parameters from Directive. </summary>
  public MosekSolverParams(MosekSolverDirective directive)
  {
    Init(directive);
  }

  public Func<bool> QueryAbort
    {
      set { cb = value; }
      get { return cb;  } 
    }
}
/// <summary> Parameters for the simplex solver. </summary>
public class MosekSimplexSolverParams : MosekSolverParams
{
  private void Init(MosekSimplexDirective directive)
  {
    if (! iparam.ContainsKey(mosek.iparam.optimizer))
      iparam[mosek.iparam.optimizer] = mosek.optimizertype.free_simplex;
  }
  
  public MosekSimplexSolverParams() : base()
  {
    iparam[mosek.iparam.optimizer] = mosek.optimizertype.free_simplex;
  }
  
  public MosekSimplexSolverParams(Directive directive) : base(directive)
  {
    MosekSimplexDirective mosekDirective = directive as MosekSimplexDirective;       
    if(mosekDirective != null)
    {
      Init(mosekDirective);
    }
    else
    {
      iparam[mosek.iparam.optimizer] = mosek.optimizertype.free_simplex;
    }
  }

  public MosekSimplexSolverParams(MosekSimplexDirective directive) : base(directive)
  {
    Init(directive);
  }
}

/// <summary> Parameters for the IP solver. </summary>
public class MosekInteriorPointSolverParams : MosekSolverParams
{
  private void Init(MosekInteriorPointMethodDirective directive)
  {
    if (! iparam.ContainsKey(mosek.iparam.optimizer))
      iparam[mosek.iparam.optimizer] = mosek.optimizertype.intpnt;
  }
  
  public MosekInteriorPointSolverParams() : base()
  {
        iparam[mosek.iparam.optimizer] = mosek.optimizertype.intpnt;
  }
  
  public MosekInteriorPointSolverParams(Directive directive) : base(directive)
  {
    MosekInteriorPointMethodDirective mosekDirective = directive as MosekInteriorPointMethodDirective;       
    if(mosekDirective !=null)
    {
      Init(mosekDirective);
    }
    else
    {
      iparam[mosek.iparam.optimizer] = mosek.optimizertype.intpnt;
    }
  }
  
  public MosekInteriorPointSolverParams(MosekInteriorPointMethodDirective directive) : base(directive)
  {
    Init(directive);
  }
}
 
/// <summary> Parameters for the MIP solver. </summary>
public class MosekMipSolverParams : MosekSolverParams
{
    public MosekMipSolverParams() : base() {}
    
    public MosekMipSolverParams(Directive directive) : base(directive){}

    public MosekMipSolverParams(MosekMipDirective directive) : base(directive){}
}

internal class LinearSolution : ILinearSolution

{
  internal LinearResult _result;
  internal LinearSolutionQuality _solutionQuality;
  internal int _solvedGoalCount;
  internal Dictionary<int,bool> _basis = new Dictionary<int,bool>();
  internal Dictionary<int,Rational> _solutionValue = new Dictionary<int,Rational>();
  internal ILinearGoal _goalUsed;
  internal Rational _primalObj;
  internal object _key = null;
  internal Rational _mipBestBound = Rational.Indeterminate;
  
  public LinearResult LpResult { get { return LinearResult.Invalid; } }
  public LinearResult MipResult { get { return _result; } }
  public LinearResult Result { get { return _result; } }
  public LinearSolutionQuality SolutionQuality { get { return _solutionQuality; } }
  public int SolvedGoalCount  { get { return _solvedGoalCount; } }
  
  public bool GetBasic(int vid) {
                           return _basis[vid];
                         }
  
  public Rational GetSolutionValue(int goalIndex) {
                                                   return _primalObj;
                                                   }
  
  public void GetSolvedGoal(int igoal, out object key, out int vid, out bool fMinimize, out bool fOptimal)
    {
      key = _goalUsed.Key;
      fMinimize = _goalUsed.Minimize;
      fOptimal = true;
      vid = _goalUsed.Index;
    }
  
  public Rational GetValue(int vid) { return  _solutionValue[vid] ; } 
  public LinearValueState GetValueState(int vid) { return LinearValueState.Invalid; }
  public Rational MipBestBound { get { return _mipBestBound; } }
}

/// <summary> Base class for all MOSEK solvers.  </summary>
public class MosekSolver : LinearModel,ILinearSolver,ILinearSolution
{
  protected Dictionary<int,int> rowMap = new Dictionary<int,int>(); /* Maps mssf row id to mosek row index */
  protected Dictionary<int,int> varMap = new Dictionary<int,int>(); /* Maps mssf var id to mosek var index */
  private bool interrupted;
  private bool foundIntSolution = false;
  private Rational mipBestBound = Rational.Indeterminate;
  private MosekMsg msgStream = null;
  private bool primalObjIsdef = false;
  private double primalObj = 0;
  private mosek.soltype solDefined;
  private mosek.prosta prosta;
  private mosek.solsta solsta;
  private MosekProgress progressCB = null;
  private Object classLock = new Object();
  private bool disposed = false;
  private ILinearGoal goalUsed = null;
  protected mosek.Env env = null;
  public Rational MipBestBound { get { return mipBestBound; } }
  
  private class MosekProgress : mosek.Progress
    {
      private Func<bool> cb = null;
      private bool stop = false;
      
      public MosekProgress() : base() {}
      public MosekProgress(Func<bool> QueryAbort)
        {
          cb = QueryAbort;
        }

      public Func<bool> QueryAbort {
        set {
          cb = value;
        }
      }
      
      public void Abort()
        {
          stop = true;
        }
      
      public override int progressCB(mosek.callbackcode caller)
        {

          if (stop)
            return  1;
          
          if (cb == null)
            return 0;
          
          if (cb())
            return 1;
          else
            return 0;
        }
    }

  private class MosekMsg : mosek.Stream
    {
      internal List<System.Diagnostics.TraceListener> listeners = new  List<System.Diagnostics.TraceListener>();
      
      public void AddListener(System.Diagnostics.TraceListener listener)
        {
          listeners.Add(listener);
        }

      public void RemoveListener(System.Diagnostics.TraceListener listener)
        {
          listeners.Remove(listener);
        }
        
      public override void streamCB (string msg)
        {
        
          foreach (System.Diagnostics.TraceListener l in listeners)
            l.Write(msg); 
        }
    }
  
  public MosekSolver() : this(null) {}
  
  public MosekSolver(System.Collections.Generic.IEqualityComparer<object> EqCompare) : base(EqCompare) 
    {
      env = new mosek.Env ();
      env.set_Stream (mosek.streamtype.log, null);
      env.set_Stream (mosek.streamtype.msg, null);
      env.set_Stream (mosek.streamtype.err, null);
      env.init ();
      msgStream = new MosekMsg();
    }
    

  private void UpdateAfterLoad()
    {
      IEnumerable<int> vars = VariableIndices;
      IEnumerable<int> rows = RowIndices;
      
      int i=0;
      foreach (int vid in vars)
        varMap.Add(vid,i++);
      i=0;
      foreach (int vid in rows)
        rowMap.Add(vid,i++);
    }
  
  new public virtual bool AddVariable(object key, out int vid)
    {
      bool e = base.AddVariable(key,out vid);
      if (e)
        varMap.Add(vid,VariableCount-1);
      
      return e;
    }

  new public virtual bool AddRow(object key, out int vid)
    {
      
      bool e =  base.AddRow(key,out vid);
      if (e)
        rowMap.Add(vid,RowCount-1);
      
      return e;
    }

  new public virtual void LoadLinearModel(ILinearModel model)
    {
      base.LoadLinearModel(model);
      UpdateAfterLoad();
    }
  
  private void PrintMatrixCmo()
    {
      IEnumerable<int> cols = VariableIndices;
      
      foreach (int vid in cols)
        {
          foreach (LinearEntry e in GetVariableEntries(vid))
            {
              Console.Write("({0},{1}) ",rowMap[e.Index],(double) e.Value);
            }
          Console.Write("\n");
        }
    }

  private void PrintQuadraticTerm(int vid)
    {
      foreach (QuadraticEntry e in GetRowQuadraticEntries(vid))
      {
        Console.Write("({0},{1},{2})\n",varMap[e.Index1],varMap[e.Index2],(double) e.Value);
      }
              
    }
  
  private void PrintMatrixRmo()
    {
      IEnumerable<int> rows = RowIndices;
      
      foreach (int vid in rows)
        {
          foreach (LinearEntry e in GetRowEntries(vid))
            {
              Console.Write("({0},{1}) ",varMap[e.Index],(double) e.Value);
            }
          Console.Write("\n");
        }
    }
  
  private void PutA(mosek.Task task)
    {
      IEnumerable<int> vars = VariableIndices;
      IEnumerable<int> rows = RowIndices;
      int mskColIdx = 0;
      bool rowMult = false;       /*  If true one of the row variable coeficient differ from the default -1 and we must scale with - 1/rc */

      /* for each constraint a 'row' variable 'r' is added. the constraint becomes a^x - r == 0. The coefficient (rc = -1) of the row variable may be changed by the user.
         This corresponds to multiplying the constraint with - 1/rc */
      
      foreach(int vid in rows)
        if (GetCoefficient(vid,vid) != -1.0)
          rowMult = true;
      
      if (rowMult)
        {
          foreach (int vid in vars)
            {
              foreach (LinearEntry e in GetVariableEntries(vid))
                {
                  double mul =  -(1.0/(double) GetCoefficient(e.Index,e.Index));
                  task.putaij(rowMap[e.Index],mskColIdx,(double) e.Value * mul);
                }
              mskColIdx++;
            }
        }
      else
        {
          foreach (int vid in vars)
            {
              foreach (LinearEntry e in GetVariableEntries(vid))
                {
                  task.putaij(rowMap[e.Index],mskColIdx,(double) e.Value);
                }
              mskColIdx++;
            }
        }
    }

  private void SetDimensions(mosek.Task task)
    {
      task.putmaxnumanz(CoefficientCount);
      task.append(mosek.accmode.con,RowCount);
      task.append(mosek.accmode.var,VariableCount);
    }

  private mosek.boundkey GetMosekBk(Rational lo,Rational hi)
    {
      if (lo == Rational.NegativeInfinity && hi == Rational.PositiveInfinity)
        return mosek.boundkey.fr;
      else if (lo == Rational.NegativeInfinity && hi != Rational.PositiveInfinity)
        return mosek.boundkey.up;
      else if (lo != Rational.NegativeInfinity && hi == Rational.PositiveInfinity)
        return mosek.boundkey.lo;
      else if (lo != Rational.NegativeInfinity && hi != Rational.PositiveInfinity) /* Fixed bounds are handled as ranged */ 
        return mosek.boundkey.ra;
      else
        {
          /* This should never happen */ 
          throw new MosekMsfFatalPluginException("Please contact Mosek support.");
        }    
    }
  
  private void PutBounds(mosek.Task task,IEnumerable<int> indices)
    {
      foreach (int vid in indices)
        {
          Rational lo,hi;
          
          GetBounds(vid, out lo,out hi);

          mosek.boundkey bk;
          
          if ( GetIgnoreBounds(vid) )
            bk = mosek.boundkey.fr;
          else
            bk = GetMosekBk(lo,hi);
             
          if (IsRow(vid))
              task.putbound(mosek.accmode.con,rowMap[vid],bk,(double) lo, (double) hi);
          else
              task.putbound(mosek.accmode.var,varMap[vid],bk,(double) lo, (double) hi);
        }
    }

  private  void PutObj(mosek.Task task)
    {
      if (GoalCount > 1)
        {
          throw new MosekMsfUnsupportedFeatureException("Multiple goals.");
        }

      foreach (ILinearGoal goal in Goals)
        {
          if (goal.Enabled)
            {
              if (goal.Minimize)
                task.putobjsense(mosek.objsense.minimize);
              else
                task.putobjsense(mosek.objsense.maximize);

              if (IsRow(goal.Index))
                {
                  goalUsed = goal;
                  
                  double mul =  -(1.0/(double)GetCoefficient(goal.Index,goal.Index));
                  foreach (LinearEntry e in GetRowEntries(goal.Index))
                    task.putcj(varMap[e.Index],(double) e.Value * mul);
                  foreach (QuadraticEntry e in GetRowQuadraticEntries(goal.Index))
                    {
                      double mul2 = 1.0;
                      if (e.Index2 == e.Index1)
                        mul2 = 2.0;
                      /* We assume that either q_ij or q_ji is nonzero, not both. 
                         We put all elements in the lower triangular part.  */
                      int index1 = varMap[e.Index1];
                      int index2 = varMap[e.Index2];
                      int ltIndex1 = System.Math.Max(index1,index2);
                      int ltIndex2 = System.Math.Min(index1,index2);
                      
                      task.putqobjij(ltIndex1,ltIndex2, (double) e.Value * mul * mul2);
                    }
                }
              else
                {
                  task.putcj(varMap[goal.Index],1.0);
                }
            }
        }     
    }

  protected virtual void SetIntergerStatus(mosek.Task task,IEnumerable<int> indices)
    {
      foreach (int vid in indices)
        if (GetIntegrality(vid))
          if (IsRow(vid))
            throw new MosekMsfUnsupportedFeatureException("Integrality constraints on rows.");
          else
            task.putvartype(varMap[vid],mosek.variabletype.type_int);      
    }
  
  private bool InitSoltypeDefined(mosek.Task task,out mosek.soltype sol)
    {
      int isdef_bas;
      int isdef_itr;
      int isdef_itg;

      task.solutiondef(mosek.soltype.bas,out isdef_bas);
      task.solutiondef(mosek.soltype.itr,out isdef_itr);
      task.solutiondef(mosek.soltype.itg,out isdef_itg);

      sol = mosek.soltype.itg;
                
      if (isdef_bas == 0 && isdef_itr == 0 && isdef_itg == 0 )
        {
          return false;
        }
      
      if (isdef_itg == 1)
        {
          sol =  mosek.soltype.itg;
        }
      
      if (isdef_bas == 1)
        {
          sol =  mosek.soltype.bas;
        }
      else if (isdef_itr == 1)
        {
          sol = mosek.soltype.itr;
        }

      return true;

    }

    private bool GetSoltypeDefined(out mosek.soltype sol)
    {
      sol = solDefined;
      
      return primalObjIsdef;
    }

    private void UpdateSolutionPart(IEnumerable<int> indices,double[] val,mosek.stakey[] sk)
    {
      int idx = 0;
      List<int> indices2 = new List<int>();

      foreach (int vid in indices)
        indices2.Add(vid);
      
      foreach (int vid in indices2)
        {
          SetValue(vid,val[idx]);
          if (sk[idx] == mosek.stakey.bas)
            SetBasic(vid,true);
          else
            SetBasic(vid,false);
          
          idx++;
        }
    }
  
  private void UpdateSolution(mosek.Task task)
    {
      double[] xx = new double[VariableCount];
      double[] xc = new double[RowCount];
      mosek.stakey[] skx = new mosek.stakey[VariableCount];
      mosek.stakey[] skc = new mosek.stakey[RowCount];
      mosek.soltype sol;

      primalObjIsdef = InitSoltypeDefined(task,out solDefined);

      if ( GetSoltypeDefined ( out sol))
        task.getsolutionstatus (
                                sol,
                                out  prosta,
                                out  solsta);
      
      if(GetSoltypeDefined(out sol))
        {
          task.getsolutionstatuskeyslice (
                                          mosek.accmode.var,
                                          sol,
                                          0,
                                          VariableCount,
                                          skx);
            
          task.getsolutionstatuskeyslice (
                                          mosek.accmode.con,
                                          sol,
                                          0,
                                          RowCount,
                                          skc);
      
          task.getsolutionslice (
                                 sol,
                                 mosek.solitem.xx,
                                 0,
                                 VariableCount,
                                 xx);
      
          task.getsolutionslice (
                                 sol,
                                 mosek.solitem.xc,
                                 0,
                                 RowCount,
                                 xc);


          UpdateSolutionPart(RowIndices,xc,skc); 
          UpdateSolutionPart(VariableIndices,xx,skx);

       
        }

      if ( GetSoltypeDefined(out sol) )
        {
          primalObjIsdef = true;
          primalObj = task.getprimalobj (sol);
        }      
    }

  private LinearSolution CreateLinearSolution()
    {
      LinearSolution s = new LinearSolution();
      s._goalUsed = goalUsed;
      s._result = Result;
      s._solutionQuality = SolutionQuality;
      s._solvedGoalCount = SolvedGoalCount;
      
      foreach(int vid in RowIndices)
        {
          s._basis[vid] = GetBasic(vid);
          s._solutionValue[vid] = GetValue(vid);
        }
      foreach(int vid in VariableIndices)
        {
          s._basis[vid] = GetBasic(vid);
          s._solutionValue[vid] = GetValue(vid);
        }

      s._primalObj     =  GetSolutionValue(goalUsed.Index);
      s._mipBestBound  =  mipBestBound;
      return s;
    }
  
  private void LoadData(mosek.Task task)
    {
      SetDimensions(task);
      PutA(task);
      PutBounds(task,VariableIndices);
      PutBounds(task,RowIndices);
      PutObj(task);
      SetIntergerStatus(task,Indices);
    }

  private void printSolution(ILinearSolution s)
    {
      Console.WriteLine("LpResult {0}", s.LpResult);
      Console.WriteLine("MipResult {0}",s.MipResult);
      Console.WriteLine("Result {0}",s.Result);
      Console.WriteLine("SolutionQuality {0}",s.SolutionQuality);
      Console.WriteLine("SolvedGoalCount {0}" , s.SolvedGoalCount);
      
      foreach (int vid in VariableIndices)
        Console.WriteLine("basis {0}",s.GetBasic(vid));
      foreach (int vid in RowIndices)
        Console.WriteLine("basis {0}",s.GetBasic(vid));

      Console.WriteLine("GetSolutionValue {0}",(double)s.GetSolutionValue(1));
        
      foreach (int vid in VariableIndices)
        Console.WriteLine("value {0}",(double)s.GetValue(vid));
      foreach (int vid in RowIndices)
        Console.WriteLine("value {0}",(double)s.GetValue(vid));

      Object key;
      int avid;
      bool fMinimize;
      bool fOptimal;
      
      s.GetSolvedGoal(0,out key,out avid, out fMinimize, out fOptimal);
      
    }
  
  public virtual ILinearSolution Solve(ISolverParameters parameters)
    {
      lock(classLock)
        {
          if (env != null) /* If shutdown has already been called, env may be null.  */
            {
              mosek.Task task = null;
              task = new mosek.Task (env, 0, 0);
              task.set_Stream (mosek.streamtype.log, null);
              task.set_Stream (mosek.streamtype.msg, null);
              task.set_Stream (mosek.streamtype.err, null);
      
              MosekSolverParams mosekParams = parameters as MosekSolverParams;

              interrupted = false;
              primalObjIsdef = false;
      
              foreach(System.Diagnostics.TraceListener listener in mosekParams.GetListeners())
                msgStream.AddListener(listener);
      
              if (msgStream.listeners.Count > 0) 
                task.set_Stream (mosek.streamtype.log, msgStream);
      
              mosekParams.LoadMosekParams(task);
              progressCB = new MosekProgress(parameters.QueryAbort);

              task.ProgressCB = progressCB;

              if (disposed)
                progressCB.Abort();
              
              LoadData(task);
        
              if (mosekParams.TaskDumpFileName != null)
                task.writedata(mosekParams.TaskDumpFileName);

              try
                {
                    task.optimize();
                }
              catch (mosek.Warning w)
                {
                if (w.Code == mosek.rescode.trm_user_callback) {
                  interrupted = true;
                  // feasible solutions ? 
                  if (task.getintinf(mosek.iinfitem.mio_num_int_solutions) > 0)
                    foundIntSolution = true;                  
                  }
                }
              catch (mosek.Error e)
                {
                  throw new MosekMsfException(e.ToString());
                }
          
              if (task.getintinf(mosek.iinfitem.mio_num_relax) > 0)
                mipBestBound = task.getdouinf(dinfitem.mio_obj_bound);
              
              task.solutionsummary(mosek.streamtype.log);

              UpdateSolution(task);
              progressCB = null;
              if (task != null)
                {
                  task.Dispose();
                  task = null;
                }
            }
        }

      ILinearSolution sol = CreateLinearSolution();
                    
      return sol;
    }

  public virtual ILinearSolverReport GetReport(LinearSolverReportType reportType)
    {
      return new MosekLinearSolverReport();
    }
  
  public virtual Rational GetSolutionValue(int goalIndex)
    {          
      if ( primalObjIsdef )
        {
          return primalObj;
        }
      else
        throw new MosekMsfNoSolutionDefinedException();
    }

  public virtual void GetSolvedGoal(int igoal,out object key,out int vid,out bool fMinimize,out bool fOptimal) {vid = goalUsed.Index;fMinimize=goalUsed.Minimize;fOptimal=true;key=goalUsed.Key;}
  public virtual LinearResult LpResult { get { return LinearResult.Invalid; } } /* For now we  do not return a solution for the root node */
  public virtual LinearResult MipResult { get { return Result; } }
  public virtual LinearResult Result {
    get {
      mosek.soltype sol;
      LinearResult res = LinearResult.Invalid;

      if (interrupted) {
        // return LinearResult.Feasible if mipbestbound was set
        if ( foundIntSolution )
          return LinearResult.Feasible;
        else
          return LinearResult.Interrupted;
      }
      
      if ( GetSoltypeDefined ( out sol))
        {
          switch (solsta)
            {
            case mosek.solsta.optimal:
            case mosek.solsta.near_integer_optimal:
            case mosek.solsta.near_optimal:
            case mosek.solsta.integer_optimal:
              res = LinearResult.Optimal;
              break;

            case mosek.solsta.dual_feas:
            case mosek.solsta.near_dual_feas:
            case mosek.solsta.near_prim_and_dual_feas:
              res = LinearResult.Interrupted;  /* No way of returning dual feasible   */
              break;
            case mosek.solsta.near_prim_feas:
            case mosek.solsta.prim_feas:
            case mosek.solsta.prim_and_dual_feas:
              res = LinearResult.Feasible;  
              break;

            case mosek.solsta.dual_infeas_cer:
            case mosek.solsta.near_dual_infeas_cer:
              /* From problems status we will always know if the problem is primal infeasible or unbounded. But this information is lost here. */
              if (prosta == prosta.dual_infeas)
                res = LinearResult.UnboundedPrimal;
              else
                res = LinearResult.InfeasibleOrUnbounded;
              break;
            case mosek.solsta.prim_infeas_cer:
            case mosek.solsta.near_prim_infeas_cer:
              if (prosta == prosta.prim_infeas)
                res = LinearResult.UnboundedDual;
              else
                res = LinearResult.InfeasiblePrimal;
              break;
            case      mosek.solsta.unknown:
              res = LinearResult.Invalid;
              break;
            }                
        }
      return (res);
    }
  }
  
  public virtual LinearSolutionQuality SolutionQuality {
    get {
      mosek.soltype sol;
      if ( ! GetSoltypeDefined(out sol))
        return LinearSolutionQuality.None;
      else
        return LinearSolutionQuality.Approximate;
    }
  }
  
  public virtual int SolvedGoalCount {
    get {
      mosek.soltype sol;
      if ( ! GetSoltypeDefined(out sol))
        return 0;
      else
        return 1;
    }
  }
  
  public virtual void Shutdown()
    {
      /* stop optimize */
      
      if (progressCB != null)
        progressCB.Abort();

      disposed = true;

      /* This method could be called while we are solving.
         We must wait until solve has exited and deleted it's resources. */
      lock(classLock)
        {      
          if (env != null)
            {
              env.Dispose();
              env = null;
            }
        }
    }

  /// <summary> Add a System.Diagnostics.TraceListener to which log information from the optimizer will be written. </summary>
  /// <param name="listener"> Listener to add. </param>
  public virtual void AddListener(System.Diagnostics.TraceListener listener)
    {
      msgStream.AddListener(listener);
    }

  /// <summary> Remove a listener  </summary>
  /// <param name="listener"> Listener to remove. </param>
  public virtual void RemoveListener(System.Diagnostics.TraceListener listener)
    {
      msgStream.RemoveListener(listener);
    }       
}

/// <summary> MOSEK interior point solver.  </summary>
public class MosekInteriorPointSolver :  MosekSolver
{  
  public MosekInteriorPointSolver() : base() {}
  
  public MosekInteriorPointSolver(System.Collections.Generic.IEqualityComparer<object> EqCompare) : base(EqCompare) {}

  public MosekInteriorPointSolver (Microsoft.SolverFoundation.Services.ISolverEnvironment env) : base() {}
    
}

/// <summary> MOSEK MIP  solver.  </summary>
public class MosekMipSolver :  MosekSolver
{  
  public MosekMipSolver() : base() {}
  
  public MosekMipSolver(System.Collections.Generic.IEqualityComparer<object> EqCompare) : base(EqCompare) {}

  public MosekMipSolver (Microsoft.SolverFoundation.Services.ISolverEnvironment env) : base() {}
}

/// <summary> MOSEK simplex solver.  </summary>
public class MosekSimplexSolver :  MosekSolver
{  
  public MosekSimplexSolver() : base() {}
  
  public MosekSimplexSolver(System.Collections.Generic.IEqualityComparer<object> EqCompare) : base(EqCompare) {}

  public MosekSimplexSolver (Microsoft.SolverFoundation.Services.ISolverEnvironment env) : base() {}
}

}
