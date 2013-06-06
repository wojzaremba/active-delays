% cqo2.m

% Set up the non-conic part of the problem.

prob          = [];
prob.c        = [1 1 1 0 0 0 0]';
prob.a        = sparse([[1 0 1 0 1 0 0];...
                        [0 1 0 0 0 0 -1]]);
prob.blc      = [0.5 0];
prob.buc      = [0.5 0];
prob.blx      = [-inf -inf -inf 1 -inf 1 -inf];
prob.bux      = [inf   inf  inf 1  inf 1  inf];

% Set up the cone information.

prob.cones         = cell(2,1);
prob.cones{1}.type = 'MSK_CT_QUAD';
prob.cones{1}.sub  = [4 1 2 3];
prob.cones{2}.type = 'MSK_CT_RQUAD';
prob.cones{2}.sub  = [5 6 7];

[r,res]       = mosekopt('minimize',prob);

% Display the solution.
res.sol.itr.xx'
