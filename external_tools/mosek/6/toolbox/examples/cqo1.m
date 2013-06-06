% cqo1.m

clear prob;

% Specify the non-confic part of the problem.

prob.c   = [0 0 0 0 1 1];
prob.a   = sparse([1 1 1 1 0 0]);
prob.blc = 1;
prob.buc = 1;
prob.blx = [0 0 0 0 -inf -inf];
prob.bux = inf*ones(6,1);

% Specify the cones.
% Define an empty cell array names 'cones' containing one cell per cone.
 
prob.cones   = cell(2,1);

% The first cone is specified.

prob.cones{1}.type = 'MSK_CT_QUAD';
prob.cones{1}.sub  = [5 3 1];

% The second cone is specified.

prob.cones{2}.type = 'MSK_CT_QUAD';
prob.cones{2}.sub  = [6 2 4];

% The field 'type' specifies the cone type, i.e. whether it is quadratic cone
% or rotated quadratic cone. The keys for the two cone types are MSK_CT_QUAD
% MSK_CT_RQUAD respectively.
%
% The field 'sub' specifies the members of the cone, i.e. the above definitions
% imply that x(5) >= sqrt(x(3)^2+x(1)^2) and x(6) * x(2) >= x(4)^2.

% Optimize the problem. 

[r,res]=mosekopt('minimize',prob);

% Display the primal solution.

res.sol.itr.xx'
