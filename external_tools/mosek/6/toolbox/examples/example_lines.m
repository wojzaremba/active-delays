% How to change the parameters that controls
% the accuracy of a solution computed by the conic
% optimizer.

param = [];

% Primal feasibility tolerance for the primal solution
param.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1.0e-8;

% Dual feasibility tolerance for the dual solution
param.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1.0e-8;

% Relative primal-dual gap tolerance.
param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1.0e-8;

[r,res]=mosekopt('minimize',prob,param);


d     = [1 1]';
c     = [-1 0]';
a     = [1 1];
blc   = 1;
buc   = 1;
[res] = mskenopt(d,c,a,blc,buc);
res.sol.itr.xx;

% Solve a problem and obtain
% the task information database.
[r,res]=mosekopt('minimize info',prob);

% View one item
res.info.MSK_IINF_INTPNT_ITER

% View the whole database
res.info



% Obtain all symbolic constants
% defined by MOSEK.

[r,res]  = mosekopt('symbcon');
sc       = res.symbcon;

param    = [];

% Basis identification is unnecessary.
param.MSK_IPAR_INTPNT_BASIS   = sc.MSK_OFF;

% Alternatively you can use
%
%  param.MSK_IPAR_INTPNT_BASIS   = 'MSK_OFF';
%

% Use another termination tolerance.
param.MSK_DPAR_INTPNT_TOLRGAP = 1.0e-9;

% Perform optimization using the
% modified parameters.

[r,res] =  mosekopt('minimize',prob,param);


% The problem is named.
prob.names.name   = 'CQO example';

% Objective name.
prob.names.obj    = 'cost';

% The two constraints are named.
prob.names.con{1} = 'constraint_1';
prob.names.con{2} = 'constraint_2';

% The six variables are named.
prob.names.var    = cell(6,1);
for j=1:6
  prob.names.var{j} = sprintf('x%d',j);
end

% Finally the two cones are named.
prob.names.cone{1} = 'cone_a';
prob.names.cone{2} = 'cone_b';



%
% In this example the MOSEK log info
% should be printed to the screen and to a file named
% mosek.log.
%

fid                = fopen('mosek.log','wt');
callback.log       = 'myprint';
callback.loghandle = fid;

%
% The 'handle' argument in myprint() will be identical to
% callback.loghandle when called.
%

mosekopt('minimize',prob,[],callback);


[r,res]             = mosekopt('symbcon');
data.maxtime        = 100.0;
data.symbcon        = res.symbcon;

callback.iter       = 'myiter';
callback.iterhandle = data;

mosekopt('minimize',prob,[],callback);



% Obtain the parameter database.
[rcode,res] = mosekopt('param');

% Display the parameter database.
res.param
param = res.param;

% Modify a parameter.
param.MSK_IPAR_OPTIMIZER = 3

% Optimize a problem.
[rcode,res]=mosekopt('minimize info',prob,param);

% Display the information database.
res.info 



% Optimize a problem having only linear inequalities.
x = linprog(f,A,b);

% Optimizes problem only
% having linear inequalities.
x = quadprog(H,f,A,b); 

% Solve a linear least
% squares problem.
x = lsqlin(C,d,A,b);

% Solve the problem
x = lsqnonneg(C,d);

% Obtain the value of the diagnostics
% option.
val = optimget(options,'Diagnostics');

% val is equal to the default value.
val = optimget(options,'Nopar',1.0e-1);

% Obtain the default options.
opt = optimset

% Modify the value of the parameter
% display in the optimization
% options structure
opt = optimset(opt,'display','on');

% Return default options
opt = optimset('whatever')

% Modify a MOSEK parameter.
opt = [];
opt = optimset(opt,'MSK_DPAR_INTPNT_TOLMURED',1.0e-14); 
